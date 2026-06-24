extends State

var can_transition = false
var dash_speed = 300
var dash_duration = 0.5
var dash_damage = 12

func enter():
	.enter()
	print("Dash state entered!")
	
	# Get boss-specific values
	if owner and "dash_damage" in owner:
		dash_damage = owner.dash_damage
	
	can_transition = false
	
	if animation_player and animation_player.has_animation("glowing"):
		animation_player.play("glowing")
	
	# Perform dash
	var dash_direction = (player.global_position - owner.global_position).normalized()
	var target_position = owner.global_position + dash_direction * 100  # Dash 100 pixels toward player
	
	# Create tween for dash
	var tween = Tween.new()
	owner.add_child(tween)
	
	tween.interpolate_property(owner, "global_position", 
		owner.global_position, target_position, dash_duration, 
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	
	# Check for collision during dash
	check_dash_collision(dash_direction)
	
	yield(tween, "tween_all_completed")
	
	if is_instance_valid(tween):
		tween.queue_free()
	
	can_transition = true

func check_dash_collision(dash_direction):
	# Simple collision check - you might want to use raycasting instead
	if player and owner:
		var distance = owner.global_position.distance_to(player.global_position)
		if distance < 80:  # If player is close during dash
			print("BOSS HIT PLAYER WITH DASH!")
			if player.has_method("take_damage"):
				player.take_damage(dash_damage, dash_direction, 80)

func transition():
	if can_transition:
		can_transition = false
		print("Dash finished, returning to Follow")
		get_parent().change_state("Follow")
