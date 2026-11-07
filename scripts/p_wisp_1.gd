extends CharacterBody2D

const WHISP_SPEED = 250.0
const WHISP_ACCEL = 10.0
const GRAB_OFFSET = Vector2(0, 0)
const STRING_STIFFNESS = 40.0
const STRING_DAMPING = 8.0

@export var body_node_path: NodePath

@onready var meet_area: Area2D = $MeetArea
@onready var grab_area: Area2D = $GrabArea

var is_possession_active: bool = false
var held_cube: RigidBody2D = null

func _ready() -> void:
	meet_area.body_entered.connect(_on_meet_area_body_entered)

func _physics_process(delta: float) -> void:
	# Handle possession
	if not is_possession_active:
		return  
	#Handles grabbing
	if Input.is_action_just_pressed("grab"): 
		_toggle_grab()

	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = velocity.lerp(direction * WHISP_SPEED, WHISP_ACCEL * delta)
	move_and_slide()
	if held_cube:  
		_update_string_pull()

#invisible string for pulling
func _update_string_pull() -> void: 
	var target_position := global_position + GRAB_OFFSET
	var to_target := target_position - held_cube.global_position
	var spring_force := to_target * STRING_STIFFNESS
	var damping_force := -held_cube.linear_velocity * STRING_DAMPING
	held_cube.apply_central_force(spring_force + damping_force)

#function for the grabbing
func _toggle_grab() -> void:
	if held_cube:
		held_cube.drop(held_cube.linear_velocity)
		held_cube = null
	else:
		for body in grab_area.get_overlapping_bodies():
			if body.is_in_group("grabbable") and body.has_method("pick_up"):
				held_cube = body
				held_cube.pick_up()
				break

func _on_meet_area_body_entered(body: Node) -> void:
	if body == get_node("../p-body-1"):
		LevelManager.complete_level()
		
func shift_form():
	if held_cube:  
		held_cube.drop()  
		held_cube = null
	var target := get_node(body_node_path) if body_node_path != NodePath("") else get_node("../p-body-1")
	PossessionManager.shift_to(target)

func activate(camera_ref: Camera2D) -> void:
	is_possession_active = true
	var old_parent = camera_ref.get_parent()
	if old_parent:
		old_parent.remove_child(camera_ref)
	add_child(camera_ref)
	camera_ref.make_current()
	
func deactivate() -> void:
	is_possession_active = false
	velocity = Vector2.ZERO
	if held_cube:
		held_cube.drop()
		held_cube = null
