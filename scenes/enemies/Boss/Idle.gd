extends State

# Use 'onready' instead of '@onready'
# And use proper get_node() paths
onready var collision = get_node("../../PlayerDetection/CollisionShape2D")
onready var progress_bar = owner.get_node("ProgressBar")

var player_entered = false

func set_player_entered(value):
	player_entered = value
	if collision:
		collision.set_deferred("disabled", value)
	if progress_bar:
		progress_bar.set_deferred("visible", value)

func transition():
	if player_entered:
		get_parent().change_state("Follow")

func _on_PlayerDetection_body_entered(body):
	set_player_entered(true)
