extends State

onready var pivot = get_node("../../Pivot") if has_node("../../Pivot") else null
var can_transition = false
var laser_damage = 15
var laser_range = 300.0

func enter():
	.enter()
	print("LaserBeam state entered!")
	
	# Get boss-specific values
	if owner and "laser_damage" in owner:
		laser_damage = owner.laser_damage
	if owner and "laser_range" in owner:
		laser_range = owner.laser_range
	
	can_transition = false
	
	# Set target direction first
	set_target()
	
	# Play animations
	if animation_player:
		if animation_player.has_animation("laser_cast"):
			animation_player.play("laser_cast")
			yield(animation_player, "animation_finished")
		
		if animation_player.has_animation("laser"):
			animation_player.play("laser")
			# Deal damage during laser
			deal_laser_damage()
			yield(animation_player, "animation_finished")
	
	can_transition = true

func set_target():
	if owner and player:
		owner.direction = player.global_position - owner.global_position
		if pivot:
			pivot.rotation = owner.direction.angle()

func deal_laser_damage():
	if player and owner:
		var distance = owner.global_position.distance_to(player.global_position)
		if distance < laser_range:
			print("BOSS HIT PLAYER WITH LASER!")
			if player.has_method("take_damage"):
				var knockback_dir = (player.global_position - owner.global_position).normalized()
				player.take_damage(laser_damage, knockback_dir, 30)

func transition():
	if can_transition:
		can_transition = false
		print("Laser attack finished, returning to Follow")
		get_parent().change_state("Follow")
