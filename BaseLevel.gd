extends Node2D
class_name BaseLevel

var jersey_font = preload("res://assets/fonts/Jersey15-Regular.ttf")

@export var snake_start_position = Vector2(150, 300)
@export var level_name = "Level"
@export var level_hint = "Navigate to the goal!"

@onready var walls_tilemap = $Walls
@onready var goal = $Goal
@onready var ui_layer = $UILayer
@onready var level_label = $UILayer/LevelLabel
@onready var hint_label = $UILayer/HintLabel
@onready var collectibles_ui = $UILayer/CollectiblesUI
@onready var timer_ui = $UILayer/TimerUI
@onready var completion_screen = $UILayer/LevelCompleteScreen
@onready var game_complete_screen = $UILayer/GameCompleteScreen

var snake_scene = preload("res://Snake.tscn")
var snake_instance
var death_tween: Tween
var level_start_time: float = 0.0

func _ready():
	# Set level name and hint
	level_label.text = level_name
	hint_label.text = level_hint
	
	# Apply Jersey font and drop shadows to UI labels
	apply_font_and_shadows()
	
	# Setup editor-placed elements
	setup_editor_elements()
	
	# Setup collectibles
	setup_collectibles()
	
	# Spawn snake
	spawn_snake()
	
	# Connect goal
	goal.body_entered.connect(_on_goal_reached)
	
	# Start timer
	start_level_timer()
	
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
		snake_instance.position = start_pos
		snake_instance.set_initial_facing_direction(start_dir)
	else:
		snake_instance.position = snake_start_position
		# Default facing direction if no start point is set
		snake_instance.set_initial_facing_direction(Vector2.RIGHT)
	
	add_child(snake_instance)
	snake_instance.died.connect(_on_snake_died)

func apply_font_and_shadows():
	# Apply Jersey font and drop shadows to level and hint labels
	if level_label:
		level_label.add_theme_font_override("font", jersey_font)
		level_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		level_label.add_theme_constant_override("shadow_offset_x", 1)
		level_label.add_theme_constant_override("shadow_offset_y", 1)
	
	if hint_label:
		hint_label.add_theme_font_override("font", jersey_font)
		hint_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		hint_label.add_theme_constant_override("shadow_offset_x", 1)
		hint_label.add_theme_constant_override("shadow_offset_y", 1)

func setup_editor_elements():
	# This function automatically handles any MovingObstaclePlacement nodes
	# and other editor-placed elements that need runtime processing
	var placement_nodes = find_children("", "MovingObstaclePlacement")
	for placement in placement_nodes:
		# The placement nodes handle their own spawning in _ready()
		# so we just need to ensure they're processed correctly
		pass

func setup_collectibles():
	# Connect to existing collectibles in the scene
	var collectibles = get_tree().get_nodes_in_group("collectibles")
	for collectible in collectibles:
		if collectible.has_signal("collected"):
			collectible.collected.connect(_on_collectible_collected)

func _on_collectible_collected():
	GameManager.collect_collectible()

func start_level_timer():
	if timer_ui:
		timer_ui.start_timer()

func stop_level_timer():
	if timer_ui:
		timer_ui.stop_timer()

func reset_level_timer():
	if timer_ui:
		timer_ui.reset_timer()

func get_level_time() -> float:
	if timer_ui:
		return timer_ui.get_elapsed_time()
	return 0.0

func _on_snake_died():
	# Stop timer on death
	stop_level_timer()
	
	# Show death message with enhanced styling
	hint_label.text = "YOU DIED!\nPress SPACE to restart"
	hint_label.modulate = Color(1, 0.3, 0.3, 1.0)  # Red color for death
	
	# Ensure font and shadows are applied to death message
	hint_label.add_theme_font_override("font", jersey_font)
	hint_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	hint_label.add_theme_constant_override("shadow_offset_x", 1)
	hint_label.add_theme_constant_override("shadow_offset_y", 1)
	
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
		# Stop timer and get completion time
		stop_level_timer()
		var completion_time = get_level_time()
		var collectible_progress = GameManager.get_collectible_progress()
		
		# Record level statistics
		GameManager.record_level_completion(GameManager.current_level, completion_time, collectible_progress[0])
		
		GameManager.complete_level()
		snake_instance.set_physics_process(false)
		
		# Visual feedback
		goal.modulate = Color(0, 1, 0, 1)
		
		# Hide the hint label (we'll show completion screen instead)
		hint_label.modulate.a = 0.0
		
		# Check if this is the final level
		if GameManager.is_final_level():
			# Show game completion screen with all stats
			if game_complete_screen:
				game_complete_screen.show_game_complete_screen()
		else:
			# Show level completion screen
			if completion_screen:
				completion_screen.show_completion_screen(completion_time, collectible_progress[0], collectible_progress[1])

func _input(event):
	if event.is_action_pressed("ui_select") or event.is_action_pressed("ui_accept"):  # Space/Enter
		# Check if game completion screen is visible
		if game_complete_screen and game_complete_screen.is_visible:
			# Hide game completion screen and return to menu
			game_complete_screen.hide_game_complete_screen()
			GameManager.return_to_main_menu()
			return
		
		# Check if level is completed and awaiting next level
		if GameManager.awaiting_next_level:
			# Hide completion screen
			if completion_screen:
				completion_screen.hide_completion_screen()
			
			# Clean up tweens before advancing
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
			GameManager.advance_to_next_level()
		else:
			# Restart current level if dead
			# Reset timer on restart
			reset_level_timer()
			
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
		GameManager.return_to_main_menu()

# Override in child levels to add moving obstacles
func _physics_process(delta):
	pass