class_name BubbleData extends Resource


@export_category("Bubble Settings")
@export var scene: PackedScene
@export var reward: int = 10
@export var scale: float = 1.0
@export_group("Gold Settings")
@export var gold_scene: PackedScene
@export var gold_reward: int = 20
@export_range(0, 100, 1, "suffix:%") var gold_probability: int = 5
