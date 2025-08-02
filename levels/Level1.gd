extends BaseLevel

# Level 1: Introduction - Simple path to goal
# Teaches: Basic movement and goal

func _ready():
	level_name = "Level 1: First Steps"
	super._ready()
	
	# Set hint
	hint_label.text = "Use arrow keys to move. Reach the yellow goal!"
	
	# Create simple walls
	create_level_geometry()

func create_level_geometry():
	# Create boundary walls using Line2D for now
	# In production, you'd use TileMap or StaticBody2D nodes
	
	var wall_positions = [
		# Outer boundaries
		[Vector2(50, 50), Vector2(974, 50)],    # Top
		[Vector2(50, 550), Vector2(974, 550)],  # Bottom
		[Vector2(50, 50), Vector2(50, 550)],    # Left
		[Vector2(974, 50), Vector2(974, 550)],  # Right
		
		# Simple maze walls
		[Vector2(300, 50), Vector2(300, 400)],   # Vertical wall 1
		[Vector2(500, 200), Vector2(500, 550)],  # Vertical wall 2
		[Vector2(700, 50), Vector2(700, 400)],   # Vertical wall 3
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
	wall.collision_layer = 4  # Layer 3 (walls) - using bit 4 which is 2^2 = layer 3
	wall.collision_mask = 0
	
	var collision = CollisionShape2D.new()
	var shape = SegmentShape2D.new()
	shape.a = start
	shape.b = end
	collision.shape = shape
	
	wall.add_child(collision)
	add_child(wall)