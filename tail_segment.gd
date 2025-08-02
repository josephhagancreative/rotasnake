extends Area2D
class_name TailSegment

@onready var sprite = $Sprite2D

func _ready():
	# Make the sprite circular for body segments
	if sprite:
		# Create a circular texture programmatically
		var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
		var center = Vector2(16, 16)
		var radius = 14.0
		
		# Draw a filled circle
		for x in range(32):
			for y in range(32):
				var distance = Vector2(x, y).distance_to(center)
				if distance <= radius:
					# White circle with full opacity
					image.set_pixel(x, y, Color.WHITE)
				else:
					# Transparent outside
					image.set_pixel(x, y, Color.TRANSPARENT)
		
		# Create texture from image
		var texture = ImageTexture.new()
		texture.set_image(image)
		sprite.texture = texture
		sprite.scale = Vector2(0.8, 0.8)  # Make it slightly smaller than head

# Called when the snake's head enters this tail segment
func _on_area_entered(area):
	# We'll connect this signal to detect self-collision
	pass

func set_segment_position(pos: Vector2):
	global_position = pos

func set_segment_rotation(rot: float):
	if sprite:
		sprite.rotation = rot
