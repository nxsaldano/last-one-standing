extends Node2D

# ─── Node References ──────────────────────────────────────────────────────
@onready var play_button     : Button = $ContentLayer/MenuSection/PlayButton
@onready var settings_button : Button = $ContentLayer/MenuSection/SettingsButton
@onready var quit_button     : Button = $ContentLayer/MenuSection/QuitButton

# ─── Scene References ─────────────────────────────────────────────────────
const LOBBY_SCENE := "res://scenes/game/lobby/lobby.tscn"

# ─── Lifecycle ────────────────────────────────────────────────────────────
func _ready() -> void:
	_connect_signals()

# ─── Setup ────────────────────────────────────────────────────────────────
func _connect_signals() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

# ─── Handlers ─────────────────────────────────────────────────────────────
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(LOBBY_SCENE)

func _on_settings_pressed() -> void:
	pass  # TODO: implement settings scene

func _on_quit_pressed() -> void:
	get_tree().quit()
