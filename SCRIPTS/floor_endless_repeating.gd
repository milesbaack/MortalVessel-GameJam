extends Node2D

@export var ground_speed = 300
@export var tree_speed = 200  # Slower for parallax effect
const TILEMAP_HEIGHT = 256

var floor_tilemaps = []
var tree_tilemaps = []

func _ready():
	floor_tilemaps = [$green_forest_floor, $green_forest_floor_copy]
	tree_tilemaps = [$green_trees, $green_trees_copy]
	
	# Position second tilemaps above first ones
	floor_tilemaps[1].position.y = -TILEMAP_HEIGHT
	tree_tilemaps[1].position.y = -TILEMAP_HEIGHT
	
	# Add subtle variation to trees
	for tilemap in tree_tilemaps:
		tilemap.modulate.a = 0.9  # Slight transparency
		
		var used_cells = tilemap.get_used_cells(0)  # Using layer 0
		for cell in used_cells:
			if randi() % 2 == 0:  # 50% chance for each tree
				tilemap.position.y += 1

func _process(delta):
	var ground_movement = ground_speed * delta
	var tree_movement = tree_speed * delta
	
	# Update ground tilemaps
	for tilemap in floor_tilemaps:
		tilemap.position.y += ground_movement
		if tilemap.position.y >= TILEMAP_HEIGHT:
			tilemap.position.y -= TILEMAP_HEIGHT * 2
	
	# Update tree tilemaps
	for tilemap in tree_tilemaps:
		tilemap.position.y += tree_movement
		if tilemap.position.y >= TILEMAP_HEIGHT:
			tilemap.position.y -= TILEMAP_HEIGHT * 2
