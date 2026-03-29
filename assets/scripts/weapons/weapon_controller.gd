class_name WeaponController extends Node


@export_category("References")
@export var camera: Camera3D
@export var weapon_mode_parent: Node3D
@export var weapon_state_chart: StateChart

@export_category("Weapon Settings")
@export var current_weapon: Weapon


var current_weapon_model: Node3D
var current_ammo: int


func _ready() -> void:
	if current_weapon:
		spawn_weapon_model()
		current_ammo = current_weapon.max_ammo


func spawn_weapon_model() -> void:
	if current_weapon_model:
		current_weapon_model.queue_free()

	if current_weapon.weapon_model:
		current_weapon_model = current_weapon.weapon_model.instantiate()
		weapon_mode_parent.add_child(current_weapon_model)
		current_weapon_model.position = current_weapon.weapon_position


func can_fire() -> bool:
	return current_ammo > 0


func fire_weapon() -> void:
	if can_fire():
		current_ammo -= 1
		print("Fired weapon! Remaining ammo: %d" % current_ammo)

		if current_weapon.is_hitscan:
			_perform_hitscan()
		else:
			_spawn_projectile()


func _perform_hitscan() -> void:
	if not camera:
		push_error("Missing camera for hitscan.")
		return

	var space_state: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
	var forward: Vector3 = - camera.global_transform.basis.z

	var from: Vector3 = camera.global_position
	var to: Vector3 = from + forward * current_weapon.hitscan_range

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	var result: Dictionary = space_state.intersect_ray(query)

	if not result:
		return

	var hit_object: Object = result.collider
	var hit_position: Vector3 = result.position

	print("Hit: ", hit_object.name, " at position: ", result.position)
	ImpactMarker.spawn_impact_marker(get_tree(), hit_position)


func _spawn_projectile() -> void:
	if not camera:
		push_error("Missing camera for projectile firing.")
		return

	if not current_weapon.projectile_scene:
		push_error("Missing projectile scene assigned.")
		return

	var projectile: Projectile = current_weapon.projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_transform = camera.global_transform

	var forward: Vector3 = - camera.global_transform.basis.z
	var velocity: Vector3 = forward * current_weapon.projectile_speed

	projectile.setup(velocity, current_weapon.damage)
