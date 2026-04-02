class_name CharacterBubbleEmitter extends SmoothStairsCharacter3D


@export_category("Movement Settings")
@export var move_speed: float = 1.5
@export_group("Roaming")
@export var roam_radius: float = 20.0
@export var min_roam_distance: float = 5.0
@export_group("Movement Smoothing")
@export var steering_smoothness: float = 2.5
@export var turn_smoothness: float = 2.0


@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var state_chart: StateChart = $StateChart
@onready var animation_player: AnimationPlayer = $Character/AnimationPlayer


var home_position: Vector3
var smoothed_move_direction: Vector3 = Vector3.FORWARD


func _ready() -> void:
	home_position = global_position

	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.target_position = home_position

	if animation_player:
		animation_player.play("Idle")
		animation_player.seek(randf_range(0.0, animation_player.current_animation_length))


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	smooth_move_and_stair_step()


func _on_smooth_step(previous_height: float, _height_delta: float) -> void:
	var delta: float = get_physics_process_delta_time()
	position.y = lerp(previous_height, position.y, 8.0 * delta)


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z


func _on_roaming_state_physics_processing(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		_on_idle_state_entered()
		_set_new_roam_target()
		return

	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var desired_direction: Vector3 = (next_pos - global_position).normalized()

	if desired_direction.length() > 0.001:
		smoothed_move_direction = smoothed_move_direction.slerp(desired_direction, steering_smoothness * delta).normalized()

	nav_agent.velocity = nav_agent.velocity.move_toward(smoothed_move_direction * move_speed, 10.0 * delta)
	_on_roaming_state_entered()

	# Face movement direction
	if smoothed_move_direction.length() > 0.01:
		var target_rotation: float = atan2(smoothed_move_direction.x, smoothed_move_direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, turn_smoothness * delta)


func _on_roaming_state_entered() -> void:
	print("Entered roaming state")
	if animation_player and animation_player.current_animation != "Walk":
		animation_player.play("Walk")


func _on_idle_state_entered() -> void:
	print("Entered idle state")
	nav_agent.velocity = Vector3.ZERO
	if animation_player and animation_player.current_animation != "Idle":
		animation_player.play("Idle")


func _set_new_roam_target() -> void:
	var random_offset: Vector3 = Vector3(
		randf_range(-roam_radius, roam_radius),
		0.0,
		randf_range(-roam_radius, roam_radius)
	)

	if random_offset.length() < min_roam_distance:
		random_offset = random_offset.normalized() * min_roam_distance

	var desired_point: Vector3 = home_position + random_offset
	var nav_map: RID = nav_agent.get_navigation_map()
	var closest_nav_point: Vector3 = NavigationServer3D.map_get_closest_point(nav_map, desired_point)
	nav_agent.target_position = closest_nav_point
