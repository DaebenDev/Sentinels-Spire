extends State

var attack_cooldown = 2.0
var time_since_last_attack = 0.0

func enter():
	.enter()
	print("Follow state entered - chasing player!")
	
	# Get boss-specific values
	if owner and "attack_cooldown" in owner:
		attack_cooldown = owner.attack_cooldown
	
	if animation_player and animation_player.has_animation("walk"):
		animation_player.play("walk")
	elif animation_player and animation_player.has_animation("move"):
		animation_player.play("move")
	
	time_since_last_attack = 0.0

func exit():
	.exit()
	print("Exiting Follow state")

func _physics_process(delta):
	if not owner or not player:
		# Try to get player reference again if missing
		if owner and owner.has_method("get_player"):
			player = owner.get_player()
			if not player:
				print("⚠️ Follow: Still no player reference!")
				return
		else:
			print("⚠️ Follow: No owner or get_player method!")
			return
	
	# Calculate direction to player
	owner.direction = player.global_position - owner.global_position
	
	# Update cooldown
	time_since_last_attack += delta
	
	transition()

func transition():
	if not owner or not player:
		return
		
	var distance = owner.direction.length()
	
	# Get boss-specific ranges
	var melee_range = 100.0
	var ranged_min = 120.0
	var ranged_max = 350.0
	
	if owner and "melee_range" in owner:
		melee_range = owner.melee_range
	if owner and "ranged_range_min" in owner:
		ranged_min = owner.ranged_range_min
	if owner and "ranged_range_max" in owner:
		ranged_max = owner.ranged_range_max
	
	# Debug distance info (you can remove this later)
	if Engine.get_frames_drawn() % 60 == 0: # Print once per second
		print("Distance to player: ", distance, " | Cooldown: ", time_since_last_attack, "/", attack_cooldown)
	
	# Check if we can attack (cooldown finished)
	if time_since_last_attack >= attack_cooldown:
		if distance < melee_range:
			print("🎯 Player in melee range, switching to MeleeAttack")
			get_parent().change_state("MeleeAttack")
			time_since_last_attack = 0.0
		elif distance > ranged_min and distance < ranged_max:
			print("🎯 Player at range, choosing ranged attack")
			# Use boss probabilities if available
			var random_attack = choose_ranged_attack()
			get_parent().change_state(random_attack)
			time_since_last_attack = 0.0

func choose_ranged_attack():
	if not owner:
		return "HomingMissle"
	
	# Use boss probabilities if available
	if "dash_probability" in owner and "missile_probability" in owner and "laser_probability" in owner:
		var rand_val = randf()
		var cumulative = 0.0
		
		# Dash probability
		cumulative += owner.dash_probability
		if rand_val <= cumulative:
			return "Dash"
		
		# Missile probability
		cumulative += owner.missile_probability
		if rand_val <= cumulative:
			return "HomingMissle"
		
		# Laser probability (remaining probability)
		return "LaserBeam"
	else:
		# Fallback to random selection
		var attacks = ["HomingMissle", "LaserBeam"]
		return attacks[randi() % attacks.size()]
