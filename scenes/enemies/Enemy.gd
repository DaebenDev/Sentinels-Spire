extends Character
class_name Enemy, "res://resources/tilesets/enemies/goblin/goblin_idle_anim_f0.png"

var path: PoolVector2Array
var damage: int = 1
var is_hit_cooldown: bool = false

onready var navigation: Navigation2D = get_tree().current_scene.get_node_or_null("Navigation2D")
onready var player: KinematicBody2D = get_tree().current_scene.get_node_or_null("KnightBeta")
onready var hit_cooldown_timer: Timer = Timer.new()
onready var spawner: Node2D = get_tree().current_scene.get_node_or_null("Spawner")
onready var path_timer: Timer = $PathTimer

func _ready() -> void:
	animated_sprite.visible = true
	add_child(hit_cooldown_timer)
	hit_cooldown_timer.wait_time = 0.5
	hit_cooldown_timer.one_shot = true
	hit_cooldown_timer.connect("timeout", self, "_on_hit_cooldown_timeout")

func _physics_process(delta: float) -> void:
	move(delta)  # Ensure move is called every frame
	move_and_slide(velocity, FLOOR_NORMAL)

func take_damage(dam: int, dir: Vector2, force: int) -> void:
	if hp <= 0:
		return
	hp -= dam
	if state_machine:
		state_machine.set_state(state_machine.states.hurt)
	velocity = dir.normalized() * knockback_speed
	mov_direction = Vector2.ZERO
	if hp <= 0:
		drop_chromatids()

func drop_chromatids() -> void:
	if not spawner:
		print("Warning: Spawner not found for Chromatid drop")
		return
	var drop_amount = randi() % (spawner.max_chromatid_drop - spawner.min_chromatid_drop + 1) + spawner.min_chromatid_drop
	if get_tree().root.has_node("/root/GameManager"):
		var game_manager = get_tree().root.get_node("/root/GameManager")
		game_manager.add_chromatids(drop_amount)
		print("Dropped ", drop_amount, " Chromatids at ", global_position)
	else:
		print("Warning: GameManager not found, Chromatids not added")

func chase() -> void:
	if not path or hp <= 0:
		return
	var vector_to_next_point: Vector2 = path[0] - global_position
	var distance_to_next_point: float = vector_to_next_point.length()
	if distance_to_next_point < 3:
		path.remove(0)
		if not path:
			return
	mov_direction = vector_to_next_point.normalized()
	animated_sprite.flip_h = vector_to_next_point.x < 0

func _on_hit_cooldown_timeout() -> void:
	is_hit_cooldown = false

func _on_PathTimer_timeout() -> void:
	if navigation and player and hp > 0:
		path = navigation.get_simple_path(global_position, player.global_position)
	else:
		path_timer.stop()
		path = []
		mov_direction = Vector2.ZERO
