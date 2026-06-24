extends Camera2D

onready var target = get_node("../../KnightBeta")

func _ready():
	make_current()
	if target:
		print("Found KnightBeta at: ", target.position)
	else:
		print("KnightBeta not found!")

func _process(delta):
	if target:
		position = lerp(position, target.position, delta * smoothing_speed)
	else:
		print("Target is null in _process")
