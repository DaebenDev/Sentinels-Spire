extends KinematicBody2D
class_name Character

const FRICTION = 0.15
const FLOOR_NORMAL = Vector2.UP

export(int) var hp = 2 setget set_hp
signal hp_changed(new_hp)

export(int) var acceleration = 40
export(int) var max_speed = 100
export(int) var speed = 100
export(int) var knockback_speed = 200

onready var state_machine = get_node("FiniteStateMachine")
onready var animated_sprite = get_node("AnimatedSprite")

var mov_direction = Vector2.ZERO
var velocity = Vector2.ZERO

func _ready():
	# Make sure the state machine knows who its owner/player is
	state_machine.owner = self
	state_machine.call_deferred("init_states")  # Initialize all states safely after ready

func _physics_process(delta):
	move_and_slide(velocity, FLOOR_NORMAL)

func move(delta):
	mov_direction = mov_direction.normalized()
	velocity += mov_direction * acceleration * delta
	velocity = velocity.clamped(max_speed)

func apply_friction(delta):
	if velocity.length() > 0:
		velocity *= (1 - FRICTION)

func take_damage(dam, dir, force):
	set_hp(hp - dam)
	if hp > 0:
		state_machine.change_state("Hurt")
		velocity = dir.normalized() * knockback_speed
		mov_direction = Vector2.ZERO
	else:
		state_machine.change_state("Dead")
		velocity += dir * force * 2

func set_hp(new_hp):
	hp = max(0, new_hp)
	emit_signal("hp_changed", hp)
