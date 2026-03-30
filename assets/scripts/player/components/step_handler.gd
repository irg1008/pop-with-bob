class_name StepHandlerComponent extends Node


@export_category("References")
@export var player_controller: PlayerController

@export_category("Settings")
@export var surface_threshold: float = 0.3
@export var step_height: float = 0.5


const FEET_ADJUSTED_HEIGHT: float = 0.05
const MIN_STEP_HEIGHT: float = 0.1
const MIN_MOVEMENT_LENGTH: float = 0.1
const MIN_DOT_VALUE: float = 0.5


func handle_step_climbing() -> void:
	for i: int in player_controller.get_slide_collision_count():
		var collision: KinematicCollision3D = player_controller.get_slide_collision(i)

		if _is_vertical_surface(collision):
			var measured_height: float = _measure_step_height(collision)
			var is_step: bool = measured_height > MIN_STEP_HEIGHT and measured_height <= step_height

			if is_step and _is_valid_step_direction(collision):
				player_controller.global_position.y += measured_height
				player_controller.velocity = player_controller.previous_velocity
				player_controller.camera.smooth_step(measured_height)


func handle_step_down() -> void:
	# Ignore if the player is jumping or moving upward
	if player_controller.velocity.y > 0.0:
		return

	var space_state: PhysicsDirectSpaceState3D = player_controller.get_world_3d().direct_space_state
	var player_feet: Vector3 = _get_player_feet_position()
	
	var ray_start: Vector3 = player_feet
	var ray_end: Vector3 = player_feet - Vector3(0, step_height, 0)
	
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.collision_mask = player_controller.collision_mask
	query.exclude = [player_controller.get_rid()]
	
	var result: Dictionary = space_state.intersect_ray(query)
	
	if not result:
		return
	
	var drop_distance: float = player_feet.y - result.position.y
	var is_drop = drop_distance > MIN_STEP_HEIGHT and drop_distance <= step_height
	
	# Snap the player down if the floor is within the step_height limit
	if is_drop:
		player_controller.global_position.y -= drop_distance
		player_controller.velocity = player_controller.previous_velocity
		player_controller.camera.smooth_step(drop_distance)


func _is_vertical_surface(collision: KinematicCollision3D) -> bool:
	var normal: Vector3 = collision.get_normal()
	var is_vertical: bool = abs(normal.y) <= surface_threshold
	return is_vertical or _check_collision_surface(collision)


func _get_player_feet_position() -> Vector3:
	var feet_pos: Vector3 = player_controller.global_position
	feet_pos.y -= player_controller.standing_collision.shape.height / 2
	feet_pos.y += FEET_ADJUSTED_HEIGHT
	return feet_pos


func _check_collision_surface(collision: KinematicCollision3D) -> bool:
	var space_state: PhysicsDirectSpaceState3D = player_controller.get_world_3d().direct_space_state
	var collision_point: Vector3 = collision.get_position()

	var player_feet: Vector3 = _get_player_feet_position()
	collision_point.y = player_feet.y

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(player_feet, collision_point)
	query.collision_mask = player_controller.collision_mask
	query.exclude = [player_controller.get_rid()]

	var result: Dictionary = space_state.intersect_ray(query)
	var is_vertical: bool = result and abs(result.normal.y) <= surface_threshold

	return is_vertical


func _measure_step_height(collision: KinematicCollision3D) -> float:
	var space_state: PhysicsDirectSpaceState3D = player_controller.get_world_3d().direct_space_state
	var collision_point: Vector3 = collision.get_position()

	var player_feet: Vector3 = _get_player_feet_position()
	var player_head_y: float = player_controller.global_position.y + player_controller.standing_collision.shape.height / 2

	var ray_start: Vector3 = Vector3(collision_point.x, player_head_y, collision_point.z)
	var ray_end: Vector3 = Vector3(collision_point.x, player_feet.y, collision_point.z)

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.collision_mask = player_controller.collision_mask
	query.exclude = [player_controller.get_rid()]

	var result: Dictionary = space_state.intersect_ray(query)
	if result:
		return result.position.y - player_feet.y

	return 0.0


func _is_valid_step_direction(collision: KinematicCollision3D) -> bool:
	var collision_normal: Vector3 = collision.get_normal()
	var input_dir: Vector2 = player_controller.get_input_direction()
	var movement_direction: Vector3 = player_controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)

	if movement_direction.length() < MIN_MOVEMENT_LENGTH:
		return false

	movement_direction = movement_direction.normalized()
	var dot_product: float = movement_direction.dot(-collision_normal)
	return dot_product > MIN_DOT_VALUE
