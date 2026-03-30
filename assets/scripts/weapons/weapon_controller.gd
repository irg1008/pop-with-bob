class_name WeaponController extends Node


@export_category("References")
@export var camera: Camera3D
@export var weapon_mode_parent: Node3D
@export var weapon_state_chart: StateChart

var weapon_data: WeaponData
var weapon: Weapon:
	get: return weapon_data.weapon

var weapon_model: Node3D

var can_fire_next: bool = true
var fire_rate_timer: float = 0.0


func _process(delta: float) -> void:
	if fire_rate_timer > 0:
		fire_rate_timer -= delta
		can_fire_next = fire_rate_timer <= 0


func spawn_weapon_model() -> void:
	if weapon_model:
		weapon_model.queue_free()

	if weapon.weapon_model:
		weapon_model = weapon.weapon_model.instantiate()
		weapon_mode_parent.add_child(weapon_model)
		weapon_model.position = weapon.weapon_position


func switch_weapon(new_weapon_data: WeaponData) -> void:
	weapon_data = new_weapon_data
	spawn_weapon_model()


func has_ammo() -> bool:
	return weapon_data.ammo > 0


func can_fire() -> bool:
	return has_ammo() and can_fire_next


func fire_weapon() -> void:
	if not can_fire():
		return

	weapon_data.ammo -= 1

	# Start fire rate cooldown
	can_fire_next = false
	fire_rate_timer = 1.0 / weapon.fire_rate

	if weapon.is_hitscan:
		_perform_hitscan()
	else:
		_spawn_projectile()


func _perform_hitscan() -> void:
	if not camera:
		push_error("Missing camera for hitscan.")
		return

	var space_state: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
	var from: Vector3 = camera.global_position
	var forward: Vector3 = - camera.global_transform.basis.z

	for i: int in weapon.pellet_count:
		var accuracy_spread: Vector3 = WeaponHelpers.get_random_accuracy_spread(weapon)
		var spread_angle: Vector3 = WeaponHelpers.get_random_spread_angle(weapon)

		var direction: Vector3 = forward + spread_angle + (accuracy_spread * camera.global_transform.basis)
		var to: Vector3 = from + direction * weapon.hitscan_range

		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
		var result: Dictionary = space_state.intersect_ray(query)

		if not result:
			return

		var hit_position: Vector3 = result.position
		WeaponHelpers.spawn_impact_marker(get_tree(), hit_position)


func _spawn_projectile() -> void:
	if not camera:
		push_error("Missing camera for projectile firing.")
		return

	if not weapon.projectile_scene:
		push_error("Missing projectile scene assigned.")
		return

	var projectile: Projectile = weapon.projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_transform = camera.global_transform

	var forward: Vector3 = - camera.global_transform.basis.z
	var spread_direction: Vector3 = WeaponHelpers.get_random_accuracy_spread(weapon)
	var direction: Vector3 = forward + spread_direction * camera.global_transform.basis

	var velocity: Vector3 = direction * weapon.projectile_speed
	projectile.setup(velocity, weapon.damage)
