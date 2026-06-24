extends KinematicBody2D

# Boss Stats - Editable in Inspector
export(int) var max_health = 100
export(int) var base_defense = 0
export(float) var move_speed = 40.0
export(float) var knockback_speed = 200.0

# State Cooldowns - Editable in Inspector
export(float) var attack_cooldown = 2.0
export(float) var dash_cooldown = 3.0
export(float) var missile_cooldown = 4.0
export(float) var laser_cooldown = 5.0
export(float) var armor_buff_cooldown = 10.0

# Attack Ranges - Editable in Inspector
export(float) var detection_range = 400.0
export(float) var melee_range = 100.0
export(float) var ranged_range_min = 120.0
export(float) var ranged_range_max = 350.0
export(float) var laser_range = 300.0

# Attack Probabilities - Editable in Inspector (0.0 to 1.0)
export(float) var dash_probability = 0.3
export(float) var missile_probability = 0.5
export(float) var laser_probability = 0.2

# Attack Damage - Editable in Inspector
export(int) var melee_damage = 10
export(int) var dash_damage = 12
export(int) var missile_damage = 8
export(int) var laser_damage = 15

# Visual Properties
export(Color) var armor_buff_color = Color(0.7, 0.7, 1.0)
export(Color) var hurt_color = Color(1, 0.5, 0.5)

onready var player = null
onready var sprite: Sprite = $Golem
onready var progress_bar = $UI/ProgressBar
onready var state_machine = $FiniteStateMachine

var direction = Vector2()
var velocity = Vector2()
var DEF = base_defense
var health = max_health setget set_health

func _ready():
	add_to_group("boss")
	# Find player with multiple fallbacks
	find_player()
	
	# Initialize health
	health = max_health
	if progress_bar:
		progress_bar.max_value = max_health
		progress_bar.value = health
		progress_bar.visible = true
	
	# Wait a moment then initialize state machine with player reference
	yield(get_tree().create_timer(0.1), "timeout")
	
	# Manually set player reference in all states
	if state_machine:
		for state in state_machine.get_children():
			if "player" in state:
				state.player = player
	
	print("Boss ready. Player found: ", player != null)
	print("State machine found: ", state_machine != null)

# ADD THIS METHOD - provides player reference to states
func get_player():
	return player

func _process(delta):
	# Debug info when pressing SPACE
	if Input.is_action_just_pressed("ui_accept"):
		print("--- BOSS DEBUG INFO ---")
		print("Player: ", player != null)
		if player:
			print("Player name: ", player.name)
			print("Player Position: ", player.position)
			print("Boss Position: ", position)
			print("Distance to player: ", position.distance_to(player.position))
		print("Current State: ", state_machine.current_state.name if state_machine and state_machine.current_state else "null")
		print("Health: ", health)
		print("-----------------------")

func _physics_process(delta):
	if not player:
		find_player()
		return
	
	# Update direction to player for states to use
	direction = player.global_position - global_position
	
	# Flip sprite based on player direction
	handle_facing()
	
	# Only move in Follow state, let other states handle their own movement
	if state_machine and state_machine.current_state and state_machine.current_state.name == "Follow":
		velocity = direction.normalized() * move_speed
		move_and_collide(velocity * delta)

func handle_facing():
	if not player or not sprite:
		return
	
	# Calculate horizontal direction to player
	var player_direction = player.global_position.x - global_position.x
	
	# Flip sprite based on player position using scale
	if player_direction > 0:
		# Player is to the right, face right (normal scale)
		sprite.scale.x = abs(sprite.scale.x)  # Positive scale
	elif player_direction < 0:
		# Player is to the left, face left (flipped scale)
		sprite.scale.x = -abs(sprite.scale.x)  # Negative scale

func find_player():
	# Try multiple ways to find the player
	if get_parent().has_node("KnightBeta"):
		player = get_parent().get_node("KnightBeta")
	elif get_parent().has_node("Character"):
		player = get_parent().get_node("Character")
	elif get_parent().has_node("Knight"):
		player = get_parent().get_node("Knight")
	elif get_tree().get_nodes_in_group("player").size() > 0:
		player = get_tree().get_nodes_in_group("player")[0]
	
	# If still not found, search all nodes
	if not player:
		var nodes = get_tree().get_nodes_in_group("player")
		if nodes.size() > 0:
			player = nodes[0]
	
	# Final fallback - search the entire scene tree
	if not player:
		for node in get_tree().get_nodes_in_group("player"):
			player = node
			break
	
	# If still no player, try to find by name in current scene
	if not player and get_tree().current_scene:
		for child in get_tree().current_scene.get_children():
			if child.is_in_group("player") or child.name == "KnightBeta" or child.name == "Character":
				player = child
				break

func set_health(value):
	health = max(0, value)
	
	if progress_bar:
		progress_bar.value = health

	print("🩸 Boss health: ", health)  # Debug line

	if health <= 0:
		print("💀 Boss health reached 0! Attempting to switch to Death state...")
		if progress_bar:
			progress_bar.visible = false
		
		# Stop all movement
		velocity = Vector2.ZERO
		
		# Disable taking more damage
		if has_node("Hurtbox"):
			$Hurtbox.monitoring = false
		
		# Change to death state
		if state_machine:
			print("✅ State machine found, changing to Death state")
			state_machine.change_state("Death")
		else:
			print("❌ No state machine found!")
			
	elif health <= 50 and DEF == base_defense:  # When health drops below 50%
		DEF = 5
		if state_machine:
			state_machine.change_state("ArmorBuff")

func take_damage(damage, dir, force):
	var actual_damage = max(1, damage - DEF)
	health -= actual_damage
	set_health(health)
	print("Boss took ", actual_damage, " damage. Health: ", health)
	
	# Visual feedback
	if sprite:
		sprite.modulate = hurt_color
		yield(get_tree().create_timer(0.1), "timeout")
		sprite.modulate = Color(1, 1, 1)

func _on_Hurtbox_area_entered(area):
	if area.is_in_group("weapon") or area.name == "Hitbox":
		print("Boss hurtbox hit by weapon!")
		var knockback_dir = (global_position - area.global_position).normalized()
		take_damage(10, knockback_dir, 50)
