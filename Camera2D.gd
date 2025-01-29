extends Camera2D

# Camera follow settings
@export_group("Follow Settings")
@export var follow_speed: float = 3.0  # Lower = smoother/slower, Higher = more responsive
@export var min_distance: float = 1.0  # Minimum distance before camera starts moving
@export var tween_duration: float = 0.3  # Duration of camera position tweening

# Target related variables
@onready var target = get_node_or_null("../Player_Vessel")
var target_position: Vector2
var is_tweening: bool = false

func _ready():
	# Basic camera setup
	make_current()
	
	# Debug check for target
	if target:
		print("Camera: Player target found")
		# Set initial position to player position
		position = target.position
		target_position = target.position
	else:
		push_error("Camera: Player target not found! Check the node path.")

func _physics_process(delta):
	if not target:
		return
		
	# Update target position
	target_position = target.position
	
	# Calculate distance to target
	var distance = position.distance_to(target_position)
	
	# Only move if we're far enough from the target and not tweening
	if distance > min_distance and not is_tweening:
		# Smoothly interpolate to target position
		position = position.lerp(target_position, follow_speed * delta)

# Function to handle forced camera movement (for cutscenes, events, etc.)
func move_to_position(new_position: Vector2, duration: float = tween_duration):
	is_tweening = true
	
	# Create and configure tween
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	# Tween to new position
	tween.tween_property(self, "position", new_position, duration)
	
	# Connect to finished signal
	tween.finished.connect(_on_tween_finished)

# Called when forced movement tween finishes
func _on_tween_finished():
	is_tweening = false

# Function to shake the camera (for impacts, damage, etc.)
func shake(intensity: float = 5.0, duration: float = 0.5):
	var initial_position = position
	is_tweening = true
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_parallel(true)
	
	# Create a series of random offsets
	for i in range(10):
		var random_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(
			self, 
			"offset", 
			random_offset, 
			duration / 10.0
		)
	
	# Reset position
	tween.chain().tween_property(self, "offset", Vector2.ZERO, duration / 10.0)
	tween.finished.connect(_on_tween_finished)

# Function to focus on a specific point (for highlighting objects, areas, etc.)
func focus_on_point(point: Vector2, zoom_level: float = 1.2, duration: float = 0.5):
	is_tweening = true
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_parallel(true)
	
	# Tween position and zoom
	tween.tween_property(self, "position", point, duration)
	tween.tween_property(self, "zoom", Vector2(zoom_level, zoom_level), duration)
	
	tween.finished.connect(_on_tween_finished)

# Function to reset zoom level
func reset_zoom(duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(self, "zoom", Vector2.ONE, duration)

# Debug input for testing camera features
func _input(event):
	if event.is_action_pressed("test_camera_shake"):
		shake()
	elif event.is_action_pressed("test_camera_zoom"):
		focus_on_point(position, 1.5)
	elif event.is_action_pressed("test_camera_reset"):
		reset_zoom()
