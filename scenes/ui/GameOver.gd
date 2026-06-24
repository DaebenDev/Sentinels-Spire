extends Control

onready var retry_button = $Retry
onready var back_to_menu_button = $BackToMenu
onready var quit_button = $Quit
onready var points_label = $PointsLabel

func _ready() -> void:
	if retry_button:
		retry_button.connect("pressed", self, "_on_Retry_pressed")
	if back_to_menu_button:
		back_to_menu_button.connect("pressed", self, "_on_BackToMenu_pressed")
	if quit_button:
		quit_button.connect("pressed", self, "_on_Quit_pressed")
	
	# Calculate and display score
	calculate_and_display_score()

func calculate_and_display_score() -> void:
	var game_manager = get_node_or_null("/root/GameManager")
	if not game_manager:
		points_label.text = "Error: GameManager not found!"
		return
	
	var chromatid_points = game_manager.chromatid_count * 10
	var survival_minutes = floor(game_manager.survival_time / 60.0)  # Convert seconds to minutes
	var survival_points = survival_minutes * 1000
	var kill_points = game_manager.enemy_kills * 60
	var total_points = chromatid_points + survival_points + kill_points
	
	# Example values based on your input: kills = 8, time survived = "balcbh basd" (assuming typo, using survival_time), points = 102002
	# For demonstration, let's assume survival_time = 101 seconds (1 minute + 41 seconds) and adjust to match 102002
	# Reverse engineer: 102002 - (8 * 60) - (1 * 1000) = 101002 / 10 = 10100 chromatids (adjust as needed)
	
	points_label.text = """
Kills = %d
Time Survived = %d minutes
Chromatid Points = %d
Survival Points = %d
Kill Points = %d
Total Points = %d
""" % [game_manager.enemy_kills, survival_minutes, chromatid_points, survival_points, kill_points, total_points]

func _on_Retry_pressed() -> void:
	# Reload the current stage (e.g., Stage1)
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		get_tree().change_scene(game_manager.get_next_stage())
	else:
		get_tree().change_scene("res://scenes/world/stages/Stage1.tscn")

func _on_BackToMenu_pressed() -> void:
	get_tree().change_scene("res://scenes/MainMenu.tscn")  # Adjust path as needed

func _on_Quit_pressed() -> void:
	get_tree().quit()
