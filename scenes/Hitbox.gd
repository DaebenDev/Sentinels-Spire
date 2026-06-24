extends Area2D
class_name Hitbox

export(int) var damage: int = 1
var knockback_direction: Vector2 = Vector2.ZERO
var can_damage: bool = true  # NEW: Cooldown flag
var cooldown_time: float = 0.1  # NEW: Prevent spam hits
var cooldown_timer: float = 0.0

onready var collision_shape: CollisionShape2D = get_child(0)

func _init() -> void:
	connect("body_entered", self, "_on_body_entered")

func _ready() -> void:
	assert(collision_shape != null)

func _physics_process(delta: float) -> void:
	# NEW: Handle cooldown timer
	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_damage = true

func _on_body_entered(body: PhysicsBody2D) -> void:
	# NEW: Check cooldown
	if not can_damage:
		return
	
	if not is_instance_valid(body):
		return
	
	if not body.has_method("take_damage"):
		print("Hitbox: Body doesn't have take_damage: ", body.name if body else "NULL")
		return
	
	if body == get_parent():
		return
	
	# NEW: Apply cooldown after successful hit
	can_damage = false
	cooldown_timer = cooldown_time
	
	print("Hitbox: Applying ", damage, " damage to ", body.name)
	body.take_damage(damage, knockback_direction, 0)
