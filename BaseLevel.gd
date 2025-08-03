extends Node2D
class_name BaseLevel

@export var snake_start_position = Vector2(150, 300)
@export var level_name = "Level"

@onready var walls_tilemap = $Walls
@onready var goal = $Goal
@onready var ui_layer = $UILayer
@onready var level_label = $UILayer/LevelLabel
@onready var hint_label = $UILayer/HintLabel

var snake_scene = preload("res://Snake.tscn")
var snake_instance
var death_tween: Tween

func _ready():
	# Set level name
	level_label.text = level_name
	
	# Spawn snake
	spawn_snake()
	
	# Connect goal
	goal.body_entered.connect(_on_goal_reached)
	
	# Show hint briefly
	if hint_label:
		hint_label.modulate.a = 1.0
		var tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_interval(3.0)
		tween.tween_property(hint_label, "modulate:a", 0.0, 1.0)

func spawn_snake():
	snake_instance = snake_scene.instantiate()
	
	# Look for SnakeStartPoint node first, otherwise use exported position
	var start_point = find_child("SnakeStartPoint", true, false) as SnakeStartPoint
	if start_point:
		var start_pos = start_point.get_start_position()
		var start_dir = start_point.get_facing_direction()
		print("BaseLevel.spawn_snake() - Found SnakeStartPoint, pos: ", start_pos, ", dir: ", start_dir)
		snake_instance.position = start_pos
		snake_instance.set_initial_facing_direction(start_dir)
	else:
		print("BaseLevel.spawn_snake() - No SnakeStartPoint found, using defaults")
		snake_instance.position = snake_start_position
		# Default facing direction if no start point is set
		snake_instance.set_initial_facing_direction(Vector2.RIGHT)
	
	add_child(snake_instance)
	snake_instance.died.connect(_on_snake_died)

func _on_snake_died():
	# Show death message with enhanced styling
	hint_label.text = "💀 YOU DIED! 💀\nPress SPACE to restart"
	hint_label.modulate = Color(1, 0.3, 0.3, 1.0)  # Red color for death
	
	# Clean up any existing tween
	if death_tween:
		death_tween.kill()
	
	# Pulsing effect
	death_tween = create_tween()
	death_tween.set_loops()
	death_tween.tween_property(hint_label, "modulate:a", 0.5, 0.5)
	death_tween.tween_property(hint_label, "modulate:a", 1.0, 0.5)

func _on_goal_reached(body):
	if body == snake_instance and not GameManager.level_completed:
		GameManager.complete_level()
		snake_instance.set_physics_process(false)
		
		# Visual feedback
		goal.modulate = Color(0, 1, 0, 1)
		hint_label.text = "Level Complete!"
		hint_label.modulate.a = 1.0

func _input(event):
	if event.is_action_pressed("ui_select") or event.is_action_pressed("ui_accept"):  # Space/Enter
		# Clean up tweens before restarting
		if death_tween:
			death_tween.kill()
			death_tween = null
		if snake_instance and snake_instance.has_method("cleanup"):
			snake_instance.cleanup()
		
		# Clean up all moving obstacles
		var obstacles = get_tree().get_nodes_in_group("moving_obstacles")
		for obstacle in obstacles:
			if obstacle.has_method("cleanup"):
				obstacle.cleanup()
		
		# Add small delay to ensure all cleanup is complete
		await get_tree().process_frame
		GameManager.restart_current_level()
	elif event.is_action_pressed("ui_cancel"):  # Escape
		get_tree().quit()

# Override in child levels to add moving obstacles
func _physics_process(delta):
	pass