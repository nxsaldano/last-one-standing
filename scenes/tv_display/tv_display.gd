extends Node2D

# ─── Node References ──────────────────────────────────────────────────────
@onready var score_grid          : HBoxContainer = $TopBar/ScoreGrid
@onready var minigame_container  : Node2D        = $MinigameContainer

# ─── Scene References ─────────────────────────────────────────────────────
const PLAYER_SLOT_SCENE    := preload("res://scenes/ui/components/PlayerSlot.tscn")
const LUZ_VERDE_SCENE      := "res://scenes/game/minigames/luz_verde_luz_roja/LuzVerdeLuzRoja.tscn"

# ─── Lifecycle ────────────────────────────────────────────────────────────
func _ready() -> void:
	_build_score_grid()
	_load_minigame(LUZ_VERDE_SCENE)

# ─── Score Grid ───────────────────────────────────────────────────────────
func _build_score_grid() -> void:
	for player in GameState.players:
		var slot := PLAYER_SLOT_SCENE.instantiate()
		score_grid.add_child(slot)
		slot.setup(player)

# ─── Minigame Loading ─────────────────────────────────────────────────────
func _load_minigame(scene_path: String) -> void:
	# Free whatever minigame is currently running
	for child in minigame_container.get_children():
		child.queue_free()

	var minigame : Node = load(scene_path).instantiate()
	minigame_container.add_child(minigame)

# ─── Public ───────────────────────────────────────────────────────────────

# Called by a minigame when it's done
func on_minigame_finished() -> void:
	# TODO: go to point_table scene, then load next minigame
	pass
