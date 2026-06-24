extends FiniteStateMachine

var stuck_timer: float = 0.0
var tiny_movement_timer: float = 0.0
const STUCK_THRESHOLD: float = 5.0  # 5 seconds of no movement
const TINY_MOVEMENT_THRESHOLD: float = 10.0  # 10 seconds of tiny movement
const MIN_VELOCITY: float = 1.0  # Minimum velocity to consider movement
const TINY_VELOCITY: float = 5.0  # Threshold for tiny movement

func _init() -> void:
	_add_state("chase")
	_add_state("hurt")
	_add_state("dead")

func _ready() -> void:
	set_state(states.chase)
	var death_timer = Timer.new()
	add_child(death_timer)
	death_timer.name = "DeathTimer"
	death_timer.wait_time = 1.0
	death_timer.one_shot = true
	death_timer.connect("timeout", self, "_on_DeathTimer_timeout")

func _state_logic(delta: float) -> void:
	match state:
		states.chase:
			parent.chase()
			parent.move(delta)
			# Check for stuck conditions
			if parent.velocity.length() < MIN_VELOCITY:
				stuck_timer += delta
				tiny_movement_timer = 0.0  # Reset tiny movement timer
				if stuck_timer >= STUCK_THRESHOLD:
					set_state(states.dead)
			elif parent.velocity.length() < TINY_VELOCITY:
				stuck_timer = 0.0  # Reset stuck timer
				tiny_movement_timer += delta
				if tiny_movement_timer >= TINY_MOVEMENT_THRESHOLD:
					set_state(states.dead)
			else:
				stuck_timer = 0.0
				tiny_movement_timer = 0.0
		states.hurt:
			# Just slide with friction during hurt
			pass
		states.dead:
			# Stop all movement and hide the enemy
			parent.velocity = Vector2.ZERO
			if parent.animated_sprite:
				parent.animated_sprite.visible = true
	
	# Apply friction to all states except dead
	if state != states.dead:
		parent.apply_friction(delta)

func _get_transition() -> int:
	match state:
		states.hurt:
			if not animation_player.is_playing():
				if parent.hp <= 0:
					return states.dead
				return states.chase
		states.dead:
			return -1  # Stay dead forever
	return -1

func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.chase:
			if animation_player and animation_player.has_animation("fly"):
				animation_player.play("fly")
		states.hurt:
			if animation_player and animation_player.has_animation("hurt"):
				animation_player.play("hurt")
		states.dead:
			if parent.animated_sprite and parent.hp <= 0 and animation_player and animation_player.has_animation("dead"):
				animation_player.play("dead")
				$DeathTimer.start()
			elif animation_player and animation_player.has_animation("dead"):  # For stuck condition
				animation_player.play("dead")
				$DeathTimer.start()

func _on_DeathTimer_timeout() -> void:
	parent.queue_free()
