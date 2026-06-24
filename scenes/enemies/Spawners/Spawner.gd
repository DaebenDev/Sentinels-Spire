extends Node2D

export(bool) var spawn_flying_creature: bool = true
export(PackedScene) var flying_creature_scene
export(float) var base_spawn_interval: float = 2.0
export(float) var min_spawn_interval: float = 0.5
export(float) var interval_decrease_rate: float = 0.1
export(int) var max_enemies: int = 20
export(float) var min_spawn_radius: float = 200.0
export(float) var max_spawn_radius: float = 500.0
export(int) var enemy_max_speed: int = 1000  # Updated to match inspector
export(int) var enemy_acceleration: int = 250  # Updated to match inspector
export(int) var enemy_hp: int = 4
export(int) var enemy_damage: int = 1
export(int) var min_chromatid_drop: int = 4
export(int) var max_chromatid_drop: int = 10

const MAX_RETRIES = 5
const MAX_SNAP_DISTANCE = 50.0

onready var spawn_timer: Timer = $SpawnTimer
var current_interval: float
var game_time: float = 0.0
var enemy_count: int = 0
var player: Node
var navigation: Navigation2D

func _ready() -> void:
	player = get_tree().current_scene.get_node("KnightBeta")
	navigation = get_tree().current_scene.get_node("Navigation2D")
	if not player or not navigation:
		print("Warning: Missing KnightBeta or Navigation2D")
		return
	
	current_interval = base_spawn_interval
	spawn_timer.wait_time = current_interval
	spawn_timer.connect("timeout", self, "_on_spawn_timer_timeout")
	spawn_timer.start()

func _process(delta: float) -> void:
	game_time += delta
	if game_time >= 60.0:
		current_interval = max(min_spawn_interval, current_interval - interval_decrease_rate)
		spawn_timer.wait_time = current_interval
		game_time = 0.0

func _on_spawn_timer_timeout() -> void:
	if enemy_count >= max_enemies or not player or not navigation:
		spawn_timer.start()
		return

	var possible_enemies = []
	if spawn_flying_creature and flying_creature_scene:
		possible_enemies.append(flying_creature_scene)
	
	if possible_enemies.empty():
		spawn_timer.start()
		return

	var enemy_scene = possible_enemies[randi() % possible_enemies.size()]
	var enemy = enemy_scene.instance()
	if not enemy:
		spawn_timer.start()
		return

	enemy.max_speed = enemy_max_speed
	enemy.acceleration = enemy_acceleration
	enemy.hp = enemy_hp
	enemy.damage = enemy_damage

	var spawn_pos = Vector2.ZERO
	for retries in MAX_RETRIES:
		var angle = randf() * 2 * PI
		var distance = rand_range(min_spawn_radius, max_spawn_radius)
		var attempted_pos = player.global_position + Vector2(cos(angle), sin(angle)) * distance
		var snapped_pos = navigation.get_closest_point(attempted_pos)
		if attempted_pos.distance_to(snapped_pos) <= MAX_SNAP_DISTANCE:
			spawn_pos = snapped_pos
			break
	
	if spawn_pos == Vector2.ZERO:
		spawn_timer.start()
		return

	enemy.global_position = spawn_pos
	get_tree().current_scene.add_child(enemy)
	enemy_count += 1
	spawn_timer.wait_time = current_interval
	spawn_timer.start()
