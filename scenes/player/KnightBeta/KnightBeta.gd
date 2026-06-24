extends Character

onready var sword: Node2D = get_node("Sword")
onready var sword_hitbox: Area2D = get_node("Sword/Node2D/Sprite/Hitbox")
onready var sword_animation_player: AnimationPlayer = sword.get_node("SwordAnimationPlayer")
onready var sword_slash: Node2D = get_node("Sword/SlashSprite")
onready var speed_timer: Timer = $SpeedTimer
onready var damage_cooldown_timer: Timer = $DamageCooldownTimer


export (Texture) var ability_icon: Texture
export (float) var ability_cooldown: float = 8.0
export (int) var ability_damage: int = 25
export (float) var ability_radius: float = 120.0

const DASH_SPEED = 300
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 2.0

var original_modulate: Color
var hurt_timer: float = 0.0
var hurt_duration: float = 0.3
var dash_timer: float = 0.0
var is_dashing: bool = false
var dash_cooldown: float = 0.0
var custom_hit_range: float = 0.0
var can_take_damage: bool = true
var draw_hitbox: bool = true  # Toggle to enable/disable hitbox drawing (set to false in release)

func _ready():
	
	add_to_group("player")
	
	animated_sprite = $AnimatedSprite
	assert(animated_sprite != null, "AnimatedSprite not found!")
	
	sword_slash.visible = false
	sword_hitbox.monitoring = false
	if sword_hitbox.get_child(0):
		sword_hitbox.get_child(0).disabled = true
	
	original_modulate = animated_sprite.modulate
	
	sword_animation_player.connect("animation_started", self, "_on_attack_started")
	sword_animation_player.connect("animation_finished", self, "_on_attack_finished")
	
	if not speed_timer:
		speed_timer = Timer.new()
		add_child(speed_timer)
		speed_timer.wait_time = 2.0
		speed_timer.connect("timeout", self, "_on_speed_timer_timeout")
		speed_timer.start()
	
	if not damage_cooldown_timer:
		damage_cooldown_timer = Timer.new()
		add_child(damage_cooldown_timer)
		damage_cooldown_timer.wait_time = 0.3
		damage_cooldown_timer.one_shot = true
		damage_cooldown_timer.connect("timeout", self, "_on_damage_cooldown_timeout")
		damage_cooldown_timer.stop()

func _physics_process(delta: float) -> void:
	get_input()
	move(delta)
	
	if hurt_timer > 0:
		hurt_timer -= delta
		if hurt_timer <= 0:
			reset_color()
	
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			apply_friction(delta)
	else:
		if dash_cooldown > 0:
			dash_cooldown -= delta
	
	if dash_cooldown > 0 or is_dashing:
		emit_signal("dash_changed", 100 * (1 - dash_cooldown / DASH_COOLDOWN) if dash_cooldown > 0 else 0)
	else:
		emit_signal("dash_changed", 100)

func _draw() -> void:
	if draw_hitbox and sword_hitbox and sword_hitbox.get_child(0):
		var shape: CollisionShape2D = sword_hitbox.get_child(0)
		if shape.shape is RectangleShape2D:
			var rect: RectangleShape2D = shape.shape
			var size = rect.extents * 2  # extents to full size
			var pos = sword_hitbox.position + shape.position
			draw_rect(Rect2(pos - size / 2, size), Color(1, 0, 0, 0.5), false)  # Red outline
		elif shape.shape is CircleShape2D:
			var circle: CircleShape2D = shape.shape
			var pos = sword_hitbox.position + shape.position
			draw_circle(pos, circle.radius, Color(1, 0, 0, 0.5))  # Red circle outline
		else:
			print("Unsupported CollisionShape2D type for drawing")

func handle_facing():
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
	if mouse_direction.x > 0 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
	elif mouse_direction.x < 0 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true
		
	sword.rotation = mouse_direction.angle()
	sword_hitbox.knockback_direction = mouse_direction
	if sword.scale.y == 1 and mouse_direction.x < 0:
		sword.scale.y = -1
	elif sword.scale.y == -1 and mouse_direction.x > 0:
		sword.scale.y = 1
	update()  # Call update to trigger _draw when facing changes

func _process(delta):
	handle_facing()
	
	if Input.is_action_just_pressed("ui_attack") and not sword_animation_player.is_playing():
		sword_animation_player.play("attack")
	
	if Input.is_action_just_pressed("ui_dash") and dash_cooldown <= 0 and not is_dashing:
		dash()

func get_input() -> void:
	mov_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_down"):
		mov_direction += Vector2.DOWN
	if Input.is_action_pressed("ui_up"):
		mov_direction += Vector2.UP
	if Input.is_action_pressed("ui_left"):
		mov_direction += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		mov_direction += Vector2.RIGHT

func move(delta: float) -> void:
	if is_dashing:
		velocity = Vector2(cos(sword.rotation), sin(sword.rotation)) * DASH_SPEED
	else:
		if mov_direction.length() > 0:
			mov_direction = mov_direction.normalized()
			velocity += mov_direction * acceleration * delta
			velocity = velocity.limit_length(max_speed)
		else:
			apply_friction(delta)
	move_and_slide(velocity, FLOOR_NORMAL)

func apply_friction(delta: float) -> void:
	if velocity.length() > 0:
		velocity *= (1 - FRICTION)

func apply_hurt_effect():
	if animated_sprite == null:
		print("Warning: animated_sprite is null in apply_hurt_effect!")
		return
	animated_sprite.modulate = Color(1.2, 0.8, 0.8)
	hurt_timer = hurt_duration

func reset_color():
	if animated_sprite == null:
		print("Warning: animated_sprite is null in reset_color!")
		return
	animated_sprite.modulate = original_modulate

func take_damage(dam: int, dir: Vector2, force: int) -> void:
	if not can_take_damage or hp <= 0:
		return
	
	hp -= dam
	emit_signal("damage_taken", dam, dir, force)
	emit_signal("hp_changed", hp)
	print("KnightBeta took ", dam, " damage. New HP: ", hp)
	
	if hp <= 0:
		die()
		return
	
	velocity = dir.normalized() * knockback_speed
	mov_direction = Vector2.ZERO
	
	if state_machine and state_machine.has_method("set_state"):
		state_machine.set_state(state_machine.states.hurt)
	
	apply_hurt_effect()
	can_take_damage = false
	damage_cooldown_timer.start()

func die():
	if state_machine and state_machine.animation_player:
		state_machine.animation_player.stop()
	if sword_animation_player:
		sword_animation_player.stop()
	
	if animated_sprite:
		animated_sprite.modulate = Color(1, 0, 0)
	
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().reload_current_scene()

func enable_hitbox():
	if sword_hitbox:
		sword_hitbox.monitoring = true
		if sword_hitbox.get_child(0):
			sword_hitbox.get_child(0).disabled = false

func disable_hitbox():
	if sword_hitbox:
		sword_hitbox.monitoring = false
		if sword_hitbox.get_child(0):
			sword_hitbox.get_child(0).disabled = true

func _on_attack_started(anim_name: String):
	if anim_name == "attack":
		enable_hitbox()
		sword_slash.visible = true
		print("Attack started. Custom hit range:", custom_hit_range)
		
		# METHOD 1: Check overlapping areas/bodies (original method)
		var hit_bodies = []
		var bodies = sword_hitbox.get_overlapping_bodies()
		for body in bodies:
			hit_bodies.append(body)
		
		var areas = sword_hitbox.get_overlapping_areas()
		for area in areas:
			if area.get_parent() and area.get_parent() != self:
				hit_bodies.append(area.get_parent())
		
		# METHOD 2: Direct distance check to boss as fallback
		var boss = get_tree().get_nodes_in_group("boss")
		if boss.size() > 0:
			var boss_node = boss[0]
			var distance_to_boss = global_position.distance_to(boss_node.global_position)
			print("Distance to boss: ", distance_to_boss)
			if distance_to_boss < 100:  # Adjust this range as needed
				if boss_node.has_method("take_damage") and not boss_node in hit_bodies:
					hit_bodies.append(boss_node)
					print("✅ Added boss via distance check")
		
		# Process all detected targets
		for body in hit_bodies:
			print("Checking target: ", body.name, " | Type: ", body.get_class())
			
			if body is Character or body.has_method("take_damage"):
				var distance = global_position.distance_to(body.global_position)
				print("Distance to ", body.name, ": ", distance)
				
				if custom_hit_range <= 0 or distance <= custom_hit_range:
					if body.has_method("take_damage"):
						var knockback_dir = (body.global_position - global_position).normalized()
						body.take_damage(10, knockback_dir, 100)  # Increased damage from 1 to 10
						print("✅ SUCCESS: Hit ", body.name, " with damage!")

func _on_attack_finished(anim_name: String):
	if anim_name == "attack":
		disable_hitbox()
		sword_slash.visible = false
		custom_hit_range = 0.0

func dash():
	is_dashing = true
	dash_timer = DASH_DURATION
	dash_cooldown = DASH_COOLDOWN
	animated_sprite.modulate = Color(0.8, 0.8, 1.2)
	print("Emitting dash_changed with value: 0")
	emit_signal("dash_changed", 0)

func _on_speed_timer_timeout():
	print("Current speed:", speed, " Current max_speed:", max_speed)

func _on_damage_cooldown_timeout():
	can_take_damage = true

signal dash_changed(value)
signal damage_taken(damage, direction, force)
