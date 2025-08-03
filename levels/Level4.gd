extends BaseLevel

# Level 4: Precision Corridors - Tight spaces requiring careful navigation
# Challenge: Navigate narrow zigzag paths while managing growing tail

func _ready():
	level_name = "Level 4: Tight Squeeze"
	super._ready()
	
	hint_label.text = "Navigate the narrow corridors! Watch your tail length!"
	
	create_level_geometry()

func create_level_geometry():
	var wall_positions = [
		# Outer boundaries
		[Vector2(50, 50), Vector2(974, 50)],    # Top
		[Vector2(50, 550), Vector2(974, 550)],  # Bottom
		[Vector2(50, 50), Vector2(50, 550)],    # Left
		[Vector2(974, 50), Vector2(974, 550)],  # Right
		
		# Zigzag corridor system creating tight passages
		[Vector2(200, 50), Vector2(200, 350)],   # First vertical wall
		[Vector2(200, 350), Vector2(400, 350)],  # First horizontal connector
		[Vector2(400, 150), Vector2(400, 350)],  # Second vertical wall (with gap at top)
		[Vector2(400, 150), Vector2(600, 150)],  # Second horizontal connector
		[Vector2(600, 150), Vector2(600, 450)],  # Third vertical wall (with gap at bottom)
		[Vector2(600, 450), Vector2(800, 450)],  # Third horizontal connector
		[Vector2(800, 250), Vector2(800, 450)],  # Fourth vertical wall (with gap at top)
		
		# Additional narrow passage walls to increase difficulty
		[Vector2(200, 450), Vector2(400, 450)],  # Bottom passage wall
		[Vector2(400, 450), Vector2(400, 550)],  # Connecting to bottom boundary
		[Vector2(600, 50), Vector2(600, 100)],   # Top passage wall
		[Vector2(800, 50), Vector2(800, 200)],   # Final top wall section
		
		# Additional tight spots to challenge tail management
		[Vector2(150, 200), Vector2(200, 200)],  # Entry constriction
		[Vector2(300, 250), Vector2(350, 250)],  # Mid-path obstacle
		[Vector2(500, 300), Vector2(550, 300)],  # Another tight spot
		[Vector2(700, 200), Vector2(750, 200)],  # Near-goal obstacle
	]
	
	for wall_data in wall_positions:
		create_wall_line(wall_data[0], wall_data[1])

func create_wall_line(start: Vector2, end: Vector2):
	# Visual representation
	var line = Line2D.new()
	line.add_point(start)
	line.add_point(end)
	line.width = 10.0
	line.default_color = Color(0.8, 0.2, 0.2, 1.0)  # Bright red walls
	add_child(line)
	
	# Create collision
	var wall = StaticBody2D.new()
	wall.collision_layer = 4  # Layer 3 (walls)
	wall.collision_mask = 0
	
	var collision = CollisionShape2D.new()
	var shape = SegmentShape2D.new()
	shape.a = start
	shape.b = end
	collision.shape = shape
	
	wall.add_child(collision)
	add_child(wall)