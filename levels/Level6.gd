extends BaseLevel

# Level 6: Spiral Challenge - Forces rotation management
# Challenge: Navigate spiral inward while managing tail rotation

func _ready():
	level_name = "Level 6: The Spiral"
	super._ready()
	
	hint_label.text = "Follow the spiral inward! Use rotation wisely!"
	
	create_level_geometry()

func create_level_geometry():
	# Outer boundaries first
	var wall_positions = [
		[Vector2(50, 50), Vector2(974, 50)],    # Top
		[Vector2(50, 550), Vector2(974, 550)],  # Bottom
		[Vector2(50, 50), Vector2(50, 550)],    # Left
		[Vector2(974, 50), Vector2(974, 550)],  # Right
	]
	
	for wall_data in wall_positions:
		create_wall_line(wall_data[0], wall_data[1])
	
	# Create spiral walls
	create_spiral()

func create_spiral():
	var center = Vector2(512, 300)
	var angle = 0.0
	var radius = 250.0
	var last_point = Vector2.ZERO
	var angle_step = 0.25  # Smaller step for smoother spiral
	var radius_step = 3.5  # How much radius decreases per step
	
	# Outer spiral wall
	while radius > 60:
		var point = center + Vector2(cos(angle), sin(angle)) * radius
		
		if last_point != Vector2.ZERO:
			create_wall_line(last_point, point)
		
		last_point = point
		angle += angle_step
		radius -= radius_step
	
	# Create inner spiral wall (with offset for passage)
	angle = 0.0
	radius = 220.0  # Start smaller for inner wall
	last_point = Vector2.ZERO
	
	while radius > 80:
		var point = center + Vector2(cos(angle + 3.14), sin(angle + 3.14)) * radius
		
		if last_point != Vector2.ZERO:
			create_wall_line(last_point, point)
		
		last_point = point
		angle += angle_step
		radius -= radius_step
	
	# Add some strategic gaps and obstacles for navigation challenge
	create_spiral_obstacles()

func create_spiral_obstacles():
	# Add small blocking walls at strategic spiral points to force rotation
	var center = Vector2(512, 300)
	
	# Obstacle 1: Mid-spiral blocker
	var angle1 = 4.0
	var radius1 = 150.0
	var point1 = center + Vector2(cos(angle1), sin(angle1)) * radius1
	var point2 = center + Vector2(cos(angle1), sin(angle1)) * (radius1 + 40)
	create_wall_line(point1, point2)
	
	# Obstacle 2: Outer spiral blocker
	var angle2 = 2.0
	var radius2 = 200.0
	var point3 = center + Vector2(cos(angle2), sin(angle2)) * radius2
	var point4 = center + Vector2(cos(angle2), sin(angle2)) * (radius2 + 35)
	create_wall_line(point3, point4)
	
	# Obstacle 3: Inner approach blocker
	var angle3 = 6.5
	var radius3 = 100.0
	var point5 = center + Vector2(cos(angle3), sin(angle3)) * radius3
	var point6 = center + Vector2(cos(angle3), sin(angle3)) * (radius3 + 30)
	create_wall_line(point5, point6)

func create_wall_line(start: Vector2, end: Vector2):
	# Visual representation
	var line = Line2D.new()
	line.add_point(start)
	line.add_point(end)
	line.width = 8.0
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