# res://scenes/game/minigames/las_canicas/las_canicas.gd
extends Node2D

# --- CONFIGURATION ---
const DEBUG_SIMULATION: bool = true # Simulates mobile player selections
const ROUND_TIME: float = 15.0
const POINTS_FOR_WINNING: int = 10

# --- UI REFERENCES ---
@onready var duels_grid = $UILayer/DuelsGrid      # Note the UILayer/ prefix!
@onready var timer_label = $UILayer/TimerLabel    # Note the UILayer/ prefix!
@onready var simulation_timer = $SimulationTimer

# --- GAME STATE ---
var active_duels: Array = [] # Stores pairs: [ [player_dict, player_dict], ... ]
var player_choices: Dictionary = {} # Stores choices: { player_id (int): {"bet": int, "guess": "par"|"impar"} }
var game_over: bool = false
var losers_this_round: Array[int] = [] # Tracks player IDs who lost and must pay a "prenda"

func _ready() -> void:
	# 1. Fallback for quick testing (F6) if GameState has no players
	if GameState.players.is_empty():
		print("[CANICAS] No players found in GameState. Creating dummy players for testing...")
		GameState.add_player("Nico")
		GameState.add_player("Santi")
		GameState.add_player("Sol")
		GameState.add_player("CPU Guard") # Dummy 4th player
	
	setup_tv_screen()
	
	if DEBUG_SIMULATION:
		print("[CANICAS] TV-Only Simulation Mode Active.")
		simulation_timer.start(3.0) # Simulates choices arriving after 3 seconds
	else:
		# PLACEHOLDER: Emit your socket.io event to mobile clients here
		# e.g., SocketManager.send_event_to_all("start_canicas_input")
		pass

func setup_tv_screen() -> void:
	timer_label.text = str(ROUND_TIME)
	player_choices.clear()
	active_duels.clear()
	losers_this_round.clear()
	
	# Clear grid for clean slate
	for child in duels_grid.get_children():
		child.queue_free()
		
	# 2. Pair up your players from GameState.players
	var pool_players = GameState.players.duplicate()
	pool_players.shuffle()
	
	while pool_players.size() > 0:
		if pool_players.size() >= 2:
			var p1 = pool_players.pop_back()
			var p2 = pool_players.pop_back()
			active_duels.append([p1, p2])
		else:
			# Odd number of players: pair the remaining player with a temporary CPU Bot
			var p1 = pool_players.pop_back()
			var cpu_bot = { "id": -1, "name": "CPU Guard", "score": 0 }
			active_duels.append([p1, cpu_bot])
			
	# 3. Create TV cards for each duel
	render_duels_on_tv()

func render_duels_on_tv() -> void:
	for duel in active_duels:
		var p1 = duel[0]
		var p2 = duel[1]
		
		var duel_panel = PanelContainer.new()
		duel_panel.custom_minimum_size = Vector2(400, 200)
		
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		# Player 1 VBox
		var p1_vbox = VBoxContainer.new()
		var p1_name = Label.new()
		p1_name.text = p1["name"]
		var p1_status = Label.new()
		p1_status.text = "Pensando..."
		p1_vbox.add_child(p1_name)
		p1_vbox.add_child(p1_status)
		
		# VS Label
		var vs_label = Label.new()
		vs_label.text = "  VS  "
		
		# Player 2 VBox
		var p2_vbox = VBoxContainer.new()
		var p2_name = Label.new()
		p2_name.text = p2["name"]
		var p2_status = Label.new()
		p2_status.text = "Pensando..."
		p2_vbox.add_child(p2_name)
		p2_vbox.add_child(p2_status)
		
		hbox.add_child(p1_vbox)
		hbox.add_child(vs_label)
		hbox.add_child(p2_vbox)
		duel_panel.add_child(hbox)
		
		# Store metadata references using your integer IDs
		duel_panel.set_meta("p1_id", p1["id"])
		duel_panel.set_meta("p2_id", p2["id"])
		duel_panel.set_meta("p1_status", p1_status)
		duel_panel.set_meta("p2_status", p2_status)
		
		duels_grid.add_child(duel_panel)

# --- WEB/MOBILE RECEIVER PLACEHOLDER ---

# Call this function when receiving the socket choice from a mobile device
func on_player_submitted_choice(player_id: int, bet: int, guess: String) -> void:
	if game_over: return
	
	player_choices[player_id] = {"bet": bet, "guess": guess}
	update_tv_player_status(player_id, "¡Listo!")
	
	# Check if all active real players have submitted
	var real_players_count = GameState.players.size()
	if player_choices.size() >= real_players_count:
		resolve_round()

func update_tv_player_status(player_id: int, status_text: String) -> void:
	for panel in duels_grid.get_children():
		if panel.get_meta("p1_id") == player_id:
			panel.get_meta("p1_status").text = status_text
		elif panel.get_meta("p2_id") == player_id:
			panel.get_meta("p2_status").text = status_text

# --- DRAMA & RESOLUTION (TV ONLY) ---

func resolve_round() -> void:
	game_over = true
	timer_label.text = "¡TIEMPO!"
	
	# Handle AFK players (who didn't pick in time)
	for p in GameState.players:
		if not player_choices.has(p["id"]):
			player_choices[p["id"]] = {"bet": randi_range(1, 10), "guess": "par"}
			update_tv_player_status(p["id"], "¡Tiempo Agotado!")
			
	# Always assign a choice to the CPU Bot if one is active
	if not player_choices.has(-1):
		player_choices[-1] = {"bet": randi_range(1, 10), "guess": "par" if randf() > 0.5 else "impar"}

	await get_tree().create_timer(1.5).timeout
	
	# Resolve each duel card sequentially for maximum TV drama
	for panel in duels_grid.get_children():
		var p1_id: int = panel.get_meta("p1_id")
		var p2_id: int = panel.get_meta("p2_id")
		
		var p1_choice = player_choices[p1_id]
		var p2_choice = player_choices[p2_id]
		
		# Par/Impar calculations
		var p2_bet_is_even = (p2_choice["bet"] % 2 == 0)
		var p1_guessed_right = (p1_choice["guess"] == "par" and p2_bet_is_even) or (p1_choice["guess"] == "impar" and not p2_bet_is_even)
		
		var p1_bet_is_even = (p1_choice["bet"] % 2 == 0)
		var p2_guessed_right = (p2_choice["guess"] == "par" and p1_bet_is_even) or (p2_choice["guess"] == "impar" and not p1_bet_is_even)
		
		# Visual reveal text
		panel.get_meta("p1_status").text = "Apostó: %d\nPredijo: %s" % [p1_choice["bet"], p1_choice["guess"].to_upper()]
		panel.get_meta("p2_status").text = "Apostó: %d\nPredijo: %s" % [p2_choice["bet"], p2_choice["guess"].to_upper()]
		
		panel.self_modulate = Color.YELLOW # Highlight active duel resolution
		await get_tree().create_timer(2.0).timeout
		
		# Resolve winner/loser
		if p1_guessed_right and not p2_guessed_right:
			panel.get_meta("p1_status").text += "\n[color=green]¡SALVADO![/color]"
			panel.get_meta("p2_status").text += "\n[color=red]¡PRENDA![/color]"
			panel.self_modulate = Color.GREEN
			
			if p1_id != -1: GameState.add_score(p1_id, POINTS_FOR_WINNING)
			if p2_id != -1: losers_this_round.append(p2_id)
			
		elif p2_guessed_right and not p1_guessed_right:
			panel.get_meta("p1_status").text += "\n[color=red]¡PRENDA![/color]"
			panel.get_meta("p2_status").text += "\n[color=green]¡SALVADO![/color]"
			panel.self_modulate = Color.GREEN
			
			if p2_id != -1: GameState.add_score(p2_id, POINTS_FOR_WINNING)
			if p1_id != -1: losers_this_round.append(p1_id)
			
		else:
			# Draw (both failed or both guessed right): both get a penalty for maximum chaos!
			panel.get_meta("p1_status").text += "\n[color=red]¡DUELO FALLIDO![/color]"
			panel.get_meta("p2_status").text += "\n[color=red]¡DUELO FALLIDO![/color]"
			panel.self_modulate = Color.RED
			
			if p1_id != -1: losers_this_round.append(p1_id)
			if p2_id != -1: losers_this_round.append(p2_id)
			
		await get_tree().create_timer(1.5).timeout
	
	transition_to_penalty_screen()

func transition_to_penalty_screen() -> void:
	print("[CANICAS] Transitioning to Penalty Screen. Losers: ", losers_this_round)
	
	# Update the Autoload State
	GameState.current_state = GameState.State.PENALTY
	
	# TODO: Store losers_this_round in GameState if your Penalty Screen needs to read it:
	# GameState.current_round_losers = losers_this_round
	
	# Transition to your next scene:
	# get_tree().change_scene_to_file("res://scenes/game/penalty/penalty.tscn")

# --- DEBUG SIMULATION TIMER ---
func _on_simulation_timer_timeout() -> void:
	# Simulates choices arriving from player mobile phones
	for duel in active_duels:
		var p1_id = duel[0]["id"]
		var p2_id = duel[1]["id"]
		
		# Generate randomized choices
		if p1_id != -1:
			on_player_submitted_choice(p1_id, randi_range(1, 10), "par" if randf() > 0.5 else "impar")
		if p2_id != -1:
			on_player_submitted_choice(p2_id, randi_range(1, 10), "par" if randf() > 0.5 else "impar")
