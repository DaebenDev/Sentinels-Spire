extends Node2D

var current_state
var previous_state

func _ready():
	current_state = get_node("Idle") # safer than get_child(8)
	previous_state = current_state
	current_state.enter()

func change_state(state_name):
	var new_state = null
	for child in get_children():
		if child.name == state_name:
			new_state = child
			break
	
	if new_state:
		previous_state.exit()
		current_state = new_state
		current_state.enter()
		previous_state = current_state
	else:
		print("State not found: ", state_name)
