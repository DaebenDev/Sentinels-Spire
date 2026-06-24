extends Node2D

func _init() -> void:
	var screen_size: Vector2 = OS.get_screen_size()
	var window_size: Vector2 = OS.get_window_size()
	OS.set_window_position(screen_size * 0.5 - window_size * 0.5)

func _ready() -> void:
	var player = get_node_or_null("/root/Stage1/KnightBeta")
	if player:
		var game_manager = get_node_or_null("/root/GameManager")
		if game_manager:
			game_manager.apply_player_stats(player)
		else:
			print("Error: GameManager not found!")
	else:
		print("Error: KnightBeta not found in Stage1!")
