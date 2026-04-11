class_name PlayerController extends SmoothStairsCharacter3D


signal interaction_entered(object: Object, object_owner: Object)
signal interaction_exited(object: Object, object_owner: Object)
signal interaction_actioned(object: Object, object_owner: Object)


@export_category("References")
@export var camera: CameraController
@export var camera_effects: CameraEffects
@export var state_chart: StateChart
@export var standing_collision: CollisionShape3D
@export var crouching_collision: CollisionShape3D
@export var crouch_check: ShapeCast3D
@export var interaction_raycast: RayCast3D
@export var weapon_controller: WeaponController
@export var health_component: HealthComponent

@export_category("Movement Settings")
@export_group("Easing")
@export var acceleration: float = 0.2
@export var deceleration: float = 0.5
@export_group("Speed")
@export var base_speed: float = 4.0
@export var sprint_speed: float = 2.0
@export var crouch_speed: float = -2.0

@export_category("Jump Settings")
@export var jump_velocity: float = 5.0
@export var fall_velocity_threhold: float = -5.0


const PLAYER_GROUP: String = "player"


var input_dir: Vector2 = Vector2.ZERO

var _sprint_modifier: float = 0.0
var _crouch_modifier: float = 0.0

var _current_fall_speed: float = 0.0
var _current_interaction: Object


func _ready() -> void:
	add_to_group(PLAYER_GROUP)


func _physics_process(delta: float) -> void:
	detect_interaction()

	if not is_on_floor():
		velocity += get_gravity() * delta

	var speed_modifier: float = _sprint_modifier + _crouch_modifier
	var speed: float = base_speed + speed_modifier

	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var horizontal_velocity: Vector2 = Vector2(velocity.x, velocity.z)

	if not Managers.is_input_locked() and direction:
		horizontal_velocity = horizontal_velocity.move_toward(Vector2(direction.x, direction.z) * speed, acceleration)
	else:
		horizontal_velocity = horizontal_velocity.move_toward(Vector2.ZERO, deceleration)

	velocity = Vector3(horizontal_velocity.x, velocity.y, horizontal_velocity.y)

	smooth_move_and_stair_step()


func _unhandled_input(event: InputEvent) -> void:
	if _current_interaction and event.is_action_pressed("interact"):
		var interaction_owner: Object = _current_interaction.owner if _current_interaction is Node else null
		interaction_actioned.emit(_current_interaction, interaction_owner)


func detect_interaction() -> Object:
	var new_interaction: Object = interaction_raycast.get_collider()

	if new_interaction == _current_interaction:
		return _current_interaction

	var interaction_owner: Object = new_interaction.owner if new_interaction is Node else null

	if _current_interaction:
		interaction_exited.emit(_current_interaction, interaction_owner)

	if new_interaction:
		interaction_entered.emit(new_interaction, interaction_owner)

	_current_interaction = new_interaction
	return new_interaction


func _on_smooth_step(_delta: float, _previous_height: float, height_delta: float) -> void:
	camera.smooth_step(height_delta)


func sprint() -> void:
	_sprint_modifier = sprint_speed


func walk() -> void:
	_sprint_modifier = 0.0


func crouch() -> void:
	_crouch_modifier = crouch_speed
	standing_collision.disabled = true
	crouching_collision.disabled = false
	collider = crouching_collision.get_path()


func stand() -> void:
	_crouch_modifier = 0.0
	standing_collision.disabled = false
	crouching_collision.disabled = true
	collider = standing_collision.get_path()


func jump() -> void:
	velocity.y += jump_velocity


func update_fall_speed() -> void:
	_current_fall_speed = velocity.y


func check_fall_speed() -> bool:
	var is_falling: bool = _current_fall_speed < fall_velocity_threhold
	_current_fall_speed = 0.0
	return is_falling


static func get_player_node(tree: SceneTree) -> PlayerController:
	return tree.get_first_node_in_group(PLAYER_GROUP)
