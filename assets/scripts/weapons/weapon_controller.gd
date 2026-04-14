class_name WeaponController extends Node


signal ammo_changed(new_ammo: int)


@export_category("References")
@export var camera: Camera3D
@export var weapon_model_parent: Node3D
@export var weapon_state_chart: StateChart


const MAX_PROJECTILE_DISTANCE: float = 1000.0
const WEAPON_GROUP: String = "weapons"


var current_ammo: int = 0
var weapon: Weapon
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

	if weapon.weapon_scene:
		weapon_model = weapon.weapon_scene.instantiate()
		weapon_model_parent.add_child(weapon_model)
		weapon_model.add_to_group(WEAPON_GROUP)
		weapon_model.position = weapon.weapon_position


func switch_weapon(weapon_data: WeaponData) -> void:
	weapon = weapon_data.weapon
	set_ammo(weapon_data.ammo)
	spawn_weapon_model()


func has_ammo() -> bool:
	return current_ammo > 0


func set_ammo(ammo: int) -> void:
	current_ammo = ammo
	ammo_changed.emit(current_ammo)


func can_fire() -> bool:
	return has_ammo() and can_fire_next


func fire_weapon() -> void:
	if not can_fire():
		return

	set_ammo(current_ammo - 1)

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

		if result:
			var hit_position: Vector3 = result.position
			var hit_target: Node3D = result.collider
			WeaponHelpers.spawn_impact_marker(get_tree(), hit_position)
			WeaponHelpers.apply_damage_to_target(weapon.damage, hit_target, owner)


func _spawn_projectile() -> void:
	if not weapon.projectile_scene:
		push_error("Missing projectile scene assigned.")
		return

	if not camera:
		push_error("Missing camera for projectile firing.")
		return

	var projectile: Projectile = weapon.projectile_scene.instantiate()
	weapon_model.add_child(projectile)

	# Offset for weapon muzzle position
	projectile.position.z = weapon.weapon_position.z

	# Intersect the target position
	var viewport_center: Vector2 = get_viewport().get_visible_rect().size * 0.5
	var ray_origin: Vector3 = camera.project_ray_origin(viewport_center)
	var ray_normal: Vector3 = camera.project_ray_normal(viewport_center)
	var ray_end: Vector3 = ray_origin + ray_normal * MAX_PROJECTILE_DISTANCE

	# Perform raycast to find target point
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(query)
	var target_position: Vector3 = result.position if result else ray_end
	projectile.look_at(target_position)

	var accuracy_spread: Vector3 = WeaponHelpers.get_random_accuracy_spread(weapon)
	var direction: Vector3 = (target_position - projectile.global_position).normalized() + accuracy_spread

	var velocity: Vector3 = direction * weapon.projectile_speed
	projectile.setup(velocity, weapon.damage)
