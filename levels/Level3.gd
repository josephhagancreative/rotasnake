extends BaseLevel

# Level 3: Moving Danger - Introduction to moving obstacles
# Teaches: Timing and waiting (which triggers rotation)

var obstacle_scene = preload("res://MovingObstacle.tscn")

func _ready():
	level_name = "Level 3: Moving Hazards"
	snake_start_position = Vector2(150, 300)
	super._ready()
	
	hint_label.text = "Red obstacles will destroy you! Time your movement!"
	
	create_level_geometry()
	create_obstacles()

func create_level_geometry():
	var wall_positions = [
		# Outer boundaries
		[Vector2(50, 50), Vector2(974, 50)],
		[Vector2(50, 550), Vector2(974, 550)],
		[Vector2(50, 50), Vector2(50, 550)],
		[Vector2(974, 50), Vector2(974, 550)],
		
		# Simple layout with obstacle paths
		[Vector2(300, 50), Vector2(300, 250)],
		[Vector2(300, 350), Vector2(300, 550)],
		
		[Vector2(700, 50), Vector2(700, 250)],
		[Vector2(700, 350), Vector2(700, 550)],
	]
	
	for wall_data in wall_positions:
		create_wall_line(wall_data[0], wall_data[1])

func create_obstacles():
	# Horizontal moving obstacle in the middle gap
	var obstacle1 = obstacle_scene.instantiate()
	obstacle1.position = Vector2(500, 300)
	obstacle1.move_pattern = "horizontal"
	obstacle1.move_distance = 150
	obstacle1.move_speed = 80
	add_child(obstacle1)
	
	# Square obstacle orbiting around the goal area
	var obstacle2 = obstacle_scene.instantiate()
	obstacle2.position = Vector2(775, 225)  # Top-left corner of tighter orbit square
	obstacle2.move_pattern = "square"
	obstacle2.move_distance = 300  # Creates 150x150 square around goal with 25px clearance
	obstacle2.move_speed = 60
	add_child(obstacle2)
	
	# Debug: Log goal and obstacle positions
	print("=== LEVEL 3 DEBUG ===")
	print("Goal position: ", goal.position)
	print("Goal bounds: ", goal.position - Vector2(20, 20), " to ", goal.position + Vector2(20, 20))
	print("Goal + 25px clearance zone: ", goal.position - Vector2(45, 45), " to ", goal.position + Vector2(45, 45))
	print("Obstacle2 start: ", obstacle2.position)
	print("Obstacle2 move_distance: ", obstacle2.move_distance, " (half_dist: ", obstacle2.move_distance * 0.5, ")")
	var half_dist = obstacle2.move_distance * 0.5
	print("Square corners will be:")
	print("  1: ", obstacle2.position)
	print("  2: ", obstacle2.position + Vector2(half_dist, 0))
	print("  3: ", obstacle2.position + Vector2(half_dist, half_dist))
	print("  4: ", obstacle2.position + Vector2(0, half_dist))

func create_wall_line(start: Vector2, end: Vector2):
	var line = Line2D.new()
	line.add_point(start)
	line.add_point(end)
	line.width = 10.0
	line.default_color = Color(0.8, 0.2, 0.2, 1.0)  # Bright red walls
	add_child(line)
	
	var wall = StaticBody2D.new()
	wall.collision_layer = 4
	wall.collision_mask = 0
	
	var collision = CollisionShape2D.new()
	var shape = SegmentShape2D.new()
	shape.a = start
	shape.b = end
	collision.shape = shape
	
	wall.add_child(collision)
	add_child(wall)