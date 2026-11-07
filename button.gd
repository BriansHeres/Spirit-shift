extends Node2D

signal pressed
signal released

const PRESSED_OFFSET := Vector2(0, 4)
const PRESSED_COLOR := Color(0.75, 0.75, 0.75)
const UNPRESSED_COLOR := Color(1, 1, 1)

@export var required_group: String = "grabbable"

@onready var detection_area: Area2D = $DetectionArea
@onready var mesh: MeshInstance2D = $MeshInstance2D

var unpressed_mesh_position: Vector2
var bodies_on_button: Array = []
var is_pressed: bool = false

func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	unpressed_mesh_position = mesh.position

func _on_body_entered(body: Node) -> void:
	if body.is_in_group(required_group) and body not in bodies_on_button:
		bodies_on_button.append(body)
		_update_state()

func _on_body_exited(body: Node) -> void:
	if body in bodies_on_button:
		bodies_on_button.erase(body)
		_update_state()

func _update_state() -> void:
	var should_be_pressed := bodies_on_button.size() > 0
	if should_be_pressed == is_pressed:
		return
	is_pressed = should_be_pressed
	if is_pressed:
		print("button press")
		mesh.position = unpressed_mesh_position + PRESSED_OFFSET
		mesh.modulate = PRESSED_COLOR
		pressed.emit()
	else:
		print("button released")
		mesh.position = unpressed_mesh_position
		mesh.modulate = UNPRESSED_COLOR
		released.emit()
