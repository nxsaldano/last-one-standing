extends VBoxContainer

@onready var avatar     : ColorRect = $Avatar
@onready var name_label : Label     = $NameLabel

# One color per player slot
const AVATAR_COLORS := [
	Color("#E50914"),   # red
	Color("#0071EB"),   # blue
	Color("#F5A623"),   # orange
	Color("#7ED321"),   # green
]

# Called when a real player fills this slot
func setup(player: Dictionary) -> void:
	name_label.text = player["name"]
	avatar.color    = AVATAR_COLORS[player["id"] % AVATAR_COLORS.size()]

# Called on startup, slot is empty
func set_empty() -> void:
	name_label.text = "Esperando..."
	avatar.color    = Color("#333333")
