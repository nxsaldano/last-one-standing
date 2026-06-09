extends Node2D

# ─── Scene References ─────────────────────────────────────────────────────
const MINIGAMES := [
	preload("res://scenes/game/minigames/luz_verde_luz_roja/luz_verde_luz_roja.tscn")
	# add future minigames here
]

const POINT_TABLE_SCENE := "res://scenes/game/point_table/point_table.tscn"

# ─── Internal ─────────────────────────────────────────────────────────────
var _current_index : int = 0


# ─── Lifecycle ────────────────────────────────────────────────────────────
func _ready() -> void:
	_load_minigame()


# ─── Minigame Management ──────────────────────────────────────────────────
func _load_minigame() -> void:
	GameState.snapshot_scores()

	var minigame : Node = MINIGAMES[_current_index].instantiate()
	add_child(minigame)

	# Connect to the signal instead of relying on get_parent()
	minigame.connect("minigame_finished", on_minigame_finished)


# Called by the minigame when it finishes
func on_minigame_finished() -> void:
	get_tree().change_scene_to_file(POINT_TABLE_SCENE)
