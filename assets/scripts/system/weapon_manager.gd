class_name WeaponManager extends Node


@export_category("References")
@export var player: PlayerController

@export_category("Weapon Manager")
@export var weapons: Array[WeaponData] = []


const WEAPON_MANAGER_GROUP: String = "weapon_manager"


var current_weapon: WeaponData


func _ready() -> void:
	add_to_group(WEAPON_MANAGER_GROUP)
	create_input_actions()

	player.weapon_controller.ammo_changed.connect(_on_weapon_controller_ammo_changed)
	initialize_starting_weapon.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	for i: int in range(1, 10):
		var action_name: String = get_slot_action_name(i)

		if event.is_action_pressed(action_name) and (i - 1) < weapons.size():
			switch_weapon(weapons[i - 1])


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
	for weapon_data: WeaponData in weapons:
		if weapon_data.unlocked:
			switch_weapon(weapon_data)
			refill_ammo(weapon_data)
			return


func switch_weapon(weapon_data: WeaponData) -> void:
	if not weapon_data.unlocked:
		return

	current_weapon = weapon_data
	player.weapon_controller.switch_weapon(weapon_data)


func refill_ammo(weapon_data: WeaponData) -> void:
	add_ammo(weapon_data, weapon_data.weapon.max_ammo)


func add_ammo(weapon_data: WeaponData, amount: int) -> void:
	weapon_data.ammo += amount

	if weapon_data == current_weapon:
		player.weapon_controller.set_ammo(weapon_data.ammo)


func unlock_weapon(weapon_data: WeaponData) -> void:
	weapon_data.unlocked = true


func get_weapon_data(weapon: Weapon) -> WeaponData:
	for weapon_data: WeaponData in weapons:
		if weapon_data.weapon == weapon:
			return weapon_data

	return null


func _on_weapon_controller_ammo_changed(ammo: int) -> void:
	if current_weapon:
		current_weapon.ammo = ammo