extends FiniteStateMachine
class_name PlayerFiniteStateMachine

func _init() -> void:
	_add_state("idle")
	_add_state("move")
	_add_state("hurt")  # Add hurt state for player
	
func _ready() -> void:
	set_state(states.idle)

func _state_logic(delta: float) -> void:
	match state:
		states.idle, states.move:
			parent.get_input()
			parent.move(delta)
		states.hurt:
			# Don't process input during hurt - just slide
			pass
	
	parent.apply_friction(delta)

func _get_transition() -> int:
	match state:
		states.idle:
			if parent.velocity.length() > 10:
				return states.move
		states.move:
			if parent.velocity.length() < 10:
				return states.idle
		states.hurt:
			# Transition after hurt duration instead of animation
			if parent.hurt_timer <= 0:
				if parent.hp <= 0:
					return -2  # Death
				return states.idle
	return -1
func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			if animation_player.has_animation("idle"):
				animation_player.play("idle")
			if parent.has_method("reset_color"):
				parent.reset_color()  # This now has null check inside
		states.move:
			if animation_player.has_animation("run"):
				animation_player.play("run")
		states.hurt:
			# Try to play hurt animation, fall back to idle if not available
			if animation_player.has_animation("hurt"):
				animation_player.play("hurt")
			else:
				# Fallback: Use idle animation briefly
				if animation_player.has_animation("idle"):
					animation_player.play("idle")
					animation_player.seek(0, true)  # Reset to start
					animation_player.playback_speed = 0.5  # Slow for hurt effect
			
			# Apply hurt effect (now safe with null check)
			if parent.has_method("apply_hurt_effect"):
				parent.apply_hurt_effect()
