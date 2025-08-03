@tool
extends Node2D
class_name MovingObstaclePlacement

@export var move_pattern: String = "horizontal" : set = set_move_pattern
@export var move_speed: float = 100.0 : set = set_move_speed
@export var move_distance: float = 200.0 : set = set_move_distance
@export var obstacle_color: Color = Color(1, 0.3, 0.3, 1) : set = set_obstacle_color

var obstacle_scene = preload("res://MovingObstacle.tscn")
var path_line: Line2D
var center_sprite: Sprite2D

func _ready():
	if Engine.is_editor_hint():
		create_visual_indicators()
	else:
		# In game, spawn the actual obstacle after a brief delay to ensure scene is ready
		call_deferred("spawn_obstacle")

func set_move_pattern(value: String):
	move_pattern = value
	if Engine.is_editor_hint():
		update_path_visualization()

func set_move_speed(value: float):
	move_speed = value
	if Engine.is_editor_hint():
		update_path_visualization()

func set_move_distance(value: float):
	move_distance = value
	if Engine.is_editor_hint():
		update_path_visualization()

func set_obstacle_color(value: Color):
	obstacle_color = value
	if Engine.is_editor_hint():
		update_visual_color()

func create_visual_indicators():
	# Remove existing visuals
	if path_line:
		path_line.queue_free()
	if center_sprite:
		center_sprite.queue_free()
	
	# Create center position indicator
	center_sprite = Sprite2D.new()
	var center_texture = ImageTexture.new()
	var center_image = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	center_image.fill(obstacle_color)
	center_texture.set_image(center_image)
	center_sprite.texture = center_texture
	add_child(center_sprite)
	
	# Create path visualization
	path_line = Line2D.new()
	path_line.width = 3.0
	path_line.default_color = Color(obstacle_color.r, obstacle_color.g, obstacle_color.b, 0.6)
	add_child(path_line)
	
	update_path_visualization()

func update_path_visualization():
	if not path_line or not is_inside_tree():
		return
	
	path_line.clear_points()
	
	match move_pattern:
		"horizontal":
			# Show horizontal line
			path_line.add_point(Vector2(-move_distance, 0))
			path_line.add_point(Vector2(move_distance, 0))
		
		"vertical":
			# Show vertical line
			path_line.add_point(Vector2(0, -move_distance))
			path_line.add_point(Vector2(0, move_distance))
		
		"circular":
			# Show circular path
			var points = 32
			for i in range(points + 1):
				var angle = (i * 2.0 * PI) / points
				var point = Vector2(
					cos(angle) * move_distance,
					sin(angle) * move_distance
				)
				path_line.add_point(point)
		
		"square":
			# Show square path
			var half_dist = move_distance * 0.5
			path_line.add_point(Vector2(-half_dist, -half_dist))
			path_line.add_point(Vector2(half_dist, -half_dist))
			path_line.add_point(Vector2(half_dist, half_dist))
			path_line.add_point(Vector2(-half_dist, half_dist))
			path_line.add_point(Vector2(-half_dist, -half_dist))

func update_visual_color():
	if center_sprite:
		var center_texture = ImageTexture.new()
		var center_image = Image.create(24, 24, false, Image.FORMAT_RGBA8)
		center_image.fill(obstacle_color)
		center_texture.set_image(center_image)
		center_sprite.texture = center_texture
	
	if path_line:
		path_line.default_color = Color(obstacle_color.r, obstacle_color.g, obstacle_color.b, 0.6)

func spawn_obstacle():
	# Create the actual moving obstacle during gameplay
	if not obstacle_scene:
		push_error("MovingObstaclePlacement: obstacle_scene is null")
		return
	
	var obstacle_instance = obstacle_scene.instantiate()
	if not obstacle_instance:
		push_error("MovingObstaclePlacement: Failed to instantiate obstacle")
		return
	
	obstacle_instance.position = global_position
	obstacle_instance.move_pattern = move_pattern
	obstacle_instance.move_speed = move_speed
	obstacle_instance.move_distance = move_distance
	obstacle_instance.modulate = obstacle_color
	
	# Add to parent scene
	var parent = get_parent()
	if parent:
		parent.add_child(obstacle_instance)
	else:
		push_error("MovingObstaclePlacement: No parent found")