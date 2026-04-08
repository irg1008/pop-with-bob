class_name BubbleEmitter extends Node3D


@export_category("Bubble Emitter Settings")
@export var bubble_emitter: BubbleEmitterData


const BUBBLES_ROOT_NODE: String = "BubblesRoot"
const MAX_START_DELAY: float = 2.0


var current_bubbles: int = 0
var _emit_timer: Timer


func _ready() -> void:
		var start_delay: float = randf_range(0, 1.0 / bubble_emitter.emit_rate)
		await get_tree().create_timer(start_delay).timeout

		emit_bubble()
		start_emit_timer()


func start_emit_timer() -> void:
		if bubble_emitter:
			_emit_timer = Timer.new()
			add_child(_emit_timer)

			_emit_timer.wait_time = 1.0 / bubble_emitter.emit_rate
			_emit_timer.start()
			_emit_timer.timeout.connect(emit_bubble)


func emit_bubble() -> void:
		if not bubble_emitter or not can_emit():
			return

		var bubble_scene: PackedScene = bubble_emitter.bubble.scene
		var bubble_reward: int = bubble_emitter.bubble.reward

		# Check for gold bubble
		if bubble_emitter.bubble.gold_scene:
			var gold_prob: float = bubble_emitter.bubble.gold_probability / 100.0
			if randf() < gold_prob:
				print("Emitting gold bubble!")
				bubble_scene = bubble_emitter.bubble.gold_scene
				bubble_reward = bubble_emitter.bubble.gold_reward

		var bubble_instance: Bubble = bubble_scene.instantiate()
		bubble_instance.max_lifetime = bubble_emitter.max_lifetime
		add_child(bubble_instance)
		bubble_instance.global_transform = global_transform

		current_bubbles += 1

		var on_bubble_popped: Callable = _on_bubble_popped.bind(bubble_reward)
		bubble_instance.popped.connect(on_bubble_popped)


func can_emit() -> bool:
	return current_bubbles < bubble_emitter.max_current


func _on_bubble_popped(reward: float) -> void:
	current_bubbles = max(0, current_bubbles - 1)
	Managers.progress_manager.add_coins(reward)
