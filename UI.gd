extends Control

# UI Element References using node paths
@onready var hp_bar = get_node_or_null("hp_bar")
@onready var mana_bar = get_node_or_null("mana_bar")
@onready var xp_bar = get_node_or_null("xp_bar")

# Progress Bar Settings
@export_group("Progress Bar Settings")
@export var vertical_bar_size: Vector2 = Vector2(20, 160)  # Thinner bars
@export var vertical_bar_margin: float = 20  # Top margin
@export var xp_bar_height: float = 8  # Increased height for better visibility
@export var bar_spacing: float = 8  # Closer spacing between bars

# Colors
@export_group("Color Settings")
@export var hp_color: Color = Color(0.8, 0.2, 0.2)  # Red
@export var mana_color: Color = Color(0.2, 0.2, 0.8)  # Blue
@export var xp_color: Color = Color(1, 1, 0.3)  # Gold/Yellow
@export var background_opacity: float = 0.8

func _ready():
	# Debug prints to check node initialization
	print("\n=== UI Debug Info ===")
	print("My name:", name)
	print("My path:", get_path())
	print("Parent node type:", get_parent().get_class())
	print("Parent name:", get_parent().name)
	
	# Set full rect anchors
	anchor_right = 1
	anchor_bottom = 1
	offset_right = 0
	offset_bottom = 0
	
	# Wait for the scene to be ready
	await get_tree().process_frame
	
	# Debug prints for each UI element
	print("\nUI Elements status:")
	print("hp_bar found:", hp_bar != null)
	print("mana_bar found:", mana_bar != null)
	print("xp_bar found:", xp_bar != null)
	
	setup_layout()
	setup_bar_styles()

func setup_layout():
	print("Setting up layout...")
	
	# Individual node checks
	if hp_bar == null:
		push_error("HP bar not initialized!")
		return
		
	if mana_bar == null:
		push_error("Mana bar not initialized!")
		return
		
	if xp_bar == null:
		push_error("XP bar not initialized!")
		return
	
	print("All UI elements found, proceeding with layout setup...")
	
	# Common margins
	var side_margin = 16
	
	# Position HP bar on the left
	hp_bar.size = vertical_bar_size
	hp_bar.position = Vector2(-32, 80)
	
	# Position Mana bar to the right of HP bar
	mana_bar.size = vertical_bar_size
	mana_bar.position = Vector2(-16, 80)
	
	# Setup XP bar with exact coordinates
	xp_bar.position = Vector2(-32, 200)
	xp_bar.custom_minimum_size = Vector2(208, xp_bar_height)  # 208 is the width from -32 to 176

func setup_bar_styles():
	setup_progress_bar(hp_bar, hp_color)
	setup_progress_bar(mana_bar, mana_color)
	setup_progress_bar(xp_bar, xp_color, true)

func setup_progress_bar(bar: ProgressBar, color: Color, is_xp: bool = false):
	if not is_instance_valid(bar):
		return
		
	# Background style
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, background_opacity)
	bg_style.set_border_width_all(2 if not is_xp else 1)
	bg_style.border_color = color
	
	if not is_xp:
		bg_style.corner_radius_top_left = 3
		bg_style.corner_radius_top_right = 3
		bg_style.corner_radius_bottom_left = 3
		bg_style.corner_radius_bottom_right = 3
	
	bar.add_theme_stylebox_override("background", bg_style)
	
	# Fill style
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = color
	
	if not is_xp:
		fill_style.corner_radius_top_left = 2
		fill_style.corner_radius_top_right = 2
		fill_style.corner_radius_bottom_left = 2
		fill_style.corner_radius_bottom_right = 2
	
	bar.add_theme_stylebox_override("fill", fill_style)
	
	# Set progress bar properties
	if is_xp:
		bar.fill_mode = 0  # Left to right
	else:
		bar.fill_mode = 2  # Bottom to top
	
	# Bar properties
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 100
	bar.show_percentage = false

# Update functions
func update_hp(value: float):
	if is_instance_valid(hp_bar):
		hp_bar.value = value

func update_mana(value: float):
	if is_instance_valid(mana_bar):
		mana_bar.value = value

func update_xp(value: float):
	if is_instance_valid(xp_bar):
		xp_bar.value = value
		print("XP bar updated to:", value)  # Debug print
		print("XP bar position:", xp_bar.position)  # Debug position
		print("XP bar size:", xp_bar.size)  # Debug size

# Window resize handling
func _notification(what: int):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		setup_layout()
