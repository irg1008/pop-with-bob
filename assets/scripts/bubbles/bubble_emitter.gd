class_name BubbleEmitter extends Node3D


@export_category("Bubble Emitter Settings")
@export var bubble_emitter: BubbleEmitterData


const BUBBLES_ROOT_NODE: String = "BubblesRoot"


var current_bubbles: int = 0
var emit_timer: Timer


func _ready() -> void:
		emit_bubble()
		start_emit_timer()


func start_emit_timer() -> void:
		if bubble_emitter:
			emit_timer = Timer.new()
			add_child(emit_timer)

			emit_timer.wait_time = 1.0 / bubble_emitter.emit_rate
			emit_timer.start()
			emit_timer.timeout.connect(emit_bubble)


func emit_bubble() -> void:
		if not bubble_emitter or not can_emit():
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
		add_to_root(bubble_instance)
		current_bubbles += 1

		bubble_instance.global_transform = global_transform

		var on_bubble_popped: Callable = _on_bubble_popped.bind(bubble_reward)
		bubble_instance.popped.connect(on_bubble_popped)


func add_to_root(bubble: Bubble) -> void:
	var bubbles_root: Node3D = get_tree().root.get_node_or_null(BUBBLES_ROOT_NODE)

	if not bubbles_root:
		bubbles_root = Node3D.new()
		bubbles_root.name = BUBBLES_ROOT_NODE
		get_tree().root.add_child(bubbles_root)

	bubbles_root.add_child(bubble)


func can_emit() -> bool:
	return current_bubbles < bubble_emitter.max_current


func _on_bubble_popped(_reward: float) -> void:
	current_bubbles = max(0, current_bubbles - 1)
