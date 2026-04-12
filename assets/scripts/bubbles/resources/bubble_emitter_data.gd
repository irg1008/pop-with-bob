class_name BubbleEmitterData extends Resource


@export_category("Bubble Emitter Settings")
@export var bubble: BubbleData
@export var max_current: int = 5
@export var emit_rate: float = 0.2
@export var max_lifetime: float = 0.0


func _init() -> void:
  resource_local_to_scene = true