extends Area2D
class_name SlamHitbox

export(int) var damage: int = 1
var knockback_direction: Vector2 = Vector2.ZERO
var can_damage: bool = true
var cooldown_time: float = 0.1
var cooldown_timer: float = 0.0

onready var collision_shape: CollisionShape2D = get_child(0)

func _ready() -> void:
	assert(collision_shape != null)
	# Connect in _ready instead of _init to be safe
	if not is_connected("body_entered", self, "_on_body_entered"):
		connect("body_entered", self, "_on_body_entered")

func _physics_process(delta: float) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_damage = true

func _on_body_entered(body: PhysicsBody2D) -> void:
	if not can_damage:
		return
	
	if not is_instance_valid(body):
		return
	
	# Skip player - more thorough check
	if body == get_parent() or body.is_in_group("player") or body.name == "KnightBeta":
		return
	
	if not body.has_method("take_damage"):
		print("Hitbox: Body doesn't have take_damage: ", body.name if body else "NULL")
		return
	
	# Apply cooldown after successful hit
	can_damage = false
	cooldown_timer = cooldown_time
	
	print("SlamHitbox: Applying ", damage, " damage to ", body.name)
	body.take_damage(damage, knockback_direction, 0)
