class_name Bubble extends RigidBody3D


@export_category("References")
@export var animation_player: AnimationPlayer
@export var pop_effect: GPUParticles3D

@export var wobble_strength: float = 0.5
@export var max_lifetime: float = 10.0


var time_alive: float = 0.0


func _ready() -> void:
	if not animation_player:
		return

	freeze = true
	sleeping = true
	contact_monitor = false

	animation_player.play("inflate")
	animation_player.animation_finished.connect(_on_inflate_animation_finished)

	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if freeze:
		return

	time_alive += delta

	if time_alive >= max_lifetime:
		pop()
		return

	var random_direction: Vector3 = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	apply_central_force(random_direction * wobble_strength)


func _on_inflate_animation_finished(_animation_name: String) -> void:
	freeze = false
	sleeping = false
	contact_monitor = true
	max_contacts_reported = 1

	apply_central_impulse(Vector3(0, 0, 0.01))

func _on_body_entered(_body: Node) -> void:
	pop()


func _on_health_component_died() -> void:
	pop()


func pop() -> void:
	pop_effect.global_transform = global_transform
	pop_effect.restart()
	queue_free()
