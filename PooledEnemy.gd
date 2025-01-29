# PooledEnemy.gd
extends CharacterBody2D

var speed: float = 200.0
var lane_index: int = 0

@onready var anim = $AnimatedSprite2D

func _ready():
	if anim:
		anim.play("default")  # or whatever your animation name is

func initialize(enemy_speed: float, assigned_lane: int) -> void:
	speed = enemy_speed
	lane_index = assigned_lane
	if anim:
		anim.play("default")

func reset(enemy_speed: float, assigned_lane: int) -> void:
	speed = enemy_speed
	lane_index = assigned_lane
	if anim:
		anim.play("default")

func _physics_process(delta: float) -> void:
	if not visible:
		return
		
	velocity.y = speed
	velocity.x = 0
	move_and_slide()
