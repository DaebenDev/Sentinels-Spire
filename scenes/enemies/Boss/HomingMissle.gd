extends State

export (PackedScene) var bullet_node
var can_transition = false
var missile_damage = 8

func enter():
	.enter()
	print("HomingMissle state entered!")
	
	# Get boss-specific damage
	if owner and "missile_damage" in owner:
		missile_damage = owner.missile_damage
	
	can_transition = false
	
	if animation_player and animation_player.has_animation("ranged_attack"):
		animation_player.play("ranged_attack")
		yield(animation_player, "animation_finished")
	
	shoot()
	
	# Short delay after shooting
	yield(get_tree().create_timer(0.5), "timeout")
	can_transition = true

func shoot():
	if bullet_node:
		var bullet = bullet_node.instance()
		bullet.position = owner.global_position
		bullet.direction = (player.global_position - owner.global_position).normalized() if player else Vector2.RIGHT
		
		# Set bullet damage from boss
		if bullet.has_method("set_damage"):
			bullet.set_damage(missile_damage)
		
		get_tree().current_scene.add_child(bullet)
		print("BOSS FIRED HOMING MISSILE!")
	else:
		print("❌ No bullet scene assigned to HomingMissle state!")

func transition():
	if can_transition:
		can_transition = false
		print("Missile attack finished, returning to Follow")
		get_parent().change_state("Follow")
