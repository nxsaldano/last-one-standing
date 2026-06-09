extends Node

# ─── Enums ────────────────────────────────────────────────────────────────
enum Deck  { SQUID_GAME, STRANGER_THINGS, SEX_EDUCATION }
enum Tone  { TRANQUILO, PICANTE, APTO_PARA_TOMAR }
enum State { LOBBY, PLAYING, CHAOS_EVENT, PENALTY, GAME_OVER }

# ─── Signals ──────────────────────────────────────────────────────────────
signal player_added(player: Dictionary)
signal score_changed(player_id: int, new_score: int)
signal game_started
signal round_ended
signal game_over

# ─── Game Settings (chosen in Lobby) ──────────────────────────────────────
var selected_deck : Deck  = Deck.SQUID_GAME
var selected_tone : Tone  = Tone.TRANQUILO
var current_state : State = State.LOBBY
var current_round : int   = 0

# ─── Players ──────────────────────────────────────────────────────────────
# Each player is a Dictionary:
# { "id": 0, "name": "Player 1", "score": 0 }
var players : Array[Dictionary] = []
var previous_scores  : Dictionary        = {}


# ─── Player Management ────────────────────────────────────────────────────
func add_player(player_name: String) -> void:
	var player := {
		"id"    : players.size(),
		"name"  : player_name,
		"score" : 0
	}
	players.append(player)
	emit_signal("player_added", player)


func add_score(player_id: int, amount: int) -> void:
	players[player_id]["score"] += amount
	emit_signal("score_changed", player_id, players[player_id]["score"])


func get_player(player_id: int) -> Dictionary:
	return players[player_id]


func get_winner() -> Dictionary:
	var winner := players[0]
	for player in players:
		if player["score"] > winner["score"]:
			winner = player
	return winner

func snapshot_scores() -> void:
	for player in players:
		previous_scores[player["id"]] = player["score"]

func get_score_delta(player_id: int) -> int:
	if previous_scores.has(player_id):
		return players[player_id]["score"] - previous_scores[player_id]
	return 0

# ─── Game Flow ────────────────────────────────────────────────────────────
func start_game() -> void:
	current_round = 1
	current_state = State.PLAYING
	emit_signal("game_started")


func next_round() -> void:
	current_round += 1
	emit_signal("round_ended")


func end_game() -> void:
	current_state = State.GAME_OVER
	emit_signal("game_over")


# ─── Reset (for rematches) ────────────────────────────────────────────────
func reset() -> void:
	players.clear()
	previous_scores.clear()
	current_round = 0
	current_state = State.LOBBY
	selected_deck  = Deck.SQUID_GAME
	selected_tone  = Tone.TRANQUILO
