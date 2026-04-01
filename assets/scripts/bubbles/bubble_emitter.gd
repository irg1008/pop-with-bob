class_name BubbleEmitter extends Node3D


@export_category("References")
@export var emit_timer: Timer

@export_category("Bubble Emitter Settings")
@export var bubble_emitter: BubbleEmitterData

var current_bubbles: int = 0


func _ready() -> void:
		start_emit_timer()


func start_emit_timer() -> void:
		if bubble_emitter and emit_timer:
			emit_timer.wait_time = 1.0 / bubble_emitter.emit_rate
			emit_timer.start()

			emit_bubble()
			emit_timer.timeout.connect(emit_bubble)


func emit_bubble() -> void:
		if not can_emit() or not bubble_emitter.bubble or not bubble_emitter.bubble.scene:
			return

		var bubble_scene: PackedScene = bubble_emitter.bubble.scene
		var bubble_reward: int = bubble_emitter.bubble.reward

		# Check for gold bubble
		if bubble_emitter.bubble.gold_scene:
			var gold_prob: float = bubble_emitter.bubble.gold_probability / 100.0
			if randf() < gold_prob:
				bubble_scene = bubble_emitter.bubble.gold_scene
				bubble_reward = bubble_emitter.bubble.gold_reward

		var bubble_instance: Bubble = bubble_scene.instantiate()
		add_child(bubble_instance)
		current_bubbles += 1

		# TODO: To test it we will emit it 1.0 meters forward of the emitter. With a proper model this should be changed to emit from the correct position
		bubble_instance.global_transform = global_transform.translated(Vector3(0, 1, -1))

		var on_bubble_popped: Callable = _on_bubble_popped.bind(bubble_reward)
		bubble_instance.popped.connect(on_bubble_popped)


func can_emit() -> bool:
	return current_bubbles < bubble_emitter.max_current


func _on_bubble_popped(_reward: float) -> void:
	current_bubbles = max(0, current_bubbles - 1)
