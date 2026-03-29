class_name WeaponStateMachine extends Node


@export var weapon_controller: WeaponController



func _ready() -> void:
	setup_children_controller()


func setup_children_controller() -> void:
	if not weapon_controller:
		push_error("WeaponStateMachine needs a reference to the WeaponController")
		return

	for state: WeaponState in find_children("*", "WeaponState", true, false):
			state.weapon_controller = weapon_controller