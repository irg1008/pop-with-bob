class_name CharacterBubbleEmitter extends SmoothStairsCharacter3D


@export_category("Movement Settings")
@export var move_speed: float = 1.5
@export var acceleration: float = 2.0
@export var deceleration: float = 1.0
@export var turn_smoothness: float = 2.0
@export_group("Weight")
@export var weight: float = 0.2
@export_group("Roaming")
@export var roam_radius: float = 40.0
@export var min_roam_distance: float = 10.0

@export_category("Soaps")
@export var initial_max_soaps: int = 4
@export var initial_soaps: Array[StoreSoap] = []


@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var state_chart: StateChart = $StateChart
@onready var character_node: Node3D = $Character
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var bubble_emitter: BubbleEmitter = $BubbleEmitter


const CHARACTER_GROUP: String = "characters"


var animation_state: AnimationNodeStateMachinePlayback
var home_position: Vector3

var is_stuck: bool = false
var _stuck_check_timer: Timer
var _stuck_check_position: Vector3

var soaps: Array[StoreSoap] = []: set = set_soaps
var max_soaps: int


func _ready() -> void:
	add_to_group(CHARACTER_GROUP)

	await setup_animation_tree()
	create_stuck_check()

	set_soaps(initial_soaps)

	home_position = global_position

	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.target_position = home_position

	state_chart.send_event("onRoaming")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	smooth_move_and_stair_step()
	update_roaming_blends()


func _on_smooth_step(delta: float, previous_height: float, _height_delta: float) -> void:
	position.y = lerp(previous_height, position.y, 1.0 / weight * delta)


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	var target_velocity: Vector3 = Vector3(safe_velocity.x, velocity.y, safe_velocity.z)
	var accel: float = acceleration if safe_velocity.length() > 0.01 else deceleration
	velocity = velocity.move_toward(target_velocity, accel * get_physics_process_delta_time())


func _on_roaming_state_physics_processing(delta: float) -> void:
	_on_roaming_state_entered()

	if nav_agent.is_navigation_finished():
		_set_new_roam_target()
		return

	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (next_pos - global_position).normalized()

	nav_agent.velocity = direction * move_speed

	if not nav_agent.avoidance_enabled:
		var target_velocity: Vector3 = Vector3(direction.x * move_speed, velocity.y, direction.z * move_speed)
		velocity = velocity.move_toward(target_velocity, acceleration * delta)


	# Face movement direction
	if direction.length() > 0.01:
		var target_rotation: float = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, turn_smoothness * delta)


func _on_roaming_state_entered() -> void:
	if animation_state.get_current_node() != "Roaming":
		animation_state.travel("Roaming")


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


func create_stuck_check() -> void:
	_stuck_check_timer = Timer.new()
	add_child(_stuck_check_timer)
	_stuck_check_timer.wait_time = 1.0
	_stuck_check_timer.start()
	_stuck_check_timer.timeout.connect(_on_stuck_check_timeout)


func _on_stuck_check_timeout() -> void:
	var distance_moved: float = global_position.distance_to(_stuck_check_position)

	is_stuck = distance_moved < 0.1
	_stuck_check_position = global_position

	if is_stuck:
		_set_new_roam_target()


func setup_animation_tree() -> void:
	if not animation_tree.anim_player:
		return

	# Change start position of idle animation
	animation_state = animation_tree.get("parameters/playback")

	await get_tree().process_frame
	animation_tree.set("parameters/Idle/TimeSeek/seek_request", randf_range(0.0, 1.0))


func update_roaming_blends() -> void:
	var move_amount: float = remap(velocity.length(), 0.0, move_speed, 0.0, 1.0)
	animation_tree.set("parameters/Roaming/IdleRoamingBlend/blend_position", move_amount)


func can_add_soap() -> bool:
	return soaps.size() < max_soaps


func reset_modifications() -> void:
	max_soaps = initial_max_soaps

	for soap: StoreSoap in soaps:
		soap.apply_character_mods(self)


func set_soaps(new_soaps: Array[StoreSoap]) -> void:
	soaps = new_soaps

	reset_modifications()

	if bubble_emitter:
		bubble_emitter.soaps = soaps
