extends BaseLevel

# Level 7: Timing Puzzle - Synchronized obstacles
# Challenge: Wait for perfect timing, manage rotation while waiting

var obstacle_scene = preload("res://MovingObstacle.tscn")

func _ready():
	level_name = "Level 7: Synchronicity"
	super._ready()
	
	hint_label.text = "Watch the pattern and wait for your moment!"
	
	create_level_geometry()
	create_obstacles()

func create_level_geometry():
	var wall_positions = [
		# Outer boundaries
		[Vector2(50, 50), Vector2(974, 50)],    # Top
		[Vector2(50, 550), Vector2(974, 550)],  # Bottom
		[Vector2(50, 50), Vector2(50, 550)],    # Left
		[Vector2(974, 50), Vector2(974, 550)],  # Right
		
		# Create narrow corridor with timing sections
		[Vector2(200, 150), Vector2(800, 150)],  # Top corridor wall
		[Vector2(200, 450), Vector2(800, 450)],  # Bottom corridor wall
		
		# Entrance walls
		[Vector2(200, 150), Vector2(200, 200)],  # Top entrance wall
		[Vector2(200, 400), Vector2(200, 450)],  # Bottom entrance wall
		
		# Exit walls
		[Vector2(800, 150), Vector2(800, 200)],  # Top exit wall
		[Vector2(800, 400), Vector2(800, 450)],  # Bottom exit wall
		
		# Additional waiting chambers
		[Vector2(150, 200), Vector2(200, 200)],  # Entry chamber top
		[Vector2(150, 400), Vector2(200, 400)],  # Entry chamber bottom
		[Vector2(800, 200), Vector2(850, 200)],  # Exit chamber top
		[Vector2(800, 400), Vector2(850, 400)],  # Exit chamber bottom
	]
	
	for wall_data in wall_positions:
		create_wall_line(wall_data[0], wall_data[1])

func create_obstacles():
	# Create synchronized vertical obstacles across the corridor
	for i in range(5):
		var obs = obstacle_scene.instantiate()
		obs.position = Vector2(300 + i * 100, 300)
		obs.move_pattern = "vertical"
		obs.move_distance = 100
		obs.move_speed = 90
		
		# Alternate starting directions for complex patterns
		obs.direction = 1 if i % 2 == 0 else -1
		add_child(obs)
	
	# Add additional obstacles for more complex timing
	# Fast horizontal obstacle at entrance
	var entrance_obs = obstacle_scene.instantiate()
	entrance_obs.position = Vector2(175, 250)
	entrance_obs.move_pattern = "vertical"
	entrance_obs.move_distance = 80
	entrance_obs.move_speed = 130
	add_child(entrance_obs)
	
	# Slow horizontal obstacle at exit
	var exit_obs = obstacle_scene.instantiate()
	exit_obs.position = Vector2(825, 350)
	exit_obs.move_pattern = "vertical"
	exit_obs.move_distance = 80
	exit_obs.move_speed = 70
	add_child(exit_obs)
	
	# Cross-pattern obstacle for extra timing challenge
	var cross_obs = obstacle_scene.instantiate()
	cross_obs.position = Vector2(500, 200)
	cross_obs.move_pattern = "horizontal"
	cross_obs.move_distance = 120
	cross_obs.move_speed = 110
	add_child(cross_obs)

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