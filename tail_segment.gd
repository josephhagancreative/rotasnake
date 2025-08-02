extends Area2D
class_name TailSegment

@onready var sprite = $Sprite2D

# Called when the snake's head enters this tail segment
func _on_area_entered(area):
	# We'll connect this signal to detect self-collision
	pass

func set_segment_position(pos: Vector2):
	global_position = pos

func set_segment_rotation(rot: float):
	if sprite:
		sprite.rotation = rot
