extends Node


@export var mob_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI/Retry.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and $UI/Retry.visible:
		# This restarts the current scene.
		get_tree().reload_current_scene()


func _on_mob_timer_timeout() -> void:
	var mob_spawn_location: PathFollow3D = $SpawnPath/SpawnLocation
	mob_spawn_location.progress_ratio = randf()

	var player_position: Vector3 = $Player.position

	var mob: Mob = mob_scene.instantiate()
	if mob is Mob:
		mob.initialize(mob_spawn_location.position, player_position)

		var increase_score: Callable = $UI/ScoreLabel._on_mob_squashed.bind()
		mob.squashed.connect(increase_score)

		add_child(mob)
	else:
		push_error("The mob scene must be of type Mob.")


func _on_player_hit() -> void:
	$MobTimer.stop()
	$UI/Retry.show()
