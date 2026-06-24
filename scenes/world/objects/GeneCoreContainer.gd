extends Node2D

export(int) var required_chromatids: int = 5  # Cost to open, adjustable in Inspector
export(Array, PackedScene) var gene_core_scenes  # Array of gene core scenes (exclude HealthGeneCore)

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var interaction_area: Area2D = $InteractionArea
onready var cost_label: Label = $CostLabel
onready var despawn_timer: Timer = $DespawnTimer

var is_opening: bool = false
var is_opened: bool = false
var player_in_range: bool = false

func _ready() -> void:
	if not animation_player:
		print("Error: AnimationPlayer not found!")
	else:
		animation_player.play("spawn")
		animation_player.connect("animation_finished", self, "_on_animation_finished")
	
	if not despawn_timer:
		print("Error: DespawnTimer not found!")
	else:
		despawn_timer.wait_time = 3.0  # Despawn after 3 seconds when opened
		despawn_timer.one_shot = true
		despawn_timer.connect("timeout", self, "_on_despawn_timeout")
	
	# Ensure interaction area is active
	if interaction_area and interaction_area.get_child(0):
		var collision_shape = interaction_area.get_child(0)
		if collision_shape is CollisionShape2D:
			collision_shape.disabled = false
			interaction_area.connect("body_entered", self, "_on_InteractionArea_body_entered")
			interaction_area.connect("body_exited", self, "_on_InteractionArea_body_exited")
		else:
			print("Error: InteractionArea child is not a CollisionShape2D!")
	else:
		print("Error: InteractionArea or CollisionShape2D not found!")
	
	# Initialize cost label (hidden until player is in range)
	if cost_label:
		cost_label.text = "Open Use E: " + str(required_chromatids)
		cost_label.rect_position = Vector2(-30,-20)  # Move 50 pixels down
		cost_label.visible = false  # Hide by default
		cost_label.add_color_override("font_color", Color(1, 1, 1))  # White text for visibility
		print("CostLabel initialized with text: ", cost_label.text, " at position: ", cost_label.rect_position)
	else:
		print("Error: CostLabel not found!")
	
	# Debug gene_core_scenes
	print("Gene core scenes array: ", gene_core_scenes, " Size: ", gene_core_scenes.size())

func _process(delta: float) -> void:
	if player_in_range and not is_opening and not is_opened:
		if Input.is_action_just_pressed("ui_interact"):  # Use "E" key or your interact action
			check_interaction()

func check_interaction() -> void:
	var game_manager = get_tree().root.get_node_or_null("/root/GameManager")
	if not game_manager:
		print("Error: GameManager not found!")
	elif game_manager.chromatid_count >= required_chromatids:
		game_manager.add_chromatids(-required_chromatids)  # Deduct Chromatids
		is_opening = true
		if animation_player:
			animation_player.play("opening")
			print("Chest opening, Chromatids deducted: ", required_chromatids)
		else:
			print("Error: AnimationPlayer not available to play opening!")
		if cost_label:
			cost_label.visible = false
	else:
		print("Not enough Chromatids: ", game_manager.chromatid_count, " / ", required_chromatids)

func _on_animation_finished(anim_name: String) -> void:
	if is_opening and anim_name == "opening":
		is_opening = false
		is_opened = true
		if animation_player:
			animation_player.play("opened")
			drop_gene_core()
			despawn_timer.start()
		else:
			print("Error: AnimationPlayer not available for opened state!")
	elif anim_name == "spawn":
		if animation_player:
			animation_player.play("idle")
		else:
			print("Error: AnimationPlayer not available for idle transition!")

func drop_gene_core() -> void:
	if gene_core_scenes.size() > 0:
		var random_index = randi() % gene_core_scenes.size()
		var gene_core = gene_core_scenes[random_index].instance()
		if gene_core:
			gene_core.global_position = global_position
			get_tree().current_scene.add_child(gene_core)
			print("Dropped Gene Core: ", gene_core.name)
		else:
			print("Error: Failed to instance gene core at index ", random_index)
	else:
		print("Error: No gene_core_scenes defined!")

func _on_despawn_timeout() -> void:
	queue_free()

func _on_InteractionArea_body_entered(body: Node) -> void:
	if body.name == "KnightBeta":
		player_in_range = true
		if cost_label:
			cost_label.visible = true  # Show label when player enters range
			print("Player in range, showing label: ", cost_label.text, " at position: ", cost_label.rect_position)

func _on_InteractionArea_body_exited(body: Node) -> void:
	if body.name == "KnightBeta":
		player_in_range = false
		if cost_label:
			cost_label.visible = false  # Hide label when player exits range
			print("Player out of range, hiding label")
