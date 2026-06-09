extends PanelContainer

# ─── Node References ──────────────────────────────────────────────────────
@onready var avatar      : ColorRect = $VBoxContainer/Avatar
@onready var name_label  : Label     = $VBoxContainer/NameLabel
@onready var score_label : Label     = $VBoxContainer/ScoreLabel
@onready var delta_label : Label     = $VBoxContainer/DeltaLabel

# ─── Constants ────────────────────────────────────────────────────────────
const AVATAR_COLORS := [
	Color("#E50914"),   # red
	Color("#0071EB"),   # blue
	Color("#F5A623"),   # orange
	Color("#7ED321"),   # green
]

const WIN_COLOR  := Color("#1a3a1a")   # dark green background
const LOSE_COLOR := Color("#3a1a1a")   # dark red background


# ─── Setup ────────────────────────────────────────────────────────────────
func setup(player: Dictionary, delta: int, is_winner: bool) -> void:
	_set_avatar(player)
	_set_score(player, delta)
	_set_highlight(is_winner)


func _set_avatar(player: Dictionary) -> void:
	avatar.color    = AVATAR_COLORS[player["id"] % AVATAR_COLORS.size()]
	name_label.text = player["name"]


func _set_score(player: Dictionary, delta: int) -> void:
	score_label.text = str(player["score"]) + " pts"

	if delta > 0:
		delta_label.text = "+" + str(delta)
		delta_label.add_theme_color_override("font_color", Color("#7ED321"))
	elif delta < 0:
		delta_label.text = str(delta)
		delta_label.add_theme_color_override("font_color", Color("#E50914"))
	else:
		delta_label.text = "±0"
		delta_label.add_theme_color_override("font_color", Color("#888888"))


func _set_highlight(is_winner: bool) -> void:
	var style        := StyleBoxFlat.new()
	style.bg_color    = WIN_COLOR if is_winner else LOSE_COLOR
	style.set_corner_radius_all(8)
	add_theme_stylebox_override("panel", style)
