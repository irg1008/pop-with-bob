class_name BubbleData extends Resource


@export_category("Bubble Settings")
@export var scene: PackedScene
@export var reward: int = 10
@export_group("Gold Settings")
@export var gold_scene: PackedScene
@export var gold_reward: int = 20
@export_range(0, 100, 1, "suffix:%") var gold_probability: int = 5
@export_group("Emitter Settings")
@export var max_current: int = 5
@export var emit_rate: float = 0.2
## Use this to replace bubble emitter model. Consider creating a new emitter for more complex scenarios.
@export var emitter_scene: PackedScene
