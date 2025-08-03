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
var current_state = State.MOVING
var facing_direction = Vector2.ZERO  # The direction the snake is visually facing
var rotation_angle = 0.0
var rotation_center = Vector2.ZERO
var initial_setup_done = false  # Flag to prevent _ready from overriding custom setup

# Movement mode cycling
enum MovementMode { COUNTER_CLOCKWISE, CLOCKWISE, FORWARD }
var current_movement_mode = MovementMode.CLOCKWISE
var rotation_direction = 1.0  # 1.0 for clockwise, -1.0 for counter-clockwise
var target_rotation_direction = 1.0  # The direction we're transitioning to
var transition_timer = 0.0
var transition_duration = 0.1  # 0.1 second to transition between directions (nearly instant)


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
var death_tween: Tween

func _ready():
	# Initialize immunity timer
	immunity_timer = collision_immunity_time
	
	# Initialize rotation direction variables
	rotation_direction = 1.0  # Start clockwise
	target_rotation_direction = 1.0
	current_movement_mode = MovementMode.FORWARD  # Start with forward movement
	
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
	# Left key: counter-clockwise rotation
	if event.is_action_pressed("ui_left"):
		current_movement_mode = MovementMode.COUNTER_CLOCKWISE
		apply_movement_mode()
	
	# Right key: clockwise rotation
	elif event.is_action_pressed("ui_right"):
		current_movement_mode = MovementMode.CLOCKWISE
		apply_movement_mode()
	
	# Forward key (up): forward movement
	elif event.is_action_pressed("ui_up"):
		current_movement_mode = MovementMode.FORWARD
		apply_movement_mode()

func apply_movement_mode():
	match current_movement_mode:
		MovementMode.COUNTER_CLOCKWISE:
			# Set counter-clockwise rotation
			if current_state == State.MOVING:
				# If moving, switch to rotating and set direction
				current_state = State.ROTATING
				setup_rotation_from_movement(-1.0)
			elif rotation_direction != -1.0:
				# If already rotating, transition to counter-clockwise
				start_rotation_transition(-1.0)
		
		MovementMode.CLOCKWISE:
			# Set clockwise rotation
			if current_state == State.MOVING:
				# If moving, switch to rotating and set direction
				current_state = State.ROTATING
				setup_rotation_from_movement(1.0)
			elif rotation_direction != 1.0:
				# If already rotating, transition to clockwise
				start_rotation_transition(1.0)
		
		MovementMode.FORWARD:
			# Switch to forward movement
			if current_state == State.ROTATING or current_state == State.TRANSITIONING:
				current_state = State.MOVING

func setup_rotation_from_movement(new_direction: float):
	# Set up rotation state when switching from movement to rotation
	rotation_direction = new_direction
	target_rotation_direction = new_direction
	
	# Calculate rotation center from current position and facing direction
	var perpendicular = Vector2(-facing_direction.y, facing_direction.x) * rotation_direction
	rotation_center = global_position + perpendicular * ROTATION_RADIUS
	rotation_angle = atan2(global_position.y - rotation_center.y, global_position.x - rotation_center.x)


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


func get_current_state():
	return current_state

func die():
	# Called when snake hits something
	died.emit()
	set_physics_process(false)  # Stop movement
	
	# Clean up any existing death tween
	if death_tween:
		death_tween.kill()
	
	# Enhanced visual feedback
	modulate = Color(1, 0.3, 0.3, 1.0)
	
	# Add death animation
	death_tween = create_tween()
	death_tween.set_parallel(true)
	death_tween.tween_property(self, "modulate", Color(1, 0, 0, 0.5), 0.5)
	death_tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.3)
	death_tween.tween_property(self, "rotation", PI/4, 0.5)
	
	# Clean up tail with delay
	for segment in tail_segments:
		if is_instance_valid(segment):
			segment.modulate = Color(1, 0.3, 0.3, 1.0)
			segment.queue_free()

func cleanup():
	# Clean up tweens before scene change
	if death_tween:
		death_tween.kill()
		death_tween = null

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
	
	
	# Verify the tangent calculation matches our facing direction
	var expected_tangent = Vector2(-sin(rotation_angle), cos(rotation_angle)) * rotation_direction
	
	# Set initial sprite rotation to face the starting direction
	if sprite:
		sprite.rotation = facing_direction.angle()
