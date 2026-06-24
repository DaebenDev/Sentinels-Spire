extends Area2D

class_name gene_core


export var boost_speed: int = 0
export var boost_max_speed: int = 0
export var boost_acceleration: int = 0  # New export for acceleration boost
export var popup_text: String = ""
export var popup_duration: float = 1.5
export var popup_color: Color = Color(1, 1, 1, 1)
export var popup_offset: Vector2 = Vector2(0, -32)

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	$CollisionShape2D.disabled = false
	print("GeneCore ready and listening for body_entered")

func _on_body_entered(body: Node) -> void:
	print("Body entered GeneCore:", body.name)
	if body.name == "KnightBeta":
		print("Applying boosts to KnightBeta: +", boost_speed, " speed, +", boost_max_speed, " max_speed, +", boost_acceleration, " acceleration")
		if body.has_method("set_speed") or "speed" in body:
			body.speed = (body.speed if "speed" in body else 0) + boost_speed
		if body.has_method("set_max_speed") or "max_speed" in body:
			body.max_speed = (body.max_speed if "max_speed" in body else 0) + boost_max_speed
		if body.has_method("set_acceleration") or "acceleration" in body:
			body.acceleration = (body.acceleration if "acceleration" in body else 0) + boost_acceleration
		show_popup(body)
		queue_free()
	else:
		print("Ignored body:", body.name, " (not KnightBeta)")

func show_popup(player: Node) -> void:
	if popup_text == "":
		print("No popup_text set, skipping popup")
		return
	
	var popup_scene = load("res://scenes/ui/PowerUpPopUp.tscn")
	if popup_scene == null:
		print("Error: Failed to load PowerUpPopUp.tscn!")
		return
	
	var popup = popup_scene.instance()
	if popup == null:
		print("Error: Failed to instance popup!")
		return
	
	print("Instanced popup, adding to scene")
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	get_tree().current_scene.add_child(canvas_layer)
	canvas_layer.add_child(popup)
	
	var viewport = get_viewport()
	var screen_pos = viewport.canvas_transform.xform(player.global_position)
	var final_pos = screen_pos + popup_offset
	print("Calculated screen_pos:", screen_pos)
	print("Setting popup position to:", final_pos)
	
	popup.show_with_text(popup_text, popup_color, popup_duration, final_pos)
	
	yield(popup.tween, "tween_all_completed")
	print("Popup animation completed, cleaning up")
	canvas_layer.queue_free()
