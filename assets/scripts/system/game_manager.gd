class_name GameManager extends Node


const GAME_MANAGER_GROUP: String = "game_manager"


var input_locked: bool = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_exit"):
		get_tree().quit()
	if event.is_action_pressed("dev_reload"):
		get_tree().reload_current_scene()
		Managers.find_managers.call_deferred()


func _ready() -> void:
	add_to_group(GAME_MANAGER_GROUP)


func lock_input() -> void:
	input_locked = true


func unlock_input() -> void:
	input_locked = false