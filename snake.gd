extends CharacterBody2D
class_name Snake

# Movement constants
const MOVE_SPEED = 200.0
const ROTATION_SPEED = 1.5  # Radians per second (about 86 degrees/sec)
const ROTATION_RADIUS = 50.0  # Distance from center when rotating

# Tail constants
const SEGMENT_DISTANCE = 25.0  # Distance between segments
const POSITION_HISTORY_SIZE = 300  # How many positions to remember
const HISTORY_RECORD_INTERVAL = 0.02  # How often to record position (seconds)

# State management
enum State { MOVING, ROTATING }
var current_state = State.ROTATING
var movement_direction = Vector2.ZERO
var rotation_angle = 0.0
var rotation_center = Vector2.ZERO

# Input buffering for most recent input priority
var input_queue = []
var max_input_queue_size = 4

# Tail management
var tail_segments = []
var position_history = []
var history_timer = 0.0
var tail_length = 5  # Start with 5 segments

# Visual
@onready var sprite = $Sprite2D
@onready var head_area = $HeadArea

# Signals
signal died()

var tail_segment_scene = preload("res://TailSegment.tscn")

func _ready():
	# Set initial movement direction for smooth rotation start
	movement_direction = Vector2(1, 0)  # Start facing right
	
	# Set initial rotation center based on default direction (clockwise rotation)
	var perpendicular = Vector2(movement_direction.y, -movement_direction.x)
	rotation_center = global_position + perpendicular * ROTATION_RADIUS
	rotation_angle = atan2(global_position.y - rotation_center.y, global_position.x - rotation_center.x)
	
	# Set initial sprite rotation to face the starting direction
	sprite.rotation = movement_direction.angle()
	
	# Initialize position history with starting positions
	for i in range(POSITION_HISTORY_SIZE):
		position_history.append({
			"position": global_position,
			"rotation": movement_direction.angle()
		})
	
	# Create initial tail segments
	create_tail_segments()
	
	# Connect head area for self-collision detection
	head_area.area_entered.connect(_on_head_area_entered)

func _physics_process(delta):
	# Record position history
	update_position_history(delta)
	
	match current_state:
		State.MOVING:
			handle_movement(delta)
		State.ROTATING:
			handle_rotation(delta)
	
	# Update tail positions
	update_tail_positions()
	
	# Check for input to switch states
	check_input()

func handle_movement(delta):
	# Move in the current direction
	velocity = movement_direction * MOVE_SPEED
	move_and_slide()
	
	# Check for wall collisions
	if is_on_wall():
		die()
		return
	
	# Update sprite rotation to face movement direction
	if movement_direction.length() > 0:
		sprite.rotation = movement_direction.angle()

func handle_rotation(delta):
	# Rotate around the center point
	rotation_angle += ROTATION_SPEED * delta
	
	# Calculate new position on the circle
	var offset = Vector2(
		cos(rotation_angle) * ROTATION_RADIUS,
		sin(rotation_angle) * ROTATION_RADIUS
	)
	
	# Store old position for collision check
	var old_position = global_position
	global_position = rotation_center + offset
	
	# Check for collisions using move_and_collide with zero vector
	var collision = move_and_collide(Vector2.ZERO, true)
	if collision:
		global_position = old_position  # Restore position
		die()
		return
	
	# Make sprite face the direction of rotation
	sprite.rotation = rotation_angle + PI/2

func _input(event):
	# Track individual key presses for input priority
	if event.is_action_pressed("ui_up"):
		add_to_input_queue("ui_up")
	elif event.is_action_pressed("ui_down"):
		add_to_input_queue("ui_down")
	elif event.is_action_pressed("ui_left"):
		add_to_input_queue("ui_left")
	elif event.is_action_pressed("ui_right"):
		add_to_input_queue("ui_right")
	
	# Remove released keys from queue
	if event.is_action_released("ui_up"):
		remove_from_input_queue("ui_up")
	elif event.is_action_released("ui_down"):
		remove_from_input_queue("ui_down")
	elif event.is_action_released("ui_left"):
		remove_from_input_queue("ui_left")
	elif event.is_action_released("ui_right"):
		remove_from_input_queue("ui_right")

func add_to_input_queue(action: String):
	# Remove if already in queue (move to front)
	input_queue.erase(action)
	# Add to front (most recent)
	input_queue.push_front(action)
	# Limit queue size
	if input_queue.size() > max_input_queue_size:
		input_queue.pop_back()

func remove_from_input_queue(action: String):
	input_queue.erase(action)

func get_priority_input_vector() -> Vector2:
	# Return direction of most recent input that's still held
	for action in input_queue:
		if Input.is_action_pressed(action):
			match action:
				"ui_up":
					return Vector2(0, -1)
				"ui_down":
					return Vector2(0, 1)
				"ui_left":
					return Vector2(-1, 0)
				"ui_right":
					return Vector2(1, 0)
	return Vector2.ZERO

func check_input():
	# Use priority-based input instead of axis input
	var input_vector = get_priority_input_vector()
	
	# If there's input and we're rotating, switch to moving
	if input_vector.length() > 0 and current_state == State.ROTATING:
		current_state = State.MOVING
		movement_direction = input_vector
		
		# Smooth transition: maintain current rotation angle for sprite consistency
		# The sprite rotation will be updated in handle_movement()
		rotation_angle = movement_direction.angle()
	
	# If no input and we're moving, switch to rotating
	elif input_vector.length() == 0 and current_state == State.MOVING:
		current_state = State.ROTATING
		
		# Start rotation from the movement direction angle
		# Up = -PI/2, Right = 0, Down = PI/2, Left = PI
		rotation_angle = movement_direction.angle()
		
		# Calculate rotation center so that current position is on the circle at the movement angle
		rotation_center = global_position - Vector2(cos(rotation_angle), sin(rotation_angle)) * ROTATION_RADIUS
	
	# Update movement direction while moving (for direction changes)
	elif input_vector.length() > 0 and current_state == State.MOVING:
		if movement_direction != input_vector:
			movement_direction = input_vector

func get_current_state():
	return current_state

func die():
	# Called when snake hits something
	print("Snake died!")
	died.emit()
	set_physics_process(false)  # Stop movement
	
	# Enhanced visual feedback
	modulate = Color(1, 0.3, 0.3, 1.0)
	
	# Add death animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color(1, 0, 0, 0.5), 0.5)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.3)
	tween.tween_property(self, "rotation", PI/4, 0.5)
	
	# Clean up tail with delay
	for segment in tail_segments:
		segment.modulate = Color(1, 0.3, 0.3, 1.0)
		segment.queue_free()

# New tail-related functions
func create_tail_segments():
	for i in range(tail_length):
		var segment = tail_segment_scene.instantiate()
		tail_segments.append(segment)
		get_parent().call_deferred("add_child", segment)

func update_position_history(delta):
	history_timer += delta
	
	if history_timer >= HISTORY_RECORD_INTERVAL:
		history_timer = 0.0
		
		# Add new position to front
		position_history.push_front({
			"position": global_position,
			"rotation": sprite.rotation
		})
		
		# Remove old positions if we exceed the limit
		if position_history.size() > POSITION_HISTORY_SIZE:
			position_history.pop_back()

func update_tail_positions():
	# Each segment follows a different position in history
	for i in range(tail_segments.size()):
		var history_index = int((i + 1) * SEGMENT_DISTANCE / MOVE_SPEED / HISTORY_RECORD_INTERVAL)
		
		if history_index < position_history.size():
			var hist_data = position_history[history_index]
			var segment = tail_segments[i] as TailSegment
			if segment:
				segment.set_segment_position(hist_data.position)
				segment.set_segment_rotation(hist_data.rotation)

func _on_head_area_entered(area):
	# Check if we hit our own tail
	if area in tail_segments:
		die()

func add_tail_segment():
	# Called when collecting items
	var segment = tail_segment_scene.instantiate()
	tail_segments.append(segment)
	get_parent().call_deferred("add_child", segment)
	tail_length += 1
