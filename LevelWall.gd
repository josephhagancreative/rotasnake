@tool
extends Node2D
class_name LevelWall

@export var wall_length: float = 100.0 : set = set_wall_length
@export var wall_rotation: float = 0.0 : set = set_wall_rotation
@export var wall_width: float = 10.0 : set = set_wall_width
@export var wall_color: Color = Color(0.372549, 0.164706, 0.094118, 1) : set = set_wall_color

var line_visual: Line2D
var static_body: StaticBody2D
var collision_shape: CollisionShape2D
var segment_shape: SegmentShape2D

func _ready():
	# Create visual line and collision
	create_visual_line()

func set_wall_length(value: float):
	wall_length = value
	update_line_visual()
	update_collision()

func set_wall_rotation(value: float):
	wall_rotation = value
	rotation = deg_to_rad(wall_rotation)
	update_line_visual()
	update_collision()

func set_wall_width(value: float):
	wall_width = value
	if line_visual:
		line_visual.width = wall_width

func set_wall_color(value: Color):
	wall_color = value
	if line_visual:
		line_visual.default_color = wall_color

func create_visual_line():
	# Remove existing line if it exists
	if line_visual:
		line_visual.queue_free()
	
	# Create Line2D for visual representation
	line_visual = Line2D.new()
	line_visual.width = wall_width
	line_visual.default_color = wall_color
	add_child(line_visual)
	
	# Update line points and collision
	update_line_visual()
	setup_collision()

func update_line_visual():
	if line_visual and is_inside_tree():
		line_visual.clear_points()
		# Draw line centered on this node - simple horizontal line
		var half_length = wall_length / 2
		line_visual.add_point(Vector2(-half_length, 0))
		line_visual.add_point(Vector2(half_length, 0))
		line_visual.width = wall_width
		line_visual.default_color = wall_color

func setup_collision():
	# Create static body if it doesn't exist
	if not static_body:
		static_body = StaticBody2D.new()
		static_body.collision_layer = 4  # Walls layer
		static_body.collision_mask = 0
		add_child(static_body)
	
	# Create collision shape if it doesn't exist
	if not collision_shape:
		collision_shape = CollisionShape2D.new()
		segment_shape = SegmentShape2D.new()
		collision_shape.shape = segment_shape
		static_body.add_child(collision_shape)
	
	update_collision()

func update_collision():
	if segment_shape:
		# Collision shape centered on this node - simple horizontal line
		var half_length = wall_length / 2
		segment_shape.a = Vector2(-half_length, 0)
		segment_shape.b = Vector2(half_length, 0)