class_name SimpleEnemy extends BaseEnemy


@export var move_speed: float = 3.0
@export var acceleration: float = 5.0
@export var deceleration: float = 5.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var state_chart: StateChart = $StateChart
@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_player: AnimationPlayer = $SimpleEnemy/AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree


var target: Node3D
var animation_state: AnimationNodeStateMachinePlayback


func _ready() -> void:
	super._ready()

	health_component.died.connect(_on_died)
	nav_agent.velocity_computed.connect(_on_velocity_computed)

	animation_state = animation_tree.get("parameters/playback")

	await get_tree().process_frame
	animation_tree.set("parameters/Idle/TimeSeek/seek_request", randf_range(0.0, 1.0))


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	update_following_blends()


func _on_died() -> void:
	queue_free()


func _on_triggered() -> void:
	if not target:
		target = PlayerController.get_player_node(get_tree())

	state_chart.send_event("onFollowing")


func _on_navigation_finished() -> void:
	state_chart.send_event("onIdle")


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		_on_triggered()


func _on_detection_area_body_exited(body: Node3D) -> void:
	if body is PlayerController:
		nav_agent.velocity = Vector3.ZERO
		_on_navigation_finished()


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	var target_velocity: Vector3 = Vector3(safe_velocity.x, velocity.y, safe_velocity.z)
	var accel: float = acceleration if safe_velocity.length() > 0.01 else deceleration
	velocity = velocity.move_toward(target_velocity, accel * get_physics_process_delta_time())


func _on_following_state_physics_processing(delta: float) -> void:
	_on_following_state_entered()

	if not target:
		return

	nav_agent.target_position = target.global_position

	if is_meele_range():
		state_chart.send_event("onAttack")
		return

	if nav_agent.is_navigation_finished():
		return

	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (next_pos - global_position).normalized()

	nav_agent.velocity = direction * move_speed

	if not nav_agent.avoidance_enabled:
		var target_velocity: Vector3 = Vector3(direction.x * move_speed, velocity.y, direction.z * move_speed)
		velocity = velocity.move_toward(target_velocity, acceleration * delta)

	# Face the target
	if direction.length() > 0.01:
		var target_rotation: float = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 5.0 * delta)


func _on_following_state_entered() -> void:
		if animation_state.get_current_node() != "Follow":
			animation_state.travel("Follow")


func update_following_blends() -> void:
	var move_amount: float = remap(velocity.length(), 0.0, move_speed, 0.0, 1.0)
	animation_tree.set("parameters/Follow/IdleFollowBlend/blend_position", move_amount)


func is_meele_range() -> bool:
	if not target:
		return false

	var distance: float = global_position.distance_to(target.global_position)
	return distance <= nav_agent.target_desired_distance


func attack() -> void:
	if not target:
		return

	velocity = Vector3.ZERO
	nav_agent.velocity = Vector3.ZERO

	var direction: Vector3 = (target.global_position - global_position).normalized()

	# Face the target
	var target_rotation: float = atan2(direction.x, direction.z)
	rotation.y = target_rotation

	if animation_state.get_current_node() != "Attack":
		animation_state.travel("Attack")
	else:
		animation_state.start("Attack")
	await animation_tree.animation_finished

	if is_meele_range():
		await attack()
		return

	state_chart.send_event("onFollowing")
