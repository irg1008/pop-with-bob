extends Node3D

@export var bubble_prefab: PackedScene
@export var release_forward_impulse: float = 3.0
@export var release_upward_impulse: float = 1.0

var current_bubble: RigidBody3D = null

func _input(event: InputEvent) -> void:
	# Press 'Enter/Accept' to BLOW
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		create_giant_bubble()
		return
	
	# Press 'Space' to POP
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		if is_instance_valid(current_bubble) and current_bubble.has_method("pop"):
			current_bubble.call("pop")
				
func create_giant_bubble() -> void:
	if bubble_prefab == null:
		push_warning("BubbleEmitter: bubble_prefab is not assigned.")
		return

	if is_instance_valid(current_bubble):
		current_bubble.queue_free()
		current_bubble = null

	var spawned_bubble := bubble_prefab.instantiate()
	if not (spawned_bubble is RigidBody3D):
		push_error("BubbleEmitter: bubble_prefab must instantiate a RigidBody3D.")
		if spawned_bubble:
			spawned_bubble.queue_free()
		return

	current_bubble = spawned_bubble as RigidBody3D
	# Match the first animation key to avoid a visible shape jump on spawn.
	current_bubble.scale = Vector3(0.02, 0.09, 0.09)
	current_bubble.global_transform = global_transform

	var parent_node := _get_spawn_parent()
	parent_node.add_child(current_bubble)

	var forward := global_transform.basis.x.normalized()
	var release_impulse := (forward * release_forward_impulse) + (Vector3.UP * release_upward_impulse)

	if current_bubble.has_method("play_blow_animation"):
		current_bubble.call("play_blow_animation", release_impulse)
	else:
		_fallback_release_bubble(release_impulse)


func _get_spawn_parent() -> Node:
	var parent_node: Node = get_tree().current_scene
	if parent_node == null:
		parent_node = get_tree().root
	return parent_node


func _fallback_release_bubble(release_impulse: Vector3) -> void:
	if not is_instance_valid(current_bubble):
		return

	if current_bubble.has_method("start_blow_phase"):
		current_bubble.call("start_blow_phase")

	current_bubble.scale = Vector3(2.58, 2.58, 2.58)
	if current_bubble.has_method("release_after_blow"):
		current_bubble.call("release_after_blow")
	else:
		current_bubble.freeze = false

	current_bubble.apply_central_impulse(release_impulse)
