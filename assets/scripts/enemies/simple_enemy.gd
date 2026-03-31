class_name SimpleEnemy extends BaseEnemy


@export var move_speed: float = 3.0


@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var state_chart: StateChart = $StateChart
@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_player: AnimationPlayer = $ExampleEnemy/AnimationPlayer


var target: Node3D


func _ready() -> void:
	super._ready()

	target = PlayerController.get_player_node(get_tree())

	health_component.died.connect(_on_died)
	nav_agent.velocity_computed.connect(_on_velocity_computed)

	if animation_player:
		animation_player.play("Zombie_Idle")
		animation_player.seek(randf_range(0.0, animation_player.current_animation_length))


func _on_died() -> void:
	queue_free()


func _on_triggered() -> void:
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
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z


func _on_following_state_physics_processing(delta: float) -> void:
	if not target:
		return

	nav_agent.target_position = target.global_position

	if nav_agent.is_navigation_finished():
		_on_idle_state_entered()
		return

	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (next_pos - global_position).normalized()

	nav_agent.velocity = nav_agent.velocity.move_toward(direction * move_speed, 10.0 * delta)
	_on_following_state_entered()

	# Face the target
	if direction.length() > 0.01:
		var target_rotation: float = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 5.0 * delta)


func _on_following_state_entered() -> void:
		if animation_player and animation_player.current_animation != "Zombie_Walk_Fwd":
			animation_player.play("Zombie_Walk_Fwd")


func _on_idle_state_entered() -> void:
	if animation_player and animation_player.current_animation != "Zombie_Idle":
		animation_player.play("Zombie_Idle")
