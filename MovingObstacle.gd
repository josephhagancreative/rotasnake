extends CharacterBody2D
class_name MovingObstacle

@export var move_speed = 100.0
@export var move_pattern = "horizontal"  # "horizontal", "vertical", "circular", "square"
@export var move_distance = 200.0

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var hazard_area = $HazardArea

var start_position: Vector2
var time: float = 0.0
var direction: int = 1
var square_phase: int = 0  # 0=right, 1=down, 2=left, 3=up
var phase_distance: float = 0.0

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
			if abs(position.x - start_position.x) >= move_distance:
				direction *= -1
			velocity.x = move_speed * direction
			velocity.y = 0
		
		"vertical":
			if abs(position.y - start_position.y) >= move_distance:
				direction *= -1
			velocity.y = move_speed * direction
			velocity.x = 0
		
		"circular":
			var angle = time * move_speed * 0.01
			position = start_position + Vector2(
				cos(angle) * move_distance,
				sin(angle) * move_distance
			)
			velocity = Vector2.ZERO  # Don't use move_and_slide for circular
			return
		
		"square":
			var half_dist = move_distance * 0.5
			match square_phase:
				0:  # Moving right
					velocity.x = move_speed
					velocity.y = 0
					phase_distance += move_speed * delta
					if phase_distance >= half_dist:
						square_phase = 1
						phase_distance = 0.0
				1:  # Moving down
					velocity.x = 0
					velocity.y = move_speed
					phase_distance += move_speed * delta
					if phase_distance >= half_dist:
						square_phase = 2
						phase_distance = 0.0
				2:  # Moving left
					velocity.x = -move_speed
					velocity.y = 0
					phase_distance += move_speed * delta
					if phase_distance >= half_dist:
						square_phase = 3
						phase_distance = 0.0
				3:  # Moving up
					velocity.x = 0
					velocity.y = -move_speed
					phase_distance += move_speed * delta
					if phase_distance >= half_dist:
						square_phase = 0
						phase_distance = 0.0
	
	move_and_slide()
	
	# Rotate sprite for visual effect
	sprite.rotation += delta * 2.0

func _on_body_entered(body):
	if body.has_method("die"):
		body.die()