extends "res://data/gene_cores/GeneCores.gd"

export var scale_boost: float = 1.0  # Increased to 1 (2x the original size)
export var hitbox_scale_factor: float = 1.5  # Factor to scale the hitbox radius

func _on_body_entered(body: Node) -> void:
	print("Body entered BigGuyGeneCore:", body.name)
	if body.name == "KnightBeta":
		# Scale up the player for visual effect
		var original_scale = body.scale if "scale" in body else Vector2(1, 1)
		body.scale = original_scale * (1.0 + scale_boost)

		# Scale up the slash sprite for visual effect only
		var slash_sprite = body.get_node("Sword/SlashSprite")
		if slash_sprite:
			var original_slash_scale = slash_sprite.scale if "scale" in slash_sprite else Vector2(1, 1)
			slash_sprite.scale = original_slash_scale * (1.0 + scale_boost)
			var direction = body.get_node("Sword").rotation
			var offset = Vector2(cos(direction), sin(direction)) * 2  # Fixed small offset
			slash_sprite.position += offset

		# Scale the sword hitbox circle radius efficiently
		var sword_hitbox = body.get_node("Sword/Node2D/Sprite/Hitbox")
		if sword_hitbox and sword_hitbox.get_child(0) and sword_hitbox.get_child(0).shape is CircleShape2D:
			var circle_shape: CircleShape2D = sword_hitbox.get_child(0).shape
			circle_shape.radius = circle_shape.radius * hitbox_scale_factor
			print("Scaled hitbox radius to:", circle_shape.radius)

		popup_text = "Big Guy AHAHAHHAHA"
		show_popup(body)
		queue_free()
	else:
		print("Ignored body:", body.name, " (not KnightBeta)")
