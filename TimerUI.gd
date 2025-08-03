class_name TimerUI
extends Control

var jersey_font = preload("res://assets/fonts/Jersey15-Regular.ttf")

@onready var timer_label: Label

var elapsed_time: float = 0.0
var is_running: bool = false

func _ready():
	# Create the timer label
	timer_label = Label.new()
	timer_label.text = "00:00.0"
	timer_label.add_theme_font_override("font", jersey_font)
	timer_label.add_theme_font_size_override("font_size", 20)
	timer_label.add_theme_color_override("font_color", Color.WHITE)
	timer_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	timer_label.add_theme_constant_override("shadow_offset_x", 1)
	timer_label.add_theme_constant_override("shadow_offset_y", 1)
	
	# Position in bottom right
	timer_label.anchor_left = 1.0
	timer_label.anchor_right = 1.0
	timer_label.anchor_top = 1.0
	timer_label.anchor_bottom = 1.0
	timer_label.offset_left = -120
	timer_label.offset_top = -40
	timer_label.offset_right = -10
	timer_label.offset_bottom = -10
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	
	add_child(timer_label)

func _process(delta):
	if is_running:
		elapsed_time += delta
		update_display()

func start_timer():
	is_running = true
	elapsed_time = 0.0

func stop_timer():
	is_running = false

func reset_timer():
	elapsed_time = 0.0
	is_running = false
	update_display()

func get_elapsed_time() -> float:
	return elapsed_time

func get_formatted_time() -> String:
	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60
	var centiseconds = int((elapsed_time - int(elapsed_time)) * 10)
	return "%02d:%02d.%d" % [minutes, seconds, centiseconds]

func update_display():
	if timer_label:
		timer_label.text = get_formatted_time()