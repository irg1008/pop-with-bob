class_name BubbleEmitter extends Node3D


@export_category("Bubble Emitter Settings")
@export var bubble_emitter: BubbleEmitterData


const BUBBLES_ROOT_NODE: String = "BubblesRoot"
const MAX_START_DELAY: float = 2.0


var mod_bubble_emitter: BubbleEmitterData

var current_bubbles: int = 0
var _emit_timer: Timer

var soaps: Array[StoreSoap] = []: set = set_soaps


func _ready() -> void:
		mod_bubble_emitter = bubble_emitter.duplicate()
		mod_bubble_emitter.bubble = bubble_emitter.bubble.duplicate()

		await start_emit_timer()


func start_emit_timer() -> void:
		if not mod_bubble_emitter:
			return

		var start_delay: float = randf_range(0, 2.0)
		await get_tree().create_timer(start_delay).timeout

		_emit_timer = Timer.new()
		add_child(_emit_timer)

		_emit_timer.wait_time = 1.0 / mod_bubble_emitter.emit_rate
		_emit_timer.start()
		_emit_timer.timeout.connect(emit_bubble)


func emit_bubble() -> void:
		if not mod_bubble_emitter or not can_emit():
			return

		var bubble_scene: PackedScene = mod_bubble_emitter.bubble.scene
		var bubble_reward: int = mod_bubble_emitter.bubble.reward

		# Check for gold bubble
		if mod_bubble_emitter.bubble.gold_scene:
			var gold_prob: float = mod_bubble_emitter.bubble.gold_probability / 100.0

			if randf() < gold_prob:
				bubble_scene = mod_bubble_emitter.bubble.gold_scene
				bubble_reward = mod_bubble_emitter.bubble.gold_reward

		var bubble_instance: Bubble = bubble_scene.instantiate()
		bubble_instance.max_lifetime = mod_bubble_emitter.max_lifetime

		apply_bubble_mods(bubble_instance)

		add_child(bubble_instance)
		bubble_instance.global_transform = global_transform

		current_bubbles += 1

		var on_bubble_popped: Callable = _on_bubble_popped.bind(bubble_reward)
		bubble_instance.popped.connect(on_bubble_popped)


func can_emit() -> bool:
	return current_bubbles < mod_bubble_emitter.max_current


func _on_bubble_popped(reward: float) -> void:
	current_bubbles = max(0, current_bubbles - 1)
	Managers.progress_manager.add_coins(reward)
	apply_pop_mods()


func apply_pop_mods() -> void:
	for i: int in range(soaps.size()):
		var prev_soap: StoreSoap = soaps[i - 1] if i > 0 else null
		var soap: StoreSoap = soaps[i]
		soap.apply_pop_mods(prev_soap)


func apply_bubble_mods(bubble: Bubble) -> void:
	for soap: StoreSoap in soaps:
		soap.apply_bubble_mods(bubble)


func set_soaps(new_soaps: Array[StoreSoap]) -> void:
	soaps = new_soaps

	for soap: StoreSoap in soaps:
		soap.apply_emitter_data_mods(mod_bubble_emitter)
		soap.apply_bubble_data_mods(mod_bubble_emitter.bubble)
