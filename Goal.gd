extends Area2D
class_name Goal

@onready var color_rect = $ColorRect
@onready var collision = $CollisionShape2D

var time = 0.0

func _ready():
	# Set collision layers
	collision_layer = 32  # Layer 6
	collision_mask = 1    # Detect layer 1 (snake head)

func _process(delta):
	time += delta
	# Simple pulsing animation
	var scale_factor = 1.0 + sin(time * 3.0) * 0.2
	scale = Vector2(scale_factor, scale_factor)
	
	# Rotate slowly
	rotation += delta * 0.5