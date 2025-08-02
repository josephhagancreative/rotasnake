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
	snake_instance.position = snake_start_position
	add_child(snake_instance)
	snake_instance.died.connect(_on_snake_died)

func _on_snake_died():
	# Show death message with enhanced styling
	hint_label.text = "💀 YOU DIED! 💀\nPress SPACE to restart"
	hint_label.modulate = Color(1, 0.3, 0.3, 1.0)  # Red color for death
	
	# Pulsing effect
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(hint_label, "modulate:a", 0.5, 0.5)
	tween.tween_property(hint_label, "modulate:a", 1.0, 0.5)

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
		GameManager.restart_current_level()
	elif event.is_action_pressed("ui_cancel"):  # Escape
		get_tree().quit()

# Override in child levels to add moving obstacles
func _physics_process(delta):
	pass