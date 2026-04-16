class_name PlayerHose extends Node3D


@export var attachment_start: Node3D


@onready var rope: Rope3D = $Rope3D
@onready var interactable_component: InteractableComponent = $HoseNozzle/InteractableComponent
@onready var nozzle: RigidBody3D = $HoseNozzle


# TODO: Make a proper picable nozzle that stays properly at the end of rope. And make a proper handler when picked up.

var player: PlayerController
var picked_up: bool = false


func _ready() -> void:
	if attachment_start:
		rope.attachment_start = attachment_start.get_path()
	rope.anchor_distanced.connect(_on_anchor_distanced)

	interactable_component.actioned.connect(toggle_follow_player)

	set_player.call_deferred()


func _physics_process(_delta: float) -> void:
	if picked_up:
		nozzle.global_rotation.y = player.camera.global_rotation.y - deg_to_rad(180)


func set_player() -> void:
	player = PlayerController.get_player_node(get_tree())


func _on_anchor_distanced(offset: Vector3) -> void:
	if picked_up and abs(offset.x) > 1.0:
		await toggle_follow_player()


func toggle_follow_player() -> void:
	if rope.attachment_end.is_empty():
		rope.attachment_end = player.get_path()
		# nozzle.freeze = true # Freeze physical drooping when explicitly held
		await get_tree().create_timer(0.5).timeout
		picked_up = true
	else:
		rope.attachment_end = ""
		picked_up = false
		# nozzle.freeze = false
