class_name ProgressManager extends Node


signal coins_changed(new_coins: float)
signal water_changed(new_water: float)


const PROGRESS_MANAGER_GROUP: String = "progress_manager"


var current_coins: float = 0.0


func _ready() -> void:
	add_to_group(PROGRESS_MANAGER_GROUP)


func add_coins(reward: float) -> void:
	current_coins += reward
	coins_changed.emit(current_coins)
