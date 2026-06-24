extends "res://data/gene_cores/GeneCores.gd"

export var health_boost: int = 10  # Amount of health to restore

func _on_body_entered(body: Node) -> void:
	print("Body entered HealthGeneCore:", body.name)
	if body.name == "KnightBeta" and body.has_method("set_hp"):
		var current_hp = body.hp if "hp" in body else 0
		var max_hp = body.max_hp if "max_hp" in body else 10  # Assume 10 as default max_hp
		var game_manager = get_node_or_null("/root/GameManager")
		if game_manager and "player_max_health" in game_manager:
			max_hp = game_manager.player_max_health
			print("Using max_hp from GameManager: ", max_hp)
		else:
			if "max_hp" in body:
				max_hp = body.max_hp  # Use player's defined max_hp if available
			print("Warning: Using fallback max_hp: ", max_hp)

		# Heal up to max_hp (if needed)
		var new_hp = min(current_hp + health_boost, max_hp)  # Cap at max_hp
		if new_hp > current_hp:  # Only update if healing occurred
			body.set_hp(new_hp)
			print("Healed KnightBeta to ", new_hp, " (Max HP: ", max_hp, ")")
		else:
			print("No healing needed for KnightBeta (at max HP: ", current_hp, ")")

		# Set the popup_text dynamically and show popup
		popup_text = "+10 HP"
		popup_color = Color(0, 1, 0, 1)  # Green color for health
		show_popup(body)
		
		# Always consume the gene core
		queue_free()
	else:
		print("Ignored body:", body.name, " (not KnightBeta or no set_hp method)")
