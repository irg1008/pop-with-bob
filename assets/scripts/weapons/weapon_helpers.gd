class_name WeaponHelpers


const MAX_SPREAD: float = 0.1
const MIN_SPREAD: float = 0.0


static func spawn_impact_marker(tree: SceneTree, position: Vector3) -> void:
		var marker: MeshInstance3D = MeshInstance3D.new()
		var box: BoxMesh = BoxMesh.new()
		box.size = Vector3(0.1, 0.1, 0.1)
		marker.mesh = box

		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = Color.RED
		marker.set_surface_override_material(0, material)

		tree.current_scene.add_child(marker)
		marker.global_position = position

		tree.create_timer(5.0).timeout.connect(marker.queue_free)


static func get_accuracy_spread(accuracy: int) -> float:
	# Inverse relationship
	return remap(accuracy, 0, 100, MAX_SPREAD, MIN_SPREAD)


static func get_random_accuracy_spread(weapon: Weapon) -> Vector3:
	var accuracy_spread: float = get_accuracy_spread(weapon.accuracy)
	var accuracy_spread_x: float = randf_range(-accuracy_spread, accuracy_spread)
	var accuracy_spread_y: float = randf_range(-accuracy_spread, accuracy_spread)
	return Vector3(accuracy_spread_x, accuracy_spread_y, 0)


static func get_random_spread_angle(weapon: Weapon) -> Vector3:
	if weapon.pellet_count <= 1:
		return Vector3.ZERO

	var spread_x: float = randf_range(-weapon.spread_angle, weapon.spread_angle)
	var spread_y: float = randf_range(-weapon.spread_angle, weapon.spread_angle)
	return Vector3(spread_x, spread_y, 0)