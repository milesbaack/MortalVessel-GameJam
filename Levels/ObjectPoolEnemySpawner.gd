# ObjectPoolEnemySpawner.gd
extends Node2D

@export var enemy_scene: PackedScene
@export var pool_size: int = 10
@export var min_spawn_interval: float = 1.5
@export var max_spawn_interval: float = 3.0
@export var enemy_speed: float = 200.0

# Lane configuration
@export var lane_start_x: float = 32  # X position of first lane
@export var lane_width: float = 16    # Width between lane centers
@export var lane_count: int = 5       # Number of lanes
@export var draw_debug_lanes: bool = true  # Toggle lane visualization

var enemy_pool: Array[Node] = []
var lane_positions: Array[float] = []
var time_until_next_spawn: float
var active: bool = true
var screen_height: float

func _ready() -> void:
	print("Spawner _ready called")
	randomize()
	reset_spawn_timer()
	setup_lanes()
	initialize_pool()
	screen_height = get_viewport_rect().size.y
	queue_redraw()
	print("Lane positions: ", lane_positions)
	print("Pool size: ", enemy_pool.size())

func setup_lanes() -> void:
	lane_positions.clear()
	for i in range(lane_count):
		var lane_center = lane_start_x + (i * lane_width)
		lane_positions.append(lane_center)

func _draw() -> void:
	if draw_debug_lanes and OS.is_debug_build():
		for lane_x in lane_positions:
			# Draw lane center line
			draw_line(
				Vector2(lane_x, -20),
				Vector2(lane_x, get_viewport_rect().size.y),
				Color(1, 0, 0, 0.5),  # Semi-transparent red
				2.0
			)
			# Draw lane boundaries
			draw_line(
				Vector2(lane_x - lane_width/2, -20),
				Vector2(lane_x - lane_width/2, get_viewport_rect().size.y),
				Color(1, 1, 0, 0.2),  # Very transparent yellow
				1.0
			)

func initialize_pool() -> void:
	for i in range(pool_size):
		var enemy = enemy_scene.instantiate()
		enemy.visible = false
		add_child(enemy)
		enemy_pool.append(enemy)
		if enemy.has_method("initialize"):
			enemy.initialize(enemy_speed, 0)

func _physics_process(delta: float) -> void:
	if not active:
		return
	
	# Update all active enemies
	for enemy in enemy_pool:
		if enemy.visible and enemy.global_position.y > screen_height + lane_width:
			recycle_enemy(enemy)
	
	time_until_next_spawn -= delta
	if time_until_next_spawn <= 0:
		spawn_enemy()
		reset_spawn_timer()

func spawn_enemy() -> void:
	print("Attempting to spawn enemy")
	var available_enemy = get_inactive_enemy()
	if not available_enemy:
		print("No available enemy in pool")
		return
	
	var lane_index = randi() % lane_count
	var spawn_x = lane_positions[lane_index]
	
	available_enemy.global_position = Vector2(spawn_x, -lane_width)
	available_enemy.visible = true
	
	if available_enemy.has_method("reset"):
		available_enemy.reset(enemy_speed, lane_index)

func get_inactive_enemy() -> Node:
	for enemy in enemy_pool:
		if not enemy.visible:
			return enemy
	return null

func recycle_enemy(enemy: Node) -> void:
	enemy.visible = false

func reset_spawn_timer() -> void:
	time_until_next_spawn = randf_range(min_spawn_interval, max_spawn_interval)

func start_spawning() -> void:
	active = true
	reset_spawn_timer()

func stop_spawning() -> void:
	active = false
	for enemy in enemy_pool:
		enemy.visible = false

# Helper function to get lane center position
func get_lane_position(lane_index: int) -> float:
	if lane_index >= 0 and lane_index < lane_positions.size():
		return lane_positions[lane_index]
	return lane_positions[0]
