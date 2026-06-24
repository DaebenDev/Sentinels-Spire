extends Enemy
class_name FlyingCreature

onready var hitbox: Area2D = get_node("Hitbox")

func _ready() -> void:
	animated_sprite.visible = true
	if hitbox:
		hitbox.monitoring = true
		if hitbox.get_child(0):
			hitbox.get_child(0).disabled = false
	if has_node("PathTimer"):
		$PathTimer.connect("timeout", self, "_on_PathTimer_timeout")

var repel_strength := 100.0  # Adjust as needed

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.collider
		if collider.is_in_group("Enemy"):
			# Repel slightly instead of damaging
			var repel_dir = (global_position - collider.global_position).normalized()
			velocity += repel_dir * repel_strength * delta
			move_and_collide(velocity * delta)

func _process(delta: float) -> void:
	hitbox.knockback_direction = velocity.normalized()
	update()
	if is_hit_cooldown and animated_sprite:
		animated_sprite.modulate = Color(1.2, 1.2, 1.2)  # Whitish effect during hit cooldown
	elif animated_sprite and animated_sprite.modulate != Color(1, 1, 1):
		animated_sprite.modulate = Color(1, 1, 1)  # Reset color when cooldown ends

func _draw() -> void:
	if path and path.size() > 1:
		for i in range(path.size() - 1):
			draw_line(path[i] - global_position, path[i + 1] - global_position, Color(1, 0, 0), 2.0)

func _on_Hitbox_body_entered(body: Node) -> void:
	if body.name == "KnightBeta" and not is_hit_cooldown and body.has_method("take_damage"):
		body.take_damage(damage, (body.global_position - global_position).normalized(), 100)
		is_hit_cooldown = true
		hit_cooldown_timer.start()

func _on_Hitbox_area_entered(area: Area2D) -> void:
	if is_hit_cooldown or area.name != "Hitbox" or area.get_parent().name != "KnightBeta":
		return
	if has_method("take_damage"):
		take_damage(1, (global_position - area.get_parent().global_position).normalized(), 100)
		is_hit_cooldown = true
		hit_cooldown_timer.start()
