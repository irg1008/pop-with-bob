extends CharacterBody3D
class_name Player


signal hit

@export var max_speed: int = 14
@export var fall_acceleration: int = 75
@export var jump_impulse: int = 20
@export var bounce_impulse: int = 16

var target_velocity: Vector3 = Vector3.ZERO


func _physics_process(delta: float) -> void:
  var direction: Vector3 = Vector3.ZERO
  direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
  direction.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")

  var strength: float = min(direction.length(), 1.0)

  if direction != Vector3.ZERO:
    direction = direction.normalized()
    $Pivot.basis = Basis.looking_at(direction)
    $AnimationPlayer.speed_scale = strength * 2 + 2
  else:
    $AnimationPlayer.speed_scale = 2

  # Ground Velocity
  var speed: float = max_speed * strength
  target_velocity.x = direction.x * speed
  target_velocity.z = direction.z * speed

  # Vertical Velocity
  if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
    target_velocity.y = target_velocity.y - (fall_acceleration * delta)

  # Iterate through all collisions that occurred this frame
  for index: int in range(get_slide_collision_count()):
    var collision: KinematicCollision3D = get_slide_collision(index)

    var mob: Node = collision.get_collider()
    if mob == null or not mob.is_in_group("mob"):
      continue

    var hit_from_above: bool = Vector3.UP.dot(collision.get_normal()) > 0.2
    if not hit_from_above:
      continue

    if mob is Mob:
      mob.squash()
      target_velocity.y = bounce_impulse
      break

  # Jumping.
  if is_on_floor() and Input.is_action_just_pressed("jump"):
    target_velocity.y = jump_impulse

  # Moving the Character
  velocity = target_velocity
  move_and_slide()

  # Effect on the player when jumping or falling.
  $Pivot.rotation.x = PI / 6 * velocity.y / jump_impulse


func die() -> void:
  hit.emit()
  queue_free()


func _on_mob_detector_body_entered(_body: Node3D) -> void:
  die()
