extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var camera: Camera2D = $Camera2D

# --- Camera tuning ---
@export var camera_smoothing_enabled: bool = true
@export var camera_smoothing_speed: float = 5.0
@export var default_zoom: Vector2 = Vector2(1.0, 1.0)

# --- Screen shake ---
var shake_strength: float = 0.0
var shake_decay: float = 5.0

func _ready() -> void:
	PossessionManager.shared_camera = $p_body_1/Camera2D
	camera.make_current()
	camera.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	camera.position_smoothing_enabled = camera_smoothing_enabled
	camera.position_smoothing_speed = camera_smoothing_speed
	camera.zoom = default_zoom

func shift_form():
	PossessionManager.shift_to(get_node("/root/Test-room-1/p-wisp-1"))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Handle shifting
	if Input.is_action_just_pressed("shift"):
		shift_form()
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _update_camera_shake(delta: float) -> void:
	if shake_strength > 0.0:
		camera.offset = Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		) * shake_strength
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
	else:
		camera.offset = Vector2.ZERO


func add_camera_shake(amount: float) -> void:
	shake_strength = max(shake_strength, amount)


func set_camera_zoom(zoom: Vector2, duration: float = 0.3) -> void:
	var tween := create_tween()
	tween.tween_property(camera, "zoom", zoom, duration)
