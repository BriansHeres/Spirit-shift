extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const GROUND_FRICTION = 800.0

@onready var camera: Camera2D = $Camera2D

@export var camera_smoothing_enabled: bool = true
@export var camera_smoothing_speed: float = 5.0
@export var default_zoom: Vector2 = Vector2(1.0, 1.0)
@export var wisp_node_path: NodePath

var shake_strength: float = 0.0
var shake_decay: float = 5.0
var is_possessed_active: bool = true

func _ready() -> void:
	PossessionManager.shared_camera = camera
	PossessionManager.current_body = self
	camera.make_current()
	camera.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	camera.position_smoothing_enabled = camera_smoothing_enabled
	camera.position_smoothing_speed = camera_smoothing_speed
	camera.zoom = default_zoom

func shift_form():
	var target := get_node(wisp_node_path) if wisp_node_path != NodePath("") else get_node("../p-wisp-1")
	PossessionManager.shift_to(target)
	
func activate(camera_ref: Camera2D) -> void:
	is_possessed_active = true
	var old_parent = camera_ref.get_parent()
	if old_parent:
		old_parent.remove_child(camera_ref)
		
	add_child(camera_ref)
	camera_ref.make_current()

func deactivate() -> void:
	is_possessed_active = false

func _physics_process(delta: float) -> void:

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	#Handle Possession
	if is_possessed_active:

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, GROUND_FRICTION * delta)

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
