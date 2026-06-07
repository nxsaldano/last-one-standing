extends Node2D

# ─── Node References ──────────────────────────────────────────────────────
@onready var title_label    : Label          = $ContentLayer/TitleLabel
@onready var squid_panel    : PanelContainer = $ContentLayer/HBoxContainer/SquidGamePanel
@onready var stranger_panel : PanelContainer = $ContentLayer/HBoxContainer/StrangerThingsPanel
@onready var sex_ed_panel   : PanelContainer = $ContentLayer/HBoxContainer/SexEducationPanel

# ─── Scene References ─────────────────────────────────────────────────────
const GAME_SCENE := "res://scenes/game/tv_display/TVDisplay.tscn"

# ─── Internal ─────────────────────────────────────────────────────────────
var _panels : Array = []

# ─── Lifecycle ────────────────────────────────────────────────────────────
func _ready() -> void:
	_panels = [squid_panel, stranger_panel, sex_ed_panel]
	_setup_labels()
	_highlight_selected()
	# TEMP: auto-select Squid Game for the demo
	# When voting is ready, replace this with real vote tallying
	GameState.selected_deck = GameState.Deck.SQUID_GAME
	_start_countdown()

# ─── Setup ────────────────────────────────────────────────────────────────
func _setup_labels() -> void:
	squid_panel.get_node("VBoxContainer/DeckNameLabel").text    = "Squid Game"
	stranger_panel.get_node("VBoxContainer/DeckNameLabel").text = "Stranger Things"
	sex_ed_panel.get_node("VBoxContainer/DeckNameLabel").text   = "Sex Education"
	squid_panel.get_node("VBoxContainer/VoteCount").text    = "Seleccionado"
	stranger_panel.get_node("VBoxContainer/VoteCount").text = "Próximamente"
	sex_ed_panel.get_node("VBoxContainer/VoteCount").text   = "Próximamente"

func _highlight_selected() -> void:
	stranger_panel.modulate = Color(1, 1, 1, 0.4)
	sex_ed_panel.modulate   = Color(1, 1, 1, 0.4)

# ─── Flow ─────────────────────────────────────────────────────────────────
func _start_countdown() -> void:
	await get_tree().create_timer(5.0).timeout
	_proceed()

func _proceed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
