extends FiniteStateMachine

func _init() -> void:
	_add_state("idle")
	_add_state("chase")
	_add_state("hurt")
	_add_state("dead")
	_add_state("laser_windup")
	_add_state("melee_attack")
	_add_state("dodge")
	_add_state("defense_boost")

func _ready() -> void:
	set_state(states.idle)

func _state_logic(delta: float) -> void:
	match state:
		states.idle, states.chase:
			if parent.player and not parent.is_attacking:
				var distance_to_player = parent.global_position.distance_to(parent.player.global_position)
				if distance_to_player > 100:  # Chase if far
					parent.mov_direction = (parent.player.global_position - parent.global_position).normalized()
				else:  # Stop and prepare attack if close
					parent.mov_direction = Vector2.ZERO
					if state == states.chase:
						set_state(states.idle)
		
		states.dodge:
			# Quick movement away from player
			if parent.player:
				var dodge_direction = (parent.global_position - parent.player.global_position).normalized()
				parent.velocity = dodge_direction * parent.max_speed * 1.5
	
	# Apply friction to all states except specific ones
	if state != states.dodge and state != states.laser_windup and state != states.melee_attack:
		parent.apply_friction(delta)

func _get_transition() -> int:
	match state:
		states.idle:
			if parent.player and parent.global_position.distance_to(parent.player.global_position) > 100:
				return states.chase
			if parent.is_attacking:
				if parent.current_attack == "laser":
					return states.laser_windup
				elif parent.current_attack == "melee":
					return states.melee_attack
		
		states.chase:
			if parent.player and parent.global_position.distance_to(parent.player.global_position) <= 100:
				return states.idle
		
		states.hurt:
			if not animation_player.is_playing():
				if parent.hp <= 0:
					return states.dead
				return states.idle
		
		states.dodge:
			if not animation_player.is_playing():
				return states.idle
		
		states.laser_windup, states.melee_attack:
			if not parent.is_attacking:
				return states.idle
		
		states.defense_boost:
			if not parent.is_defense_boosted:
				return states.idle
		
		states.dead:
			return -1
	
	return -1

func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			if animation_player.has_animation("idle"):
				animation_player.play("idle")
			parent.attack_timer.start()
		
		states.chase:
			if animation_player.has_animation("move"):
				animation_player.play("move")
		
		states.hurt:
			if animation_player.has_animation("hurt"):
				animation_player.play("hurt")
		
		states.dead:
			if animation_player.has_animation("dead"):
				animation_player.play("dead")
			# Handle boss death (drop rewards, etc.)
			parent.handle_boss_death()
		
		states.laser_windup:
			if animation_player.has_animation("laser_windup"):
				animation_player.play("laser_windup")
		
		states.melee_attack:
			if animation_player.has_animation("melee_attack"):
				animation_player.play("melee_attack")
			# Enable hitbox at specific frame (handled in animation)
		
		states.dodge:
			if animation_player.has_animation("dodge"):
				animation_player.play("dodge")
		
		states.defense_boost:
			if animation_player.has_animation("defense_boost"):
				animation_player.play("defense_boost")

func _exit_state(state_exited: int) -> void:
	if state_exited == states.melee_attack:
		parent.disable_melee_hitbox()
