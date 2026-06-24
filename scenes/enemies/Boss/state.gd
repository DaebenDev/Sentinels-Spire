extends Node2D
class_name State

var debug = null
var player = null
var animation_player = null

func _ready():
	# We find these after scene is loaded
	yield(get_tree(), "idle_frame")  # Wait one frame for scene to be ready
	
	# Get debug label if exists
	if owner and owner.has_node("debug"):
		debug = owner.get_node("debug")
	
	# Get player reference from the boss owner
	if owner and owner.has_method("get_player"):
		player = owner.get_player()
	elif owner and "player" in owner:
		player = owner.player
	
	# Get animation player from owner
	if owner and owner.has_node("AnimationPlayer"):
		animation_player = owner.get_node("AnimationPlayer")

	set_physics_process(false)

func enter():
	set_physics_process(true)

func exit():
	set_physics_process(false)

func transition():
	pass

func _physics_process(_delta):
	transition()
	if debug:
		debug.text = name
