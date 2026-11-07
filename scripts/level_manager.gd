extends Node

signal level_completed(level_index: int)
signal all_levels_completed

const LEVELS_FOLDER := "res://levels/"

var level_paths: Array[String] = []
var current_level_index: int = -1

func _ready() -> void:
	_discover_levels()
	var current_scene_path := get_tree().current_scene.scene_file_path
	current_level_index = level_paths.find(current_scene_path)

func _discover_levels() -> void:
	level_paths.clear()
	var dir := DirAccess.open(LEVELS_FOLDER)
	if dir == null:
		push_error("LevelManager: couldn't open %s" % LEVELS_FOLDER)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			level_paths.append(LEVELS_FOLDER + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	level_paths.sort()  #(level_01, level_02, etc...)

func complete_level() -> void:
	level_completed.emit(current_level_index)
	print("Level %d complete!" % current_level_index)
	go_to_next_level()

func go_to_next_level() -> void:
	current_level_index += 1
	if current_level_index < level_paths.size():
		get_tree().change_scene_to_file(level_paths[current_level_index])
	else:
		all_levels_completed.emit()
		print("All levels complete!")
		# e.g. get_tree().change_scene_to_file("res://ui/end_screen.tscn")

func restart_current_level() -> void:
	get_tree().reload_current_scene()

func go_to_level(index: int) -> void:
	if index >= 0 and index < level_paths.size():
		current_level_index = index
		get_tree().change_scene_to_file(level_paths[index])
