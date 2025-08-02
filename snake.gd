extends CharacterBody2D
class_name Snake

# Movement constants
const ROTATION_SPEED = 2.0  # Radians per second (about 115 degrees/sec)
const ROTATION_RADIUS = 50.0  # Distance from center when rotating
const MOVE_SPEED = ROTATION_SPEED * ROTATION_RADIUS * 1.25  # Match tangential speed of rotation, increased by 25% (125px/s)

# Tail constants
const SEGMENT_DISTANCE = 18.0  # Distance between segments
const POSITION_HISTORY_SIZE = 300  # How many positions to remember
const HISTORY_RECORD_INTERVAL = 0.02  # How often to record position (seconds)

# State management
enum State { MOVING, ROTATING, TRANSITIONING }
var current_state = State.ROTATING
var facing_direction = Vector2.ZERO  # The direction the snake is visually facing
var rotation_angle = 0.0
var rotation_center = Vector2.ZERO
var initial_setup_done = false  # Flag to prevent _ready from overriding custom setup

# Rotation direction control
var rotation_direction = 1.0  # 1.0 for clockwise, -1.0 for counter-clockwise
var target_rotation_direction = 1.0  # The direction we're transitioning to
var transition_timer = 0.0
var transition_duration = 0.1  # 0.1 second to transition between directions (nearly instant)

# Input buffering for most recent input priority
var input_queue = []
var max_input_queue_size = 4

# Tail management
var tail_segments = []
var position_history = []
var history_timer = 0.0
var tail_length = 10  # Start with 10 segments for shorter snake

# Self-collision immunity
var collision_immunity_time = 2.0  # 2 seconds of immunity at start
var immunity_timer = 0.0
var min_tail_segment_distance = 3  # Ignore first 3 tail segments

# Visual
@onready var sprite = $Sprite2D
@onready var head_area = $HeadArea

# Signals
signal died()

var tail_segment_scene = preload("res://TailSegment.tscn")

func _ready():
	# Initialize immunity timer
	immunity_timer = collision_immunity_time
	
	# Initialize rotation direction variables
	rotation_direction = 1.0  # Start clockwise
	target_rotation_direction = 1.0
	
	# Only do default setup if set_initial_facing_direction wasn't called
	if not initial_setup_done:
		# Set initial facing direction (can be overridden by set_initial_facing_direction)
		facing_direction = Vector2(1, 0)  # Start facing right
		
		# Set initial rotation center based on default direction (clockwise rotation)
		var perpendicular = Vector2(facing_direction.y, -facing_direction.x)
		rotation_center = global_position + perpendicular * ROTATION_RADIUS
		rotation_angle = atan2(global_position.y - rotation_center.y, global_position.x - rotation_center.x)
		
		# Set initial sprite rotation to face the starting direction
		sprite.rotation = facing_direction.angle()
	
	
	# Initialize position history with starting positions
	for i in range(POSITION_HISTORY_SIZE):
		position_history.append({
			"position": global_position,
			"rotation": facing_direction.angle()
		})
	
	# Create initial tail segments
	create_tail_segments()
	
	# Connect head area for self-collision detection
	# Configure HeadArea collision - it should be on layer 1 and detect layer 2 (tail segments)
	head_area.collision_layer = 1  # 2^0 = layer 1 (snake_head)
	head_area.collision_mask = 2   # 2^1 = detect layer 2 (snake_tail)
	
	# Set head collision shape to normal size for solid body
	var head_collision = head_area.get_child(0) as CollisionShape2D
	if head_collision and head_collision.shape is CircleShape2D:
		var head_shape = head_collision.shape as CircleShape2D
		head_shape.radius = 12.0  # Back to normal size for solid collision
	
	head_area.area_entered.connect(_on_head_area_entered)

func _physics_process(delta):
	# Update immunity timer
	if immunity_timer > 0:
		immunity_timer -= delta
	
	# Record position history
	update_position_history(delta)
	
	match current_state:
		State.MOVING:
			handle_movement(delta)
		State.ROTATING:
			handle_rotation(delta)
		State.TRANSITIONING:
			handle_transition(delta)
	
	# Update tail positions
	update_tail_positions()
	
	# Check for input to switch states
	check_input()

func handle_movement(delta):
	# Move in the current facing direction (keep facing_direction UNCHANGED during movement)
	velocity = facing_direction * MOVE_SPEED
	move_and_slide()
	
	# Check for wall collisions
	if is_on_wall():
		die()
		return
	
	# Keep sprite rotation consistent with facing direction (don't change facing_direction)
	sprite.rotation = facing_direction.angle()

func handle_rotation(delta):
	# Rotate around the center point using current rotation direction
	rotation_angle += ROTATION_SPEED * rotation_direction * delta
	
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
	
	# Calculate the tangent direction (direction of movement on the circle)
	var tangent = Vector2(-sin(rotation_angle), cos(rotation_angle)) * rotation_direction
	var old_facing = facing_direction
	facing_direction = tangent.normalized()
	
	# Log first few frames to see what's happening
	if Engine.get_process_frames() < 100:
		print("Snake.handle_rotation() - Frame ", Engine.get_process_frames())
		print("  rotation_angle: ", rotation_angle)
		print("  tangent: ", tangent)
		print("  old_facing: ", old_facing)
		print("  new facing_direction: ", facing_direction)
	
	# Make sprite face the tangent direction
	sprite.rotation = facing_direction.angle()

func handle_transition(delta):
	# Update transition timer
	transition_timer += delta
	
	# Calculate transition progress (0.0 to 1.0)
	var progress = transition_timer / transition_duration
	
	
	# Move forward in the current facing direction
	velocity = facing_direction * MOVE_SPEED
	move_and_slide()
	
	# Check for wall collisions
	if is_on_wall():
		die()
		return
	
	# Keep sprite facing the current direction (don't change during transition)
	sprite.rotation = facing_direction.angle()
	
	# Check if transition is complete
	if progress >= 1.0:
		# Complete the transition
		rotation_direction = target_rotation_direction
		current_state = State.ROTATING
		
		# Set up new rotation center from current position using current facing direction
		var perpendicular_to_facing = Vector2(-facing_direction.y, facing_direction.x) * rotation_direction
		rotation_center = global_position + perpendicular_to_facing * ROTATION_RADIUS
		rotation_angle = atan2(global_position.y - rotation_center.y, global_position.x - rotation_center.x)

func _input(event):
	# Left key: set rotation to counter-clockwise
	if event.is_action_pressed("ui_left"):
		if target_rotation_direction != -1.0:  # Only transition if direction changed
			# Only start transition if we're in ROTATING state
			if current_state == State.ROTATING:
				start_rotation_transition(-1.0)
			else:
				# If we're moving, just set the target direction for later
				target_rotation_direction = -1.0
		add_to_input_queue("ui_left")
	
	# Right key: set rotation to clockwise
	elif event.is_action_pressed("ui_right"):
		if target_rotation_direction != 1.0:  # Only transition if direction changed
			# Only start transition if we're in ROTATING state
			if current_state == State.ROTATING:
				start_rotation_transition(1.0)
			else:
				# If we're moving, just set the target direction for later
				target_rotation_direction = 1.0
		add_to_input_queue("ui_right")
	
	# Forward key (up): move forward in current facing direction
	elif event.is_action_pressed("ui_up"):
		add_to_input_queue("ui_up")
	
	# Remove released keys from queue
	if event.is_action_released("ui_up"):
		remove_from_input_queue("ui_up")
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

func start_rotation_transition(new_direction: float):
	# Start a smooth transition to a new rotation direction
	# Only transition if we're actually changing direction
	if new_direction == rotation_direction:
		return
	
	target_rotation_direction = new_direction
	transition_timer = 0.0
	current_state = State.TRANSITIONING

func recalculate_rotation_center():
	# When changing rotation direction, calculate new rotation center from current position
	# The current facing direction becomes the tangent to the new circle
	var current_facing = facing_direction.normalized()
	
	# Calculate perpendicular direction for the new rotation center
	# For clockwise rotation (positive), center is to the right of facing direction
	# For counter-clockwise rotation (negative), center is to the left of facing direction
	var perpendicular = Vector2(-current_facing.y, current_facing.x) * rotation_direction
	
	# Set new rotation center
	rotation_center = global_position + perpendicular * ROTATION_RADIUS
	
	# Update rotation angle to match current position on new circle
	rotation_angle = atan2(global_position.y - rotation_center.y, global_position.x - rotation_center.x)

func get_priority_input_action() -> String:
	# Return most recent input that's still held
	for action in input_queue:
		if Input.is_action_pressed(action):
			return action
	return ""

func check_input():
	# Get the current priority input
	var current_input = get_priority_input_action()
	
	# Forward key (up): switch to moving state
	if current_input == "ui_up":
		if current_state == State.ROTATING:
			# Switch to moving in the direction we're currently facing
			current_state = State.MOVING
		elif current_state == State.TRANSITIONING:
			# Switch to moving state to pause transition
			current_state = State.MOVING
	
	# Left/Right keys: handle rotation direction changes
	elif current_input == "ui_left" or current_input == "ui_right":
		# Don't switch to rotating if we're moving forward - just set the rotation direction
		# This allows changing rotation direction while moving without affecting current movement
		pass  # Rotation direction is already handled in _input()
	
	# No input: switch to rotating state from moving
	elif current_input == "":
		if current_state == State.MOVING:
			# Switch to rotating state, use target rotation direction if it was changed while moving
			rotation_direction = target_rotation_direction
			current_state = State.ROTATING
			
			# COMPLETELY FRESH rotation setup - ignore any previous rotation_angle
			# The facing direction should remain exactly as it was during movement
			# Calculate where the rotation center should be so that we continue smoothly
			var perpendicular = Vector2(-facing_direction.y, facing_direction.x) * rotation_direction
			rotation_center = global_position + perpendicular * ROTATION_RADIUS
			
			# Calculate the angle for this position on the new circle
			rotation_angle = atan2(global_position.y - rotation_center.y, global_position.x - rotation_center.x)
			
		
		# If rotating or transitioning, continue in current state

func get_current_state():
	return current_state

func die():
	# Called when snake hits something
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
		
		# Set collision layer for tail segments (layer 2: snake_tail)
		segment.collision_layer = 2  # 2^1 = layer 2
		segment.collision_mask = 0   # Don't detect anything
		
		# Set tail collision shape to be smaller than head (circular)
		var tail_collision = segment.get_child(0) as CollisionShape2D
		if tail_collision:
			# Create a circular collision shape for body segments
			var circle_shape = CircleShape2D.new()
			circle_shape.radius = 10.0  # Smaller than head (12px)
			tail_collision.shape = circle_shape
		
		tail_segments.append(segment)
		get_parent().call_deferred("add_child", segment)

func update_position_history(delta):
	history_timer += delta
	
	if history_timer >= HISTORY_RECORD_INTERVAL:
		history_timer = 0.0
		
		# Add new position to front
		position_history.push_front({
			"position": global_position,
			"rotation": facing_direction.angle()
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

func check_self_collision_overlap(tail_area: Area2D):
	die()

func _on_head_area_entered(area):
	# Check immunity period
	if immunity_timer > 0:
		return
	
	# Check if we hit our own tail
	if area in tail_segments:
		# Find which segment this is
		var segment_index = tail_segments.find(area)
		
		# Ignore collisions with nearby segments (first few segments)
		if segment_index < min_tail_segment_distance:
			return
		
		check_self_collision_overlap(area)

func add_tail_segment():
	# Called when collecting items
	var segment = tail_segment_scene.instantiate()
	tail_segments.append(segment)
	get_parent().call_deferred("add_child", segment)
	tail_length += 1

func set_initial_facing_direction(direction: Vector2):
	# Set the initial facing direction before _ready() completes
	facing_direction = direction.normalized()
	initial_setup_done = true  # Mark that we've done custom setup
	print("Snake.set_initial_facing_direction() - Setting facing_direction to: ", facing_direction)
	
	# For the rotation to work correctly, we need to position the rotation center
	# such that the current facing direction IS the tangent to the circle at this position
	
	# For clockwise rotation (rotation_direction = 1):
	# - If facing right (1,0), center should be below (0,1) 
	# - If facing up (0,-1), center should be to the right (1,0)
	# - If facing left (-1,0), center should be above (0,-1)
	# - If facing down (0,1), center should be to the left (-1,0)
	
	# The perpendicular that points toward the center (for clockwise rotation)
	# For facing RIGHT (1,0), we want center BELOW, so perpendicular should be DOWN (0,1)
	var perpendicular = Vector2(-facing_direction.y, facing_direction.x) * rotation_direction
	rotation_center = global_position + perpendicular * ROTATION_RADIUS
	rotation_angle = atan2(global_position.y - rotation_center.y, global_position.x - rotation_center.x)
	
	print("Snake.set_initial_facing_direction() - rotation_direction: ", rotation_direction)
	print("Snake.set_initial_facing_direction() - perpendicular: ", perpendicular)
	print("Snake.set_initial_facing_direction() - rotation_center: ", rotation_center)
	print("Snake.set_initial_facing_direction() - rotation_angle: ", rotation_angle)
	
	# Verify the tangent calculation matches our facing direction
	var expected_tangent = Vector2(-sin(rotation_angle), cos(rotation_angle)) * rotation_direction
	print("Snake.set_initial_facing_direction() - expected_tangent: ", expected_tangent)
	print("Snake.set_initial_facing_direction() - facing_direction: ", facing_direction)
	
	# Set initial sprite rotation to face the starting direction
	if sprite:
		sprite.rotation = facing_direction.angle()
