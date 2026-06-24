extends State

var can_transition = false
var buff_duration = 2.0

func enter():
	.enter()
	print("ArmorBuff state entered! DEF increased to ", owner.DEF)
	
	can_transition = false
	
	if animation_player and animation_player.has_animation("armor_buff"):
		animation_player.play("armor_buff")
		yield(animation_player, "animation_finished")
	
	# Visual effect for armor buff
	if owner and owner.has_node("Sprite"):
		var armor_color = Color(0.7, 0.7, 1.0)
		if owner and "armor_buff_color" in owner:
			armor_color = owner.armor_buff_color
		owner.get_node("Sprite").modulate = armor_color
	
	# Wait a bit before transitioning
	yield(get_tree().create_timer(buff_duration), "timeout")
	
	# Restore normal color
	if owner and owner.has_node("Sprite"):
		owner.get_node("Sprite").modulate = Color(1, 1, 1)
	
	can_transition = true

func transition():
	if can_transition:
		can_transition = false
		print("Armor buff finished, returning to Follow")
		get_parent().change_state("Follow")
