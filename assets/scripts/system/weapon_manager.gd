class_name WeaponManager extends Node


@export_category("References")
@export var player: PlayerController

@export_category("Weapon Manager")
@export var weapons: Dictionary[int, WeaponData] = {}


const WEAPON_MANAGER_GROUP: String = "weapon_manager"


# Starting at 1 to match numeric actions
var current_slot: int = 1


func _ready() -> void:
	add_to_group(WEAPON_MANAGER_GROUP)

	create_input_actions()
	initialize_starting_weapon.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	for i: int in range(1, 10):
		var action_name: String = get_slot_action_name(i)

		if event.is_action_pressed(action_name):
			switch_to_slot(i)


func get_slot_action_name(slot: int) -> String:
	return "weapon_%d" % slot


func create_input_actions() -> void:
	for i: int in range(1, 10):
		var action_name: String = get_slot_action_name(i)
		if InputMap.has_action(action_name):
			continue

		var key_event: InputEventKey = InputEventKey.new()
		key_event.keycode = KEY_1 + (i - 1) as Key

		InputMap.add_action(action_name)
		InputMap.action_add_event(action_name, key_event)


func initialize_starting_weapon() -> void:
	for slot: int in range(1, 10):
		if slot in weapons and weapons[slot].unlocked:
			switch_to_slot(slot)
			return


func switch_to_slot(slot: int) -> void:
		if slot in weapons:
			current_slot = slot
			player.weapon_controller.switch_weapon(weapons[slot])


func get_current_weapon() -> WeaponData:
	return weapons[current_slot]


func use_ammo(amount: int) -> void:
	var current_weapon_data: WeaponData = get_current_weapon()
	current_weapon_data.ammo = max(current_weapon_data.ammo - amount, 0)
