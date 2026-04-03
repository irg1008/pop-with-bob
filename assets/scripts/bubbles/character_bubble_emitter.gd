class_name CharacterBubbleEmitter extends SmoothStairsCharacter3D


@export_category("Movement Settings")
@export var move_speed: float = 1.0
@export_group("Roaming")
@export var roam_radius: float = 20.0
@export var min_roam_distance: float = 5.0
@export_group("Movement Smoothing")
@export var steering_smoothness: float = 2.0
@export var turn_smoothness: float = 4.0
@export_group("Animations")
@export var states_enabled: bool = true
@export var animation_blend: float = 0.2
@export var walk_animation: String = "Walk"
@export var stuck_animation: String = "No"
@export var idle_animation: String


@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var state_chart: StateChart = $StateChart
@onready var character_node: Node3D = $Character


var animation_player: AnimationPlayer

var home_position: Vector3
var _smoothed_move_direction: Vector3 = Vector3.FORWARD

var is_stuck: bool = false
var _stuck_check_timer: Timer
var _stuck_check_position: Vector3


func _ready() -> void:
	load_character()
	create_stuck_check()

	home_position = global_position

	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.target_position = home_position


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	smooth_move_and_stair_step()


func _on_smooth_step(delta: float, previous_height: float, _height_delta: float) -> void:
	position.y = lerp(previous_height, position.y, 8.0 * delta)


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z


func _on_roaming_state_physics_processing(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		state_chart.send_event("onIdle")
		_set_new_roam_target()
		return

	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var desired_direction: Vector3 = (next_pos - global_position).normalized()

	if desired_direction.length() > 0.001:
		_smoothed_move_direction = _smoothed_move_direction.slerp(desired_direction, steering_smoothness * delta).normalized()

	nav_agent.velocity = nav_agent.velocity.move_toward(_smoothed_move_direction * move_speed, 10.0 * delta)
	_on_roaming_state_entered()

	# Face movement direction
	if _smoothed_move_direction.length() > 0.01:
		var target_rotation: float = atan2(_smoothed_move_direction.x, _smoothed_move_direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, turn_smoothness * delta)


func _on_roaming_state_entered() -> void:
	if animation_player and animation_player.current_animation != walk_animation:
		animation_player.play(walk_animation, animation_blend)


func _on_idle_state_entered() -> void:
	if animation_player and animation_player.has_animation(idle_animation):
		nav_agent.velocity = Vector3.ZERO
		animation_player.play(idle_animation, animation_blend)
		await animation_player.animation_finished

	state_chart.send_event("onRoaming")


func _on_stuck_state_entered() -> void:
	if animation_player and animation_player.has_animation(stuck_animation):
		nav_agent.velocity = Vector3.ZERO
		animation_player.play(stuck_animation, animation_blend)
		await animation_player.animation_finished

	state_chart.send_event("onRoaming")


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


func load_character() -> void:
	var character_animation_player: Node = character_node.find_child("AnimationPlayer", true, false)

	if character_animation_player is AnimationPlayer and character_animation_player.has_animation(walk_animation):
		animation_player = character_animation_player

	if animation_player:
		animation_player.play(walk_animation)
		animation_player.seek(randf_range(0.0, animation_player.current_animation_length))


func create_stuck_check() -> void:
	_stuck_check_timer = Timer.new()
	add_child(_stuck_check_timer)
	_stuck_check_timer.wait_time = 0.5
	_stuck_check_timer.start()
	_stuck_check_timer.timeout.connect(_on_stuck_check_timeout)


func _on_stuck_check_timeout() -> void:
	if animation_player and animation_player.current_animation == idle_animation:
		return

	var distance_moved: float = global_position.distance_to(_stuck_check_position)

	is_stuck = distance_moved < 0.1
	_stuck_check_position = global_position

	if is_stuck:
		_set_new_roam_target()
		state_chart.send_event("onStuck")