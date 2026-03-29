class_name WeaponController extends Node


@export var current_weapon: Weapon
@export var weapon_mode_parent: Node3D


var current_weapon_model: Node3D


func _ready() -> void:
	if current_weapon:
		spawn_weapon_model()


func spawn_weapon_model() -> void:
	if current_weapon_model:
		current_weapon_model.queue_free()

	if current_weapon.weapon_model:
		current_weapon_model = current_weapon.weapon_model.instantiate()
		weapon_mode_parent.add_child(current_weapon_model)
		current_weapon_model.position = current_weapon.weapon_position