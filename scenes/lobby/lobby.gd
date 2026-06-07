extends Node2D

# ─── Node References ──────────────────────────────────────────────────────
@onready var player_grid  : HBoxContainer = $ContentLayer/MainContent/PlayersSection/PlayerGrid
@onready var start_button : Button        = $ContentLayer/BottomBar/StartButton
@onready var back_button  : Button        = $ContentLayer/BottomBar/BackButton

# ─── Scene References ─────────────────────────────────────────────────────
const PLAYER_SLOT_SCENE := preload("res://scenes/ui/components/PlayerSlot.tscn")
const MAIN_MENU_SCENE   := "res://scenes/main_menu/MainMenu.tscn"
const GAME_SCENE        := "res://scenes/game/tv_display/TVDisplay.tscn"

# ─── Constants ────────────────────────────────────────────────────────────
const MAX_PLAYERS := 4
const MIN_PLAYERS := 2

# ─── Internal ─────────────────────────────────────────────────────────────
var _slots : Array = []   # references to the 4 PlayerSlot nodes


# ─── Lifecycle ────────────────────────────────────────────────────────────
func _ready() -> void:
	_build_empty_slots()
	_connect_signals()
	_update_start_button()

	# ── TEMP: remove this block when web integration is ready ──────────────
	GameState.add_player("Player 1")
	GameState.add_player("Player 2")
	# ───────────────────────────────────────────────────────────────────────


# ─── Setup ────────────────────────────────────────────────────────────────
func _connect_signals() -> void:
	back_button.pressed.connect(_on_back_pressed)
	start_button.pressed.connect(_on_start_pressed)

	# Lobby doesn't care HOW a player joined,
	# it just reacts to GameState saying a player was added.
	# When web integration is ready, just call GameState.add_player(name)
	# from there and this will update automatically.
	GameState.player_added.connect(_on_player_added)


func _build_empty_slots() -> void:
	for i in MAX_PLAYERS:
		var slot := PLAYER_SLOT_SCENE.instantiate()
		player_grid.add_child(slot)  # add to tree FIRST
		slot.set_empty()             # THEN call methods on it
		_slots.append(slot)


# ─── Handlers ─────────────────────────────────────────────────────────────
func _on_player_added(player: Dictionary) -> void:
	var index : int = player["id"]
	if index < MAX_PLAYERS:
		_slots[index].setup(player)
	_update_start_button()


func _update_start_button() -> void:
	start_button.disabled = GameState.players.size() < MIN_PLAYERS


func _on_back_pressed() -> void:
	GameState.reset()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _on_start_pressed() -> void:
	GameState.start_game()
	get_tree().change_scene_to_file(GAME_SCENE)
