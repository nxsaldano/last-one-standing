extends Node2D

# ─── Node References ──────────────────────────────────────────────────────
@onready var player_grid     : HBoxContainer = $ContentLayer/MainContent/PlayersSection/PlayerGrid
@onready var countdown_label : Label         = $ContentLayer/MainContent/PlayersSection/CountdownLabel

# ─── Scene References ─────────────────────────────────────────────────────
const PLAYER_SLOT_SCENE := preload("res://scenes/ui/components/player_slot/PlayerSlot.tscn")
const MINIGAME_SCENE    := "res://scenes/game/minigames/luz_verde_luz_roja/luz_verde_luz_roja.tscn"
const GAME_SCENE        := "res://scenes/game/tv_display/tv_display.tscn"   

# ─── Constants ────────────────────────────────────────────────────────────
const MAX_PLAYERS       := 4
const MIN_PLAYERS       := 2
const COUNTDOWN_SECONDS := 10

# ─── Internal ─────────────────────────────────────────────────────────────
var _slots     : Array = []
var _countdown : int   = COUNTDOWN_SECONDS
var _starting  : bool  = false
var _timer     : Timer = null


# ─── Lifecycle ────────────────────────────────────────────────────────────
func _ready() -> void:
	_build_empty_slots()
	_connect_signals()

	# ── TEMP: remove when web integration is ready ────────────────────────
	GameState.add_player("Player 1")
	GameState.add_player("Player 2")
	# ─────────────────────────────────────────────────────────────────────


# ─── Setup ────────────────────────────────────────────────────────────────
func _connect_signals() -> void:
	GameState.player_added.connect(_on_player_added)


func _build_empty_slots() -> void:
	for i in MAX_PLAYERS:
		var slot := PLAYER_SLOT_SCENE.instantiate()
		player_grid.add_child(slot)
		slot.set_empty()
		_slots.append(slot)


# ─── Handlers ─────────────────────────────────────────────────────────────
func _on_player_added(player: Dictionary) -> void:
	var index : int = player["id"]
	if index < MAX_PLAYERS:
		_slots[index].setup(player)

	# Auto-start countdown once minimum players have joined
	if GameState.players.size() >= MIN_PLAYERS and not _starting:
		_start_countdown()


# ─── Countdown ────────────────────────────────────────────────────────────
func _start_countdown() -> void:
	_starting  = true
	_countdown = COUNTDOWN_SECONDS

	_timer = Timer.new()
	_timer.wait_time = 1.0
	_timer.timeout.connect(_on_tick)
	add_child(_timer)
	_timer.start()

	_update_countdown_label()


func _on_tick() -> void:
	_countdown -= 1
	_update_countdown_label()

	if _countdown <= 0:
		_timer.stop()
		GameState.start_game()
		get_tree().change_scene_to_file(GAME_SCENE)   


func _update_countdown_label() -> void:
	countdown_label.text = "Comenzando en " + str(_countdown) + "..."
