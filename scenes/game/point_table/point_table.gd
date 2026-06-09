extends Node2D

# ─── Node References ──────────────────────────────────────────────────────
@onready var countdown_label : Label         = $ContentLayer/MainContent/TopBar/CountdownLabel
@onready var players_grid    : GridContainer = $ContentLayer/PlayersGrid
@onready var countdown_timer : Timer         = $Timer

# ─── Scene References ─────────────────────────────────────────────────────
const PLAYER_CARD_SCENE := preload("res://scenes/ui/components/player_card/player_card.tscn")
const NEXT_SCENE := "res://scenes/main_menu/main_menu.tscn"

# ─── Constants ────────────────────────────────────────────────────────────
const COUNTDOWN_SECONDS := 10

# ─── Internal ─────────────────────────────────────────────────────────────
var _countdown : int = COUNTDOWN_SECONDS


# ─── Lifecycle ────────────────────────────────────────────────────────────
func _ready() -> void:
	# ── TEMP: remove when full game flow is connected ──────────────────────
	GameState.add_player("Player 1")
	GameState.add_player("Player 2")
	GameState.add_player("Player 3")
	GameState.add_player("Player 4")
	GameState.add_score(0, 100)
	GameState.add_score(1, 75)
	GameState.add_score(2, 50)
	GameState.add_score(3, 25)
	# ───────────────────────────────────────────────────────────────────────
	
	_build_player_cards()
	_start_countdown()


# ─── Player Cards ─────────────────────────────────────────────────────────
func _build_player_cards() -> void:
	# Sort players by score, highest first
	var sorted := GameState.players.duplicate()
	sorted.sort_custom(func(a, b): return a["score"] > b["score"])

	# Top score = winner
	var top_score : int = sorted[0]["score"] if sorted.size() > 0 else 0

	for player in sorted:
		var card      := PLAYER_CARD_SCENE.instantiate()
		var delta     : int  = GameState.get_score_delta(player["id"])
		var is_winner : bool = player["score"] == top_score

		players_grid.add_child(card)
		card.setup(player, delta, is_winner)


# ─── Countdown ────────────────────────────────────────────────────────────
func _start_countdown() -> void:
	_countdown = COUNTDOWN_SECONDS
	countdown_label.text = str(_countdown)
	countdown_timer.wait_time = 1.0
	countdown_timer.timeout.connect(_on_tick)
	countdown_timer.start()


func _on_tick() -> void:
	_countdown -= 1
	countdown_label.text = str(_countdown)

	if _countdown <= 0:
		countdown_timer.stop()
		get_tree().change_scene_to_file(NEXT_SCENE)
