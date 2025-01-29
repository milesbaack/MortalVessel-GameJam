# green_forest_level_1.gd
extends Node2D

func _ready():
	$ObjectPoolEnemySpawner.start_spawning()
	
