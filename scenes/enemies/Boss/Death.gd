extends State

func enter():
	.enter()
	print("💀 Death state entered! Playing death animations sequentially.")
	
	# Focus camera
	var camera = get_viewport().get_camera()
	if camera and camera.has_method("focus_on_boss"):
		camera.focus_on_boss(owner)
	
	# Stop everything
	if owner:
		owner.velocity = Vector2.ZERO
		if owner is KinematicBody2D:
			owner.collision_layer = 0
			owner.collision_mask = 0
	
	if owner and owner.has_node("Hurtbox"):
		owner.get_node("Hurtbox").monitoring = false
	
	# Make sure BossSlained node is visible
	if owner and owner.has_node("BossSlained"):
		owner.get_node("BossSlained").visible = true
	
	# Play animations sequentially
	if animation_player:
		# Play death animation first
		if animation_player.has_animation("death"):
			print("🎬 Playing death animation...")
			animation_player.play("death")
			yield(animation_player, "animation_finished")
			print("✅ Death animation finished")
		
		# Play boss_slained animation second
		if animation_player.has_animation("boss_slained"):
			print("🎬 Playing boss_slained animation...")
			animation_player.play("boss_slained")
			yield(animation_player, "animation_finished")
			print("✅ Boss slained animation finished")
	
	# Return camera and remove boss
	if camera and camera.has_method("return_to_player"):
		camera.return_to_player()
	
	print("💀 Removing boss from scene...")
	if owner:
		owner.queue_free()

func exit():
	.exit()
	print("Exiting Death state")
