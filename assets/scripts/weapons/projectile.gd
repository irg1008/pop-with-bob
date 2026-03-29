class_name Projectile extends Area3D


var velocity: Vector3
var damage: float


# This solution might be improved using a Raycast3D or a ShapeCast3D.
# Current solution might fail to detect collision on high speed projectiles
func _physics_process(delta: float) -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var start_pos: Vector3 = global_position
	var end_pos: Vector3 = global_position + velocity * delta

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(start_pos, end_pos)
	query.collision_mask = 1
	var result: Dictionary = space_state.intersect_ray(query)

	if not result:
		global_position = end_pos
		return

	global_position = result.position
	var collider: Node3D = result.collider
	_on_body_entered(collider)


func _on_body_entered(body: Node3D) -> void:
	print("Projectile hit: %s" % body.name)
	ImpactMarker.spawn_impact_marker(get_tree(), global_position)
	queue_free()


func setup(initial_velocity: Vector3, initial_damage: float) -> void:
	velocity = initial_velocity
	damage = initial_damage
