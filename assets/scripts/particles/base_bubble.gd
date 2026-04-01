class_name BaseBubble extends Node3D


signal popped()


@export_category("References")
@export var animation_player: AnimationPlayer
@export var rigid_body: RigidBody3D
@export var pop_effect: GPUParticles3D

@export_category("Bubble Properties")
@export var max_lifetime: float = 10.0
@export_group("Wobble")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var wobble_enabled: bool = true
@export var wobble_strength: float = 0.5


var time_alive: float = 0.0


func _ready() -> void:
	rigid_body.freeze = true
	rigid_body.sleeping = true
	rigid_body.contact_monitor = false

	animation_player.play("inflate")
	animation_player.animation_finished.connect(_on_inflate_animation_finished)

	rigid_body.body_entered.connect(_on_body_entered)
	pop_effect.finished.connect(_on_pop_effect_finished)


func _physics_process(delta: float) -> void:
	time_alive += delta

	if time_alive >= max_lifetime:
		pop()
		return

	if not rigid_body or rigid_body.freeze:
		return

	var random_direction: Vector3 = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	rigid_body.apply_central_force(random_direction * wobble_strength)


func _on_inflate_animation_finished(_animation_name: String) -> void:
	if not wobble_enabled:
		return

	rigid_body.freeze = false
	rigid_body.sleeping = false
	rigid_body.contact_monitor = true
	rigid_body.max_contacts_reported = 1

	rigid_body.apply_central_impulse(Vector3.FORWARD * 0.01)


func _on_body_entered(_body: Node) -> void:
	pop()


func _on_health_component_died() -> void:
	pop()


func pop() -> void:
	pop_effect.global_position = rigid_body.global_position
	pop_effect.restart()
	popped.emit()
	rigid_body.queue_free()


func _on_pop_effect_finished() -> void:
	queue_free()
