extends RigidBody2D

var is_held: bool = false
var original_collision_layer: int
var original_collision_mask: int

func _ready() -> void:
	original_collision_layer = collision_layer
	original_collision_mask = collision_mask

func pick_up() -> void:
	is_held = true

func drop(throw_velocity: Vector2 = Vector2.ZERO) -> void:
	is_held = false
	linear_velocity = throw_velocity
