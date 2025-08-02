extends CharacterBody2D
class_name MovingObstacle

@export var move_speed = 100.0
@export var move_pattern = "horizontal"  # "horizontal", "vertical", "circular"
@export var move_distance = 200.0

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var hazard_area = $HazardArea

var start_position: Vector2
var time: float = 0.0
var direction: int = 1

func _ready():
	start_position = position
	
	# Set collision layers
	collision_layer = 8   # Layer 4 (hazards)
	collision_mask = 1    # Collide with layer 1 (snake)
	
	# Visual styling
	modulate = Color(1, 0.3, 0.3, 1)  # Red color for danger
	
	# Connect area for detection
	hazard_area.body_entered.connect(_on_body_entered)

func _physics_process(delta):
	time += delta
	
	match move_pattern:
		"horizontal":
			velocity.x = move_speed * direction
			if abs(position.x - start_position.x) > move_distance:
				direction *= -1
		
		"vertical":
			velocity.y = move_speed * direction
			if abs(position.y - start_position.y) > move_distance:
				direction *= -1
		
		"circular":
			var angle = time * move_speed * 0.01
			position = start_position + Vector2(
				cos(angle) * move_distance,
				sin(angle) * move_distance
			)
			velocity = Vector2.ZERO  # Don't use move_and_slide for circular
			return
	
	move_and_slide()
	
	# Rotate sprite for visual effect
	sprite.rotation += delta * 2.0

func _on_body_entered(body):
	if body.has_method("die"):
		body.die()