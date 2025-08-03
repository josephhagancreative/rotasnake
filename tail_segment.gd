extends Area2D
class_name TailSegment

@onready var sprite = $Sprite2D

func _ready():
	# Use the actual sprite artwork instead of generating a circle
	if sprite:
		sprite.scale = Vector2(0.8, 0.8)  # Make it slightly smaller than head

# Called when the snake's head enters this tail segment
func _on_area_entered(area):
	# We'll connect this signal to detect self-collision
	pass

func set_segment_position(pos: Vector2):
	global_position = pos

func set_segment_rotation(rot: float):
	if sprite:
		# Apply same rotation offset as the head sprite
		sprite.rotation = rot - PI/2
