extends Label

func _process(delta):
	var boss = get_parent()
	if boss and boss.has_method("get_node") and boss.get_node("FiniteStateMachine"):
		var state_machine = boss.get_node("FiniteStateMachine")
		var current_state = state_machine.current_state.name if state_machine.current_state else "None"
		var player_dist = "N/A"
		
		if boss.player:
			player_dist = str(int(boss.global_position.distance_to(boss.player.global_position)))
		
		text = "State: " + current_state + "\nDistance: " + player_dist
