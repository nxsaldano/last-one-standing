extends Node2D

signal minigame_finished

# ─── Node References ──────────────────────────────────────────────────────
@onready var background_rect : ColorRect      = $BackgroundRect
@onready var young_hee       : Sprite2D       = $YoungHeeImage
@onready var pendulum_arm    : Sprite2D       = $Pendulum/PendulumArm
@onready var status_label    : Label          = $UILayer/StatusLabel
@onready var timer_label     : Label          = $UILayer/TimerLabel
@onready var players_grid    : HBoxContainer  = $UILayer/PlayersGrid
@onready var game_timer      : Timer          = $GameTimer

# ─── Assets ───────────────────────────────────────────────────────────────
const GREEN_IMAGE := preload("res://assets/images/backgrounds/green-young-hee.jpg")
const RED_IMAGE   := preload("res://assets/images/backgrounds/red-young-hee.jpg")

# ─── Constants ────────────────────────────────────────────────────────────
const PENDULUM_SPEED   := 2.0   # radians per second
const PENDULUM_RANGE   := 1.0   # max angle in radians (~57 degrees)
const LUZ_VERDE_TIME   := 3.0   # seconds in green state
const LUZ_ROJA_TIME    := 2.0   # seconds in red state

# ─── Colors ───────────────────────────────────────────────────────────────
const COLOR_GREEN := Color(0.1, 0.6, 0.1)
const COLOR_RED   := Color(0.7, 0.1, 0.1)

# ─── Internal ─────────────────────────────────────────────────────────────
var _time_elapsed   : float = 0.0
var _phase_timer    : float = 0.0
var _is_luz_verde   : bool  = true
var _pendulum_angle : float = 0.0
var _game_running   : bool  = false

# ─── Lifecycle ────────────────────────────────────────────────────────────
func _ready() -> void:
	_build_players_grid()
	_start_countdown()

func _process(delta: float) -> void:
	if not _game_running:
		return

	# Update total time elapsed
	_time_elapsed += delta
	timer_label.text = "%.1f" % max(0.0, 10.0 - _time_elapsed)

	# Swing the pendulum
	_pendulum_angle = sin(_time_elapsed * PENDULUM_SPEED) * PENDULUM_RANGE
	pendulum_arm.rotation = _pendulum_angle

	# Handle phase switching
	_phase_timer += delta
	if _is_luz_verde and _phase_timer >= LUZ_VERDE_TIME:
		_set_luz_roja()
	elif not _is_luz_verde and _phase_timer >= LUZ_ROJA_TIME:
		_set_luz_verde()

# ─── Setup ────────────────────────────────────────────────────────────────
func _build_players_grid() -> void:
	for player in GameState.players:
		var label := Label.new()
		label.text = player["name"]
		players_grid.add_child(label)

# ─── Flow ─────────────────────────────────────────────────────────────────
func _start_countdown() -> void:
	status_label.text = "3"
	await get_tree().create_timer(1.0).timeout
	status_label.text = "2"
	await get_tree().create_timer(1.0).timeout
	status_label.text = "1"
	await get_tree().create_timer(1.0).timeout
	_start_game()

func _start_game() -> void:
	_game_running = true
	game_timer.timeout.connect(_on_game_over)
	game_timer.start()
	_set_luz_verde()

func _set_luz_verde() -> void:
	_is_luz_verde  = true
	_phase_timer   = 0.0
	status_label.text        = "LUZ VERDE"
	background_rect.color    = COLOR_GREEN
	young_hee.texture        = GREEN_IMAGE

func _set_luz_roja() -> void:
	_is_luz_verde  = false
	_phase_timer   = 0.0
	status_label.text        = "LUZ ROJA"
	background_rect.color    = COLOR_RED
	young_hee.texture        = RED_IMAGE

# ─── Handlers ─────────────────────────────────────────────────────────────
func _on_game_over() -> void:
	_game_running = false
	status_label.text = "FIN"
	await get_tree().create_timer(2.0).timeout
	emit_signal("minigame_finished")    # ← signal instead of get_parent()
