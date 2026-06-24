extends Node2D

var current_state = null
var previous_state = null

func _ready():
	print("State Machine has children: ", get_children())
	for child in get_children():
		print(" - ", child.name)
	
	# Wait for everything to be ready
	yield(get_tree().create_timer(0.5), "timeout")
	init_states()

func init_states():
	print("Initializing state machine...")
	
	# Initialize first state automatically
	if has_node("Idle"):
		current_state = $Idle
		previous_state = current_state
		if current_state.has_method("enter"):
			current_state.enter()
		print("State machine initialized with Idle state")
	else:
		print("⚠️ No 'Idle' state found!")
		# Fallback to first available state
		if get_child_count() > 0:
			for child in get_children():
				if child.has_method("enter"):
					current_state = child
					previous_state = current_state
					current_state.enter()
					print("State machine initialized with ", child.name, " state")
					break

func change_state(state_name):
	print("🔄 Attempting to change state to: ", state_name)
	
	var new_state = null
	for child in get_children():
		if child.name == state_name:
			new_state = child
			break

	if new_state:
		print("✅ Changing state from ", current_state.name if current_state else "null", " to ", state_name)
		
		if current_state and current_state.has_method("exit"):
			current_state.exit()
		
		previous_state = current_state
		current_state = new_state
		
		if current_state.has_method("enter"):
			current_state.enter()
	else:
		print("❌ State not found: ", state_name)
		# Print available states for debugging
		print("Available states:")
		for child in get_children():
			print(" - ", child.name)

func _process(delta):
	if current_state and current_state.has_method("transition"):
		current_state.transition()
