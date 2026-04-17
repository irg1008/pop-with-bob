class_name PlayerHose extends Node3D


@export var attachment_start: Node3D


@onready var rope: Rope3D = $Rope3D
@onready var interactable_component: InteractableComponent = $HoseNozzle/InteractableComponent
@onready var nozzle: RigidBody3D = $HoseNozzle


var player: PlayerController
var just_picked_up: bool = false


func _ready() -> void:
	if attachment_start:
		rope.attachment_start = attachment_start.get_path()
	rope.anchor_distanced.connect(_on_anchor_distanced)

	interactable_component.picked_up.connect(_on_interactable_component_picked_up)
	interactable_component.dropped.connect(_on_interactable_component_dropped)

	set_player.call_deferred()


func _process(_delta: float) -> void:
	if interactable_component.is_picked_up:
		var target_yaw: float = player.camera.global_rotation.y
		nozzle.global_rotation = Vector3(deg_to_rad(-90), target_yaw, 0)


func set_player() -> void:
	player = PlayerController.get_player_node(get_tree())


func _on_anchor_distanced(offset: Vector3) -> void:
	if just_picked_up:
		await get_tree().create_timer(0.5).timeout
		just_picked_up = false

	if interactable_component.is_picked_up and abs(offset.x) > 1.5:
		interactable_component.drop()


func _on_interactable_component_picked_up() -> void:
	rope.attachment_end = player.camera_pick.get_path()
	just_picked_up = true


func _on_interactable_component_dropped() -> void:
	rope.attachment_end = ""
