extends Control

onready var start_button = $StartGame
onready var quit_button = $Quit

func _ready() -> void:
	if start_button:
		start_button.connect("pressed", self, "_on_Play_pressed")
	if quit_button:
		quit_button.connect("pressed", self, "_on_Quit_pressed")

func _on_StartGame_pressed() -> void:
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		# Load the first stage using GameManager
		var first_stage = game_manager.get_next_stage()
		get_tree().change_scene(first_stage)
	else:
		print("Error: GameManager not found! Loading Stage1 directly.")
		get_tree().change_scene("res://scenes/world/stages/Stage1.tscn")

func _on_Quit_pressed() -> void:
	get_tree().quit()


func _on_Play_pressed():
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		# Load the first stage using GameManager
		var first_stage = game_manager.get_next_stage()
		get_tree().change_scene(first_stage)
	else:
		print("Error: GameManager not found! Loading Stage1 directly.")
		get_tree().change_scene("res://scenes/world/stages/Stage1.tscn")
