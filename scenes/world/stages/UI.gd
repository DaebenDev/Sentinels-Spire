extends CanvasLayer

const MIN_HEALTH: int = 23
var max_hp: int = 4
onready var player: KinematicBody2D = get_parent().get_node("KnightBeta")
onready var health_bar: TextureProgress = get_node("HealthBar")
onready var health_bar_tween: Tween = get_node("HealthBar/Tween")
onready var dash_icon: TextureRect = get_node("DashIcon")
onready var dash_progress: TextureProgress = get_node("DashIcon/DashProgress")
onready var dash_tween: Tween = get_node("DashIcon/DashProgress/Tween")
onready var chromatid_label: Label = get_node("ChromatidDisplay/Label")  # Ensure this path matches your scene

func _ready() -> void:
	if not player:
		print("ERROR: Player (KnightBeta) not found! Check node path.")
		return
	max_hp = player.hp
	_update_health_bar(100)
	var hp_err = player.connect("hp_changed", self, "_on_hp_changed")
	var dash_err = player.connect("dash_changed", self, "_on_dash_changed")
	if hp_err != OK:
		print("Signal connect error for hp_changed:", hp_err)
	if dash_err != OK:
		print("Dash signal connect error:", dash_err)
	else:
		print("UI ready - Player starting HP:", player.hp)
	dash_icon.modulate = Color(1, 1, 1, 0.5)
	dash_progress.value = 100
	
	# Connect to GameManager signal
	if get_tree().root.has_node("/root/GameManager"):
		var game_manager = get_tree().root.get_node("/root/GameManager")
		var chromatid_err = game_manager.connect("chromatid_count_changed", self, "_on_chromatid_count_changed")
		if chromatid_err != OK:
			print("Signal connect error for chromatid_count_changed:", chromatid_err)
		else:
			chromatid_label.text = str(game_manager.chromatid_count)

func _update_health_bar(new_value: int) -> void:
	if not health_bar or not health_bar_tween:
		print("Error: health_bar or health_bar_tween is null!")
		return
	if health_bar_tween.interpolate_property(health_bar, "value", health_bar.value, new_value, 0.5, Tween.TRANS_QUINT, Tween.EASE_OUT):
		health_bar_tween.start()
	else:
		print("Tween failed! Check property/path for health_bar.")

func _update_dash_progress(new_value: int) -> void:
	if not dash_progress or not dash_tween:
		print("Error: dash_progress or dash_tween is null!")
		return
	if dash_tween.interpolate_property(dash_progress, "value", dash_progress.value, new_value, 0.5, Tween.TRANS_QUINT, Tween.EASE_OUT):
		dash_tween.start()
	else:
		print("Dash Tween failed! Check property/path for dash_progress.")
	dash_progress.value = new_value
	if new_value >= 100:
		dash_icon.modulate = Color(1, 1, 1, 1)
	else:
		dash_icon.modulate = Color(1, 1, 1, 0.5)

func _on_hp_changed(new_hp: int) -> void:
	if not player:
		print("Error: Player is null in _on_hp_changed!")
		return
	print("UI: Received hp_changed signal! New HP:", new_hp)
	var new_health: int = int((100 - MIN_HEALTH) * float(new_hp) / max_hp) + MIN_HEALTH
	print("UI: Calculated bar value:", new_health)
	_update_health_bar(new_health)

func _on_dash_changed(value: int) -> void:
	_update_dash_progress(value)

func _on_chromatid_count_changed(count: int) -> void:
	chromatid_label.text = str(count)
	print("UI: Chromatid count updated to ", count)
