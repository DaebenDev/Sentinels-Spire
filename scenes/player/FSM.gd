extends Node
class_name FiniteStateMachine

var states: Dictionary = {}
var previous_state: int = -1
var state: int = -1 setget set_state

onready var parent: Character = get_parent()
onready var animation_player: AnimationPlayer = parent.get_node_or_null("AnimationPlayer") if parent else null



func _ready() -> void:
	if not parent:
		print("Error: FiniteStateMachine parent is null! Check node attachment.")
		return
	if not parent is Character:
		print("Error: FiniteStateMachine parent is not a Character! Got: ", parent)
	if not animation_player:
		print("Warning: AnimationPlayer not found in parent ", parent.name)

func _physics_process(delta: float) -> void:
	if state != -1 and parent:  # Add null check for parent
		_state_logic(delta)
		var transition: int = _get_transition()
		if transition != -1:
			# Handle player death (special case)
			if transition == -2 and parent.has_method("die"):
				parent.die()
			else:
				set_state(transition)

func _state_logic(delta: float) -> void:
	pass

func _get_transition() -> int:
	return -1

func _add_state(new_state: String) -> void:
	states[new_state] = states.size()

func set_state(new_state: int) -> void:
	if not parent:  # Prevent crashes if parent is invalid
		print("Error: Cannot set state - parent is null!")
		return
	_exit_state(state)
	previous_state = state
	state = new_state
	_enter_state(previous_state, state)

func _enter_state(_previous_state: int, _new_state: int) -> void:
	pass

func _exit_state(_state_exited: int) -> void:
	pass
