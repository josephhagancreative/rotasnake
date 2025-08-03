extends Node2D

# Simple test level to verify snake movement

func _ready():
	# Create a snake at the center of the screen
	var snake_scene = preload("res://Snake.tscn")
	var snake = snake_scene.instantiate()
	snake.position = Vector2(512, 300)  # Center of 1024x600 window
	add_child(snake)
	
	# Connect to snake's death signal
	snake.died.connect(_on_snake_died)
	
	# Add a simple boundary for visual reference
	create_boundary_walls()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event.is_action_pressed("ui_accept"):
		# Restart on Enter/Space
		get_tree().reload_current_scene()

func _on_snake_died():
	
func create_boundary_walls():
	# Just visual markers for now - we'll add proper walls in next step
	var lines = [
		[Vector2(100, 100), Vector2(924, 100)],  # Top
		[Vector2(100, 500), Vector2(924, 500)],  # Bottom
		[Vector2(100, 100), Vector2(100, 500)],  # Left
		[Vector2(924, 100), Vector2(924, 500)]   # Right
	]
	
	for line in lines:
		var line2d = Line2D.new()
		line2d.add_point(line[0])
		line2d.add_point(line[1])
		line2d.width = 4.0
		line2d.default_color = Color(0.5, 0.5, 0.5, 1.0)
		add_child(line2d)