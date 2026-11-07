extends Node

var current_body: Node = null
var shared_camera: Camera2D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shift") and current_body and current_body.has_method("shift_form"):
		current_body.shift_form()
		get_viewport().set_input_as_handled()
		
func shift_to(new_body: Node) -> void:
	if current_body and current_body.has_method("deactivate"):
		current_body.deactivate()
	current_body = new_body
	if new_body.has_method("activate"):
		new_body.activate(shared_camera)
