@tool
extends StaticBody2D
class_name LevelWall

@export var start_point: Vector2 = Vector2.ZERO : set = set_start_point
@export var end_point: Vector2 = Vector2(100, 0) : set = set_end_point
@export var wall_width: float = 10.0 : set = set_wall_width
@export var wall_color: Color = Color(1, 0, 0, 1) : set = set_wall_color

var line_visual: Line2D
var collision_shape: CollisionShape2D
var segment_shape: SegmentShape2D

func _ready():
	# Set collision layer to walls (layer 3)
	collision_layer = 4
	collision_mask = 0
	
	# Create visual line and collision in both editor and game
	create_visual_line()

func set_start_point(value: Vector2):
	start_point = value
	if Engine.is_editor_hint():
		update_line_visual()
		update_collision()

func set_end_point(value: Vector2):
	end_point = value
	if Engine.is_editor_hint():
		update_line_visual()
		update_collision()

func set_wall_width(value: float):
	wall_width = value
	if Engine.is_editor_hint():
		update_line_visual()

func set_wall_color(value: Color):
	wall_color = value
	if Engine.is_editor_hint():
		update_line_visual()

func create_visual_line():
	# Remove existing line if it exists
	if line_visual:
		line_visual.queue_free()
	
	# Create Line2D for visual representation in both editor and game
	line_visual = Line2D.new()
	line_visual.width = wall_width
	line_visual.default_color = wall_color
	line_visual.add_point(start_point)
	line_visual.add_point(end_point)
	add_child(line_visual)
	
	# Also setup collision
	setup_collision()

func update_line_visual():
	if line_visual and is_inside_tree():
		line_visual.clear_points()
		line_visual.add_point(start_point)
		line_visual.add_point(end_point)
		line_visual.width = wall_width
		line_visual.default_color = wall_color

func setup_collision():
	# Create collision shape if it doesn't exist
	if not collision_shape:
		collision_shape = CollisionShape2D.new()
		segment_shape = SegmentShape2D.new()
		collision_shape.shape = segment_shape
		add_child(collision_shape)
	
	update_collision()

func update_collision():
	if segment_shape:
		segment_shape.a = start_point
		segment_shape.b = end_point

func get_wall_length() -> float:
	return start_point.distance_to(end_point)

func get_wall_center() -> Vector2:
	return (start_point + end_point) / 2