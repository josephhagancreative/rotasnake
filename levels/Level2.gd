extends BaseLevel

# Level 2: Tail Danger - Narrow corridor forces tail awareness
# Teaches: Tail collision danger

func _ready():
	level_name = "Level 2: Watch Your Tail"
	snake_start_position = Vector2(150, 300)
	super._ready()
	
	hint_label.text = "Your tail follows you! Don't hit it when rotating!"
	
	create_level_geometry()

func create_level_geometry():
	var wall_positions = [
		# Outer boundaries
		[Vector2(50, 50), Vector2(974, 50)],
		[Vector2(50, 550), Vector2(974, 550)],
		[Vector2(50, 50), Vector2(50, 550)],
		[Vector2(974, 50), Vector2(974, 550)],
		
		# Narrow corridor that forces careful movement
		[Vector2(50, 200), Vector2(600, 200)],   # Top corridor wall
		[Vector2(50, 400), Vector2(600, 400)],   # Bottom corridor wall
		[Vector2(600, 200), Vector2(600, 250)],  # Small opening top
		[Vector2(600, 350), Vector2(600, 400)],  # Small opening bottom
		
		# Force player to navigate carefully
		[Vector2(700, 150), Vector2(700, 450)],
	]
	
	for wall_data in wall_positions:
		create_wall_line(wall_data[0], wall_data[1])

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