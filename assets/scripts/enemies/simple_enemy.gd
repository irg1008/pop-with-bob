class_name SimpleEnemy extends BaseEnemy


@export var move_speed: float = 3.0


@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var state_chart: StateChart = $StateChart
@onready var health_component: HealthComponent = $HealthComponent


var target: Node3D

func _ready() -> void:
	super._ready()

	target = PlayerController.get_player_node(get_tree())

	health_component.died.connect(_on_died)
	nav_agent.velocity_computed.connect(_on_velocity_computed)


func _on_triggered() -> void:
	state_chart.send_event("onFollowing")


func _on_died() -> void:
	queue_free()


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z


func _on_following_state_physics_processing(delta: float) -> void:
	if not target:
		return

	nav_agent.target_position = target.global_position

	var next_pos: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (next_pos - global_position).normalized()

	nav_agent.velocity = direction * move_speed

	# Face the target
	if direction.length() > 0.01:
		var target_rotation: float = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 5.0 * delta)


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		print("Player entered detection area.")
		_on_triggered()


func _on_detection_area_body_exited(body: Node3D) -> void:
	if body is PlayerController:
		print("Player exited detection area.")
		state_chart.send_event("onIdle")
		nav_agent.velocity = Vector3.ZERO
