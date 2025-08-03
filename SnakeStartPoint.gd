@tool
extends Node2D
class_name SnakeStartPoint

@export var facing_direction: Vector2 = Vector2.RIGHT : set = set_facing_direction
var arrow_sprite: Sprite2D
var circle_sprite: Sprite2D

func _ready():
	# Only create visual indicators in the editor
	if Engine.is_editor_hint():
		create_visual_indicators()
		update_arrow_rotation()

func set_facing_direction(value: Vector2):
	facing_direction = value
	# Update arrow when direction changes in editor
	if Engine.is_editor_hint():
		update_arrow_rotation()

func create_visual_indicators():
	# Remove any existing visuals first
	if circle_sprite:
		circle_sprite.queue_free()
	if arrow_sprite:
		arrow_sprite.queue_free()
	
	# Create circle to indicate position
	circle_sprite = Sprite2D.new()
	var circle_texture = ImageTexture.new()
	var circle_image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	circle_image.fill(Color(0, 1, 0, 0.7))  # Green circle
	circle_texture.set_image(circle_image)
	circle_sprite.texture = circle_texture
	add_child(circle_sprite)
	
	# Create arrow to indicate direction
	arrow_sprite = Sprite2D.new()
	var arrow_texture = ImageTexture.new()
	var arrow_image = Image.create(48, 24, false, Image.FORMAT_RGBA8)
	arrow_image.fill(Color.TRANSPARENT)
	
	# Draw simple arrow shape
	for x in range(0, 36):
		for y in range(10, 14):
			arrow_image.set_pixel(x, y, Color(1, 1, 0, 1.0))  # Yellow arrow body
	
	# Arrow head
	for i in range(8):
		for y in range(6 + i, 18 - i):
			arrow_image.set_pixel(36 + i, y, Color(1, 1, 0, 1.0))
	
	arrow_texture.set_image(arrow_image)
	arrow_sprite.texture = arrow_texture
	arrow_sprite.position.x = 24  # Offset from center
	add_child(arrow_sprite)

func update_arrow_rotation():
	if arrow_sprite and is_inside_tree():
		arrow_sprite.rotation = facing_direction.angle()

func get_start_position() -> Vector2:
	return global_position

func get_facing_direction() -> Vector2:
	# Apply the node's rotation to the facing direction
	var rotated_direction = facing_direction.rotated(rotation)
	return rotated_direction.normalized()