extends Node2D

onready var label = $NextStageLabel
onready var collision_shape = $Area2D/CollisionShape2D
var player_in_range = false

func _ready():
	if not is_in_group("next_stage_area"):
		add_to_group("next_stage_area")
	if label:
		label.visible = false
		label.text = "Next Stage? Press E"
	if not collision_shape or collision_shape.disabled:
		print("Warning: CollisionShape2D is missing or disabled!")
	$Area2D.connect("body_entered", self, "_on_body_entered")
	$Area2D.connect("body_exited", self, "_on_body_exited")

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("ui_interact"):
		transition_to_next_stage()

func _on_body_entered(body):
	if body.name == "KnightBeta":
		player_in_range = true
		if label:
			label.visible = true
		print("Player in range of NextStageArea")

func _on_body_exited(body):
	if body.name == "KnightBeta":
		player_in_range = false
		if label:
			label.visible = false
		print("Player out of range of NextStageArea")

func transition_to_next_stage():
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		var current_player = get_node_or_null("/root/" + get_tree().current_scene.name + "/KnightBeta")
		if current_player:
			var player_pos = current_player.global_position
			game_manager.increment_stage_index()
			var next_stage = game_manager.get_next_stage()
			get_tree().change_scene(next_stage)
			print("Transitioning to ", next_stage)
		else:
			print("Error: Current KnightBeta not found before transition!")
	else:
		print("Error: GameManager not found for transition!")
