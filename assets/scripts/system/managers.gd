extends Node


var weapon_manager: WeaponManager
var progress_manager: ProgressManager
var game_manager: GameManager


func _ready() -> void:
	find_managers.call_deferred()


func find_managers() -> void:
	weapon_manager = get_tree().get_first_node_in_group(WeaponManager.WEAPON_MANAGER_GROUP)
	progress_manager = get_tree().get_first_node_in_group(ProgressManager.PROGRESS_MANAGER_GROUP)
	game_manager = get_tree().get_first_node_in_group(GameManager.GAME_MANAGER_GROUP)


func is_input_locked() -> bool:
	return game_manager and game_manager.input_locked