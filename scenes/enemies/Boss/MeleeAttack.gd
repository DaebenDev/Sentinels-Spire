extends State

var attack_duration = 1.0
var attack_timer = 0.0
var can_transition = false
var attack_damage = 10

func enter():
	.enter()
	print("MeleeAttack state entered!")
	
	# Get boss-specific damage
	if owner and "melee_damage" in owner:
		attack_damage = owner.melee_damage
	
	attack_timer = 0.0
	can_transition = false
	
	if animation_player and animation_player.has_animation("melee_attack"):
		animation_player.play("melee_attack")
		# Start dealing damage immediately
		deal_melee_damage()
	else:
		# If no animation, just do the attack quickly
		deal_melee_damage()
		can_transition = true

func exit():
	.exit()
	print("Exiting MeleeAttack state")

func _physics_process(delta):
	if not can_transition:
		attack_timer += delta
		if attack_timer >= attack_duration:
			can_transition = true
	
	transition()

func transition():
	if can_transition:
		can_transition = false
		print("Melee attack finished, returning to Follow")
		get_parent().change_state("Follow")

func deal_melee_damage():
	if player and owner:
		var distance = owner.global_position.distance_to(player.global_position)
		var melee_range = 100.0
		if owner and "melee_range" in owner:
			melee_range = owner.melee_range
			
		if distance < melee_range:
			print("BOSS HIT PLAYER WITH MELEE!")
			if player.has_method("take_damage"):
				var knockback_dir = (player.global_position - owner.global_position).normalized()
				player.take_damage(attack_damage, knockback_dir, 50)
