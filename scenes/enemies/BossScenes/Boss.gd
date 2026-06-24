extends Character
class_name Boss

# Boss-specific properties
export(int) var boss_max_hp: int = 100
export(int) var laser_damage: int = 2
export(int) var melee_damage: int = 3
export(float) var defense_boost_multiplier: float = 0.5
export(float) var dodge_chance: float = 0.3
export(float) var attack_cooldown: float = 2.0
export(float) var laser_windup: float = 1.0

onready var player: KinematicBody2D = get_tree().current_scene.get_node_or_null("KnightBeta")
onready var laser_hitbox: Area2D = $LaserHitbox
onready var melee_hitbox: Area2D = $MeleeHitbox
onready var attack_timer: Timer = $AttackTimer
onready var defense_timer: Timer = $DefenseTimer
onready var laser_timer: Timer = $LaserTimer

var damage = 10
var is_defense_boosted: bool = false
var original_damage: int = 1
var is_attacking: bool = false
var current_attack: String = ""

func _ready() -> void:
	hp = boss_max_hp
	max_speed = 80  # Slower movement for boss
	acceleration = 150
	original_damage = damage
	
	# Setup timers
	attack_timer.wait_time = attack_cooldown
	attack_timer.connect("timeout", self, "_on_AttackTimer_timeout")
	
	defense_timer.one_shot = true
	defense_timer.connect("timeout", self, "_on_DefenseTimer_timeout")
	
	laser_timer.one_shot = true
	laser_timer.wait_time = laser_windup
	laser_timer.connect("timeout", self, "_on_LaserTimer_timeout")
	
	# Disable hitboxes initially
	if laser_hitbox:
		laser_hitbox.monitoring = false
	if melee_hitbox:
		melee_hitbox.monitoring = false

func _physics_process(delta: float) -> void:
	if hp <= 0 or is_attacking:
		return
	
	move(delta)
	move_and_slide(velocity, FLOOR_NORMAL)
	
	# Face the player
	if player:
		var direction_to_player = (player.global_position - global_position).normalized()
		animated_sprite.flip_h = direction_to_player.x < 0

func take_damage(dam: int, dir: Vector2, force: int) -> void:
	# Chance to dodge
	if randf() < dodge_chance and not is_defense_boosted:
		print("Boss dodged the attack!")
		# Play dodge animation/effect
		if state_machine:
			state_machine.set_state(state_machine.states.dodge)
		return
	
	# Apply defense reduction if boosted
	var actual_damage = dam
	if is_defense_boosted:
		actual_damage = max(1, int(dam * defense_boost_multiplier))
		print("Reduced damage due to defense boost: ", actual_damage)
	
	.take_damage(actual_damage, dir, force)

func activate_defense_boost(duration: float = 5.0) -> void:
	is_defense_boosted = true
	defense_timer.wait_time = duration
	defense_timer.start()
	
	# Visual effect for defense boost
	if animated_sprite:
		animated_sprite.modulate = Color(0.7, 0.7, 1.2)  # Bluish tint
	
	print("Boss defense boosted for ", duration, " seconds")

func _on_AttackTimer_timeout() -> void:
	if hp <= 0 or not player:
		return
	
	# Choose random attack
	var attack_roll = randf()
	if attack_roll < 0.3:  # 30% chance for laser
		start_laser_attack()
	elif attack_roll < 0.6:  # 30% chance for defense boost
		activate_defense_boost()
	else:  # 40% chance for melee
		start_melee_attack()

func start_laser_attack() -> void:
	is_attacking = true
	current_attack = "laser"
	velocity = Vector2.ZERO
	
	# Play laser windup animation
	if state_machine:
		state_machine.set_state(state_machine.states.laser_windup)
	
	laser_timer.start()

func start_melee_attack() -> void:
	is_attacking = true
	current_attack = "melee"
	
	# Play melee attack animation
	if state_machine:
		state_machine.set_state(state_machine.states.melee_attack)

func _on_LaserTimer_timeout() -> void:
	if current_attack == "laser" and laser_hitbox:
		# Enable laser hitbox
		laser_hitbox.monitoring = true
		
		# Visual effect for laser
		if animated_sprite:
			animated_sprite.modulate = Color(1.5, 0.5, 0.5)  # Reddish tint
		
		# Disable laser after brief moment
		yield(get_tree().create_timer(0.5), "timeout")
		laser_hitbox.monitoring = false
		animated_sprite.modulate = Color(1, 1, 1)
		
		end_attack()

func _on_DefenseTimer_timeout() -> void:
	is_defense_boosted = false
	if animated_sprite:
		animated_sprite.modulate = Color(1, 1, 1)
	print("Boss defense boost ended")

func enable_melee_hitbox() -> void:
	if melee_hitbox:
		melee_hitbox.monitoring = true

func disable_melee_hitbox() -> void:
	if melee_hitbox:
		melee_hitbox.monitoring = false

func end_attack() -> void:
	is_attacking = false
	current_attack = ""
	disable_melee_hitbox()
	
	if state_machine:
		state_machine.set_state(state_machine.states.idle)
	
	# Restart attack timer
	attack_timer.start()
