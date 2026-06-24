extends Area2D

onready var player = get_player_reference()
var speed = 150
var direction = Vector2.RIGHT
var homing_strength = 2.0
var lifetime = 5.0
var life_timer = 0.0

func get_player_reference():
	# Try multiple ways to find the player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	
	# Alternative search methods
	if get_tree().current_scene.has_node("KnightBeta"):
		return get_tree().current_scene.get_node("KnightBeta")
	elif get_tree().current_scene.has_node("Character"):
		return get_tree().current_scene.get_node("Character")
	
	return null

func _ready():
	# If player wasn't found in onready, try again
	if not player:
		player = get_player_reference()

func _physics_process(delta):
	life_timer += delta
	if life_timer >= lifetime:
		queue_free()
		return
	
	if player:
		# Homing behavior
		var target_direction = (player.global_position - global_position).normalized()
		direction = direction.linear_interpolate(target_direction, homing_strength * delta)
	
	rotation = direction.angle()
	position += direction * speed * delta

func _on_Bullet_body_entered(body):
	if body and body.has_method("take_damage") and (body.name == "KnightBeta" or body.is_in_group("player")):
		print("MISSILE HIT PLAYER!")
		body.take_damage(8, direction, 20)
		queue_free()
		
		# Add this function to the bullet script
func set_damage(new_damage):
	# You'll need to modify the bullet to store damage and use it when hitting player
	pass
