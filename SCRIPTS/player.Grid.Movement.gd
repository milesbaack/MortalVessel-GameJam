extends Node2D

# Grid Movement Constants
const GRID_COLUMNS = 5
const GRID_ROWS = 5
const CELL_SIZE = 16
const GRID_CENTER = Vector2(72, 162)
const GRID_ORIGIN = Vector2(
	GRID_CENTER.x - ((GRID_COLUMNS * CELL_SIZE) / 2),
	GRID_CENTER.y - ((GRID_ROWS * CELL_SIZE) / 2)
)

# Movement Settings
@export_group("Movement Settings")
@export var movement_duration: float = 0.15
@export var bounce_duration: float = 0.1
@export var bounce_distance: float = 4.0

# Stats Settings
@export_group("Base Stats")
@export var max_health: float = 100
@export var max_mana: float = 100
@export var max_xp: float = 100

# Current Stats
var current_health: float
var current_mana: float
var current_xp: float
var current_level: int = 1

# Movement State
var grid_pos = Vector2(2, 2)
var can_move = true

# UI Reference - Get the Control node from the UI scene instance
@onready var ui_container = get_node_or_null("../UI").get_node("Control")

func _ready():
	# Initialize position
	position = grid_to_world(grid_pos)
	
	# Initialize stats
	current_health = max_health
	current_mana = max_mana
	current_xp = 0
	
	# Debug: Print detailed node information
	print("\n=== Player Debug Info ===")
	print("My name:", name)
	print("My parent:", get_parent().name)
	
	# Debug UI scene instance
	var ui_scene = get_node_or_null("../UI")
	if ui_scene:
		print("\nFound UI scene instance!")
		print("UI scene children:", ui_scene.get_children())
		
		var control_node = ui_scene.get_node_or_null("Control")
		if control_node:
			print("Found Control node in UI scene!")
		else:
			print("Control node not found in UI scene.")
	else:
		print("UI scene instance not found!")
	
	await get_tree().process_frame
	if ui_container:
		update_ui()
		print("UI container found and connected!")
	else:
		print("\nUI not found! Debug info:")
		print("1. Your UI is a scene instance, which is good!")
		print("2. Check inside your UI.tscn that:")
		print("   - Root node is named 'UI' (CanvasLayer)")
		print("   - It has a Control node named 'Control'")

func _process(delta):
	if can_move:
		handle_input()

# Movement Functions
func handle_input():
	var move = Vector2.ZERO
	
	if Input.is_action_just_pressed("move_left"):
		move.x = -1
	elif Input.is_action_just_pressed("move_right"):
		move.x = 1
		
	if Input.is_action_just_pressed("move_up"):
		move.y = -1
	elif Input.is_action_just_pressed("move_down"):
		move.y = 1
	
	if move != Vector2.ZERO:
		var new_pos = grid_pos + move
		if is_valid_move(new_pos):
			move_to_position(new_pos)

func move_to_position(new_grid_pos: Vector2):
	can_move = false
	grid_pos = new_grid_pos
	var new_world_pos = grid_to_world(new_grid_pos)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "position", new_world_pos, movement_duration)
	
	var direction = (new_world_pos - position).normalized()
	tween.tween_property(self, "position", new_world_pos + (direction * bounce_distance), bounce_duration)
	tween.tween_property(self, "position", new_world_pos, bounce_duration)
	
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished():
	can_move = true

func is_valid_move(new_pos: Vector2) -> bool:
	return (new_pos.x >= 0 and new_pos.x < GRID_COLUMNS and
			new_pos.y >= 0 and new_pos.y < GRID_ROWS)

func grid_to_world(grid_position: Vector2) -> Vector2:
	return Vector2(
		GRID_ORIGIN.x + (grid_position.x * CELL_SIZE) + (CELL_SIZE / 2),
		GRID_ORIGIN.y + (grid_position.y * CELL_SIZE) + (CELL_SIZE / 2)
	)

# UI Update
func update_ui():
	if ui_container:
		ui_container.update_hp(current_health)
		ui_container.update_mana(current_mana)
		ui_container.update_xp(current_xp)

# Health Functions
func take_damage(amount: float):
	current_health = max(0, current_health - amount)
	update_ui()
	if current_health <= 0:
		die()

func heal(amount: float):
	current_health = min(max_health, current_health + amount)
	update_ui()

# Mana Functions
func use_mana(amount: float) -> bool:
	if current_mana >= amount:
		current_mana -= amount
		update_ui()
		return true
	return false

func restore_mana(amount: float):
	current_mana = min(max_mana, current_mana + amount)
	update_ui()

# XP Functions
func gain_xp(amount: float):
	current_xp += amount
	if current_xp >= max_xp:
		level_up()
	update_ui()

func level_up():
	current_level += 1
	current_xp = 0
	max_health *= 1.1
	max_mana *= 1.1
	max_xp *= 1.2
	current_health = max_health
	current_mana = max_mana
	update_ui()

func die():
	print("Vessel has fallen!")

# Debug Testing Input
func _input(event):
	if event.is_action_pressed("test_damage"):
		take_damage(10)
	elif event.is_action_pressed("test_heal"):
		heal(10)
	elif event.is_action_pressed("test_mana_use"):
		use_mana(20)
	elif event.is_action_pressed("test_mana_restore"):
		restore_mana(20)
	elif event.is_action_pressed("test_xp_gain"):
		gain_xp(25)
