extends CharacterBody2D

const WHISP_SPEED = 250.0
const WHISP_ACCEL = 10.0

var is_active: bool = false

func _physics_process(delta: float) -> void:
	if not is_active:
		return  # frozen/idle until the player shifts into it

	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = velocity.lerp(direction * WHISP_SPEED, WHISP_ACCEL * delta)
	move_and_slide()

func activate(camera_ref: Camera2D) -> void:
	is_active = true
	var old_parent = camera_ref.get_parent()
	if old_parent:
		old_parent.remove_child(camera_ref)
	add_child(camera_ref)
	camera_ref.make_current()
	
func deactivate() -> void:
	is_active = false
	velocity = Vector2.ZERO
