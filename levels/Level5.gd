extends BaseLevel

# Level 5: Obstacle Gauntlet - Multiple moving hazards
# Challenge: Timing through multiple obstacles with different patterns

var obstacle_scene = preload("res://MovingObstacle.tscn")

func _ready():
	level_name = "Level 5: Danger Zone"
	super._ready()
	
	hint_label.text = "Time your movements carefully! Multiple hazards ahead!"
	
	create_level_geometry()
	create_obstacles()

func create_level_geometry():
	var wall_positions = [
		# Outer boundaries
		[Vector2(50, 50), Vector2(974, 50)],    # Top
		[Vector2(50, 550), Vector2(974, 550)],  # Bottom
		[Vector2(50, 50), Vector2(50, 550)],    # Left
		[Vector2(974, 50), Vector2(974, 550)],  # Right
		
		# Three chambers design
		[Vector2(300, 50), Vector2(300, 250)],   # Chamber 1 - top wall
		[Vector2(300, 350), Vector2(300, 550)],  # Chamber 1 - bottom wall
		[Vector2(600, 50), Vector2(600, 250)],   # Chamber 2 - top wall
		[Vector2(600, 350), Vector2(600, 550)],  # Chamber 2 - bottom wall
	]
	
	for wall_data in wall_positions:
		create_wall_line(wall_data[0], wall_data[1])

func create_obstacles():
	# Chamber 1: Single vertical obstacle
	var obs1 = obstacle_scene.instantiate()
	obs1.position = Vector2(175, 300)
	obs1.move_pattern = "vertical"
	obs1.move_distance = 100
	obs1.move_speed = 120
	add_child(obs1)
	
	# Chamber 2: Two crossing vertical obstacles
	var obs2 = obstacle_scene.instantiate()
	obs2.position = Vector2(450, 200)
	obs2.move_pattern = "vertical"
	obs2.move_distance = 150
	obs2.move_speed = 100
	add_child(obs2)
	
	var obs3 = obstacle_scene.instantiate()
	obs3.position = Vector2(450, 400)
	obs3.move_pattern = "vertical"
	obs3.move_distance = 150
	obs3.move_speed = 100
	obs3.direction = -1  # Start moving opposite direction
	add_child(obs3)
	
	# Chamber 3: Circular obstacle around goal area
	var obs4 = obstacle_scene.instantiate()
	obs4.position = Vector2(750, 300)
	obs4.move_pattern = "circular"
	obs4.move_distance = 80
	obs4.move_speed = 80
	add_child(obs4)
	
	# Additional horizontal obstacle for extra challenge
	var obs5 = obstacle_scene.instantiate()
	obs5.position = Vector2(700, 150)
	obs5.move_pattern = "horizontal"
	obs5.move_distance = 120
	obs5.move_speed = 90
	add_child(obs5)

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