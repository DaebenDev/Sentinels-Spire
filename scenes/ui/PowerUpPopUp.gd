extends Control

onready var label: Label = $TextLabel
onready var tween: Tween = Tween.new()  # For animation

func _ready() -> void:
	add_child(tween)
	visible = false  # Start hidden
	print("Popup ready (hidden)")  # Debug

func show_with_text(text: String, color: Color, duration: float, start_pos: Vector2) -> void:
	print("Showing popup with text: ", text, " at start_pos: ", start_pos)  # Debug
	label.text = text
	label.modulate = color
	rect_position = start_pos
	visible = true
	
	# Animate: Float up and fade out
	tween.interpolate_property(self, "rect_position:y", rect_position.y, rect_position.y - 20, duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(label, "modulate:a", 1.0, 0.0, duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	tween.connect("tween_all_completed", self, "_on_tween_completed")
	print("Tween started for popup")  # Debug

func _on_tween_completed() -> void:
	print("Tween completed for popup")  # Debug
	queue_free()  # Remove after animation
