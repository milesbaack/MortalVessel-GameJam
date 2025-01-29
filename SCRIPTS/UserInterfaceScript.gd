extends Control

# UI Element References
@onready var XP_bar = $XP_bar
@onready var Vessel_Icon = $Vessel_Icon
@onready var hp_bar = $hp_bar
@onready var mana_bar = $mana_bar

# Vessel Icon Settings
@export_group("Vessel Icon Settings")
@export var icon_size: Vector2 = Vector2(64, 64)
@export var icon_position: Vector2 = Vector2(20, 20)

# Progress Bar Settings
@export_group("Progress Bar Settings")
@export var bar_size: Vector2 = Vector2(30, 150)
@export var hp_bar_position: Vector2 = Vector2(20, 100)
@export var mana_bar_position: Vector2 = Vector2(60, 100)
@export var bar_spacing: float = 40

# Colors
@export_group("Color Settings")
@export var hp_color: Color = Color(0.8, 0.2, 0.2)  # Red
@export var mana_color: Color = Color(0.2, 0.2, 0.8)  # Blue
@export var xp_color: Color = Color(1, 1, 0.3)  # Gold/Yellow for XP
@export var background_opacity: float = 0.8

func _ready():
	# Wait a frame to ensure all nodes are ready
	await get_tree().process_frame
	setup_layout()
	setup_bar_styles()

func setup_layout():
	if not is_instance_valid(Vessel_Icon) or not is_instance_valid(hp_bar) or not is_instance_valid(mana_bar):
		return
	
	size = Vector2(2560, 1600)
	
	# Use Vessel_Icon instead of vessel_icon
	Vessel_Icon.custom_minimum_size = icon_size
	Vessel_Icon.position = icon_position
	
	hp_bar.size = bar_size
	mana_bar.size = bar_size
	
	hp_bar.position = hp_bar_position
	mana_bar.position = Vector2(
		hp_bar_position.x + bar_spacing, 
		hp_bar_position.y
	)
	
	# XP Bar Setup
	if is_instance_valid(XP_bar):
		XP_bar.custom_minimum_size = Vector2(224, 10)  # Full width, 2px height
		XP_bar.position = Vector2(-40, 208)  # 2px from bottom

func setup_bar_styles():
	if not is_instance_valid(hp_bar) or not is_instance_valid(mana_bar):
		return
		
	# HP Bar
	var hp_style = StyleBoxFlat.new()
	hp_style.bg_color = Color(0.2, 0.2, 0.2, background_opacity)
	hp_style.set_border_width_all(2)
	hp_style.border_color = hp_color
	hp_bar.add_theme_stylebox_override("background", hp_style)
	
	var hp_fill = StyleBoxFlat.new()
	hp_fill.bg_color = hp_color
	hp_fill.set_border_width_all(0)
	hp_bar.add_theme_stylebox_override("fill", hp_fill)
	
	# Mana Bar
	var mana_style = StyleBoxFlat.new()
	mana_style.bg_color = Color(0.2, 0.2, 0.2, background_opacity)
	mana_style.set_border_width_all(2)
	mana_style.border_color = mana_color
	mana_bar.add_theme_stylebox_override("background", mana_style)
	
	var mana_fill = StyleBoxFlat.new()
	mana_fill.bg_color = mana_color
	mana_fill.set_border_width_all(0)
	mana_bar.add_theme_stylebox_override("fill", mana_fill)
	
	# XP Bar
	if is_instance_valid(XP_bar):
		var xp_style = StyleBoxFlat.new()
		xp_style.bg_color = Color(0.2, 0.2, 0.2, background_opacity)
		xp_style.set_border_width_all(1)
		xp_style.border_color = xp_color
		XP_bar.add_theme_stylebox_override("background", xp_style)
		
		var xp_fill = StyleBoxFlat.new()
		xp_fill.bg_color = xp_color
		xp_fill.set_border_width_all(0)
		XP_bar.add_theme_stylebox_override("fill", xp_fill)
		
		# XP Bar properties
		XP_bar.max_value = 100
		XP_bar.value = 0
		XP_bar.show_percentage = false
	
	# Set vertical fill mode
	hp_bar.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
	mana_bar.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
	
	# Initial values
	hp_bar.max_value = 100
	hp_bar.value = 100
	mana_bar.max_value = 100
	mana_bar.value = 100

# Update functions
func update_hp(value: float):
	hp_bar.value = value

func update_mana(value: float):
	mana_bar.value = value

func update_xp(value: float):
	if is_instance_valid(XP_bar):
		XP_bar.value = value

func update_vessel_icon(texture: Texture2D):
	Vessel_Icon.texture = texture
