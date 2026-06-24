# res://abilities/GroundSlam.gd
extends Node2D

export (Texture) var icon: Texture setget set_icon
export (float, 1, 30) var cooldown: float = 8.0
export (int) var damage: int = 25
export (float) var radius: float = 120.0

onready var anim_player: AnimationPlayer = $AnimatedSprite/AnimationPlayer
onready var hitbox: Area2D = $SlamHitbox
onready var cooldown_timer: Timer = $CooldownTimer
onready var progress: TextureProgress = $CooldownBar
onready var icon_node: TextureRect = $Control/AbilityIcon

var is_ready: bool = true
var slam_active: bool = false

func _ready() -> void:
	# === SAFETY & CONFIG ===
	if not hitbox:
		push_error("SlamHitbox (Area2D) is missing!")
		return
	if not cooldown_timer:
		push_error("CooldownTimer missing!")
		return

	cooldown_timer.wait_time = cooldown
	if progress:
		progress.max_value = cooldown
		progress.value = cooldown

	# Apply radius
	if hitbox.get_child_count() > 0 and hitbox.get_child(0) is CollisionShape2D:
		var shape = hitbox.get_child(0).shape
		if shape is CircleShape2D:
			shape.radius = radius

	if icon:
		set_icon(icon)

	# Connect signals properly
	if not cooldown_timer.is_connected("timeout", self, "_on_cooldown_timeout"):
		cooldown_timer.connect("timeout", self, "_on_cooldown_timeout")
	
	# Connect hitbox signal properly
	if not hitbox.is_connected("body_entered", self, "_on_SlamHitbox_body_entered"):
		hitbox.connect("body_entered", self, "_on_SlamHitbox_body_entered")

	# Start DISABLED
	hitbox.monitoring = false
	if hitbox.get_child_count() > 0 and hitbox.get_child(0) is CollisionShape2D:
		hitbox.get_child(0).disabled = true

	# Keep icon always visible, hide effect/animation only
	visible = false
	if icon_node:
		icon_node.visible = true
	if progress:
		progress.visible = true
		progress.value = cooldown

	print("GroundSlam ready. Animation list: ", anim_player.get_animation_list() if anim_player else "No AnimationPlayer")

func set_icon(tex: Texture) -> void:
	icon = tex
	if icon_node:
		icon_node.texture = tex

func activate() -> void:
	if not is_ready or slam_active:
		print("GroundSlam: Cannot activate - not ready or already active")
		return

	print("GROUND SLAM ACTIVATED")

	slam_active = true
	is_ready = false
	
	# Position at player but don't make it a child for movement
	global_position = get_parent().global_position
	
	# Show animation effect
	visible = true
	
	# Update icon appearance for cooldown
	if icon_node:
		icon_node.modulate = Color(0.5, 0.5, 0.5)  # Darken during cooldown

	# Play animation
	if anim_player and anim_player.has_animation("ground_slam"):
		anim_player.play("ground_slam")
		print("Playing ground_slam animation")
	else:
		push_error("Animation 'ground_slam' not found or no AnimationPlayer!")

	# Enable hitbox
	hitbox.monitoring = true
	if hitbox.get_child_count() > 0 and hitbox.get_child(0) is CollisionShape2D:
		hitbox.get_child(0).disabled = false

	# Start cooldown
	cooldown_timer.start()

	# Auto-disable after animation duration (for 10 frames at your FPS)
	get_tree().create_timer(0.3).connect("timeout", self, "_disable_hitbox")

func _disable_hitbox() -> void:
	hitbox.monitoring = false
	if hitbox.get_child_count() > 0 and hitbox.get_child(0) is CollisionShape2D:
		hitbox.get_child(0).disabled = true
	slam_active = false
	visible = false  # Hide animation effect, but keep icon visible
	print("Ground Slam hitbox disabled")

func _on_cooldown_timeout() -> void:
	is_ready = true
	# Reset icon to normal color when ready
	if icon_node:
		icon_node.modulate = Color(1, 1, 1)  # Normal color
	print("Ground Slam ready again")

func _process(delta: float) -> void:
	if not is_ready and progress:
		progress.value = cooldown - cooldown_timer.time_left
	
	# Make UI follow camera instead of player
	if (progress or icon_node) and is_instance_valid(get_parent()):
		var camera = get_viewport().get_camera()
		if camera:
			var base_pos = camera.global_position + Vector2(-50, 100)
			if progress:
				progress.global_position = base_pos
			if icon_node:
				icon_node.global_position = base_pos + Vector2(-20, -30)  # Adjust icon position relative to progress bar

# FIXED: Damage detection - properly check for player
func _on_SlamHitbox_body_entered(body: Node) -> void:
	if not is_instance_valid(body):
		return
		
	# Skip if it's the player or in player group
	if body == get_parent() or body.is_in_group("player"):
		print("Skipping player damage")
		return
		
	# Check if it's an enemy that can take damage
	if body.has_method("take_damage"):
		var dir = (body.global_position - global_position).normalized()
		body.take_damage(damage, dir, 200)
		print("Ground Slam hit: ", body.name, " | Type: ", body.get_class())
	else:
		print("Body cannot take damage: ", body.name, " | Type: ", body.get_class())
