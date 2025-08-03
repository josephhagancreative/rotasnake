class_name LevelCompleteScreen
extends Control

@onready var background: ColorRect
@onready var completion_label: Label
@onready var time_label: Label
@onready var collectibles_label: Label
@onready var continue_label: Label

var is_visible: bool = false

func _ready():
	# Initially hidden
	visible = false
	
	# Create semi-transparent background
	background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.7)
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	add_child(background)
	
	# Create completion label
	completion_label = Label.new()
	completion_label.text = "LEVEL COMPLETE!"
	completion_label.add_theme_font_size_override("font_size", 48)
	completion_label.add_theme_color_override("font_color", Color(0, 1, 0, 1))
	completion_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	completion_label.add_theme_constant_override("shadow_offset_x", 2)
	completion_label.add_theme_constant_override("shadow_offset_y", 2)
	completion_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	completion_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	completion_label.anchor_left = 0.5
	completion_label.anchor_right = 0.5
	completion_label.anchor_top = 0.3
	completion_label.anchor_bottom = 0.3
	completion_label.offset_left = -300
	completion_label.offset_right = 300
	completion_label.offset_top = -30
	completion_label.offset_bottom = 30
	add_child(completion_label)
	
	# Create time label
	time_label = Label.new()
	time_label.text = "Time: 00:00.0"
	time_label.add_theme_font_size_override("font_size", 32)
	time_label.add_theme_color_override("font_color", Color.YELLOW)
	time_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	time_label.add_theme_constant_override("shadow_offset_x", 1)
	time_label.add_theme_constant_override("shadow_offset_y", 1)
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	time_label.anchor_left = 0.5
	time_label.anchor_right = 0.5
	time_label.anchor_top = 0.45
	time_label.anchor_bottom = 0.45
	time_label.offset_left = -200
	time_label.offset_right = 200
	time_label.offset_top = -20
	time_label.offset_bottom = 20
	add_child(time_label)
	
	# Create collectibles label
	collectibles_label = Label.new()
	collectibles_label.text = "Collectibles: 0/3"
	collectibles_label.add_theme_font_size_override("font_size", 32)
	collectibles_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0, 1.0))  # Golden yellow
	collectibles_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	collectibles_label.add_theme_constant_override("shadow_offset_x", 1)
	collectibles_label.add_theme_constant_override("shadow_offset_y", 1)
	collectibles_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	collectibles_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	collectibles_label.anchor_left = 0.5
	collectibles_label.anchor_right = 0.5
	collectibles_label.anchor_top = 0.55
	collectibles_label.anchor_bottom = 0.55
	collectibles_label.offset_left = -200
	collectibles_label.offset_right = 200
	collectibles_label.offset_top = -20
	collectibles_label.offset_bottom = 20
	add_child(collectibles_label)
	
	# Create continue instruction
	continue_label = Label.new()
	continue_label.text = "Press SPACE to continue"
	continue_label.add_theme_font_size_override("font_size", 24)
	continue_label.add_theme_color_override("font_color", Color.WHITE)
	continue_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	continue_label.add_theme_constant_override("shadow_offset_x", 1)
	continue_label.add_theme_constant_override("shadow_offset_y", 1)
	continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	continue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	continue_label.anchor_left = 0.5
	continue_label.anchor_right = 0.5
	continue_label.anchor_top = 0.7
	continue_label.anchor_bottom = 0.7
	continue_label.offset_left = -150
	continue_label.offset_right = 150
	continue_label.offset_top = -15
	continue_label.offset_bottom = 15
	add_child(continue_label)

func show_completion_screen(completion_time: float, collected_count: int, total_collectibles: int):
	time_label.text = "Time: " + format_time(completion_time)
	collectibles_label.text = "Collectibles: %d/%d" % [collected_count, total_collectibles]
	
	# Update completion message based on game progress
	if GameManager.current_level < GameManager.total_levels:
		completion_label.text = "LEVEL COMPLETE!"
		continue_label.text = "Press SPACE for next level"
	else:
		completion_label.text = "LEVEL COMPLETE!"
		continue_label.text = "Press SPACE for final results"
	
	visible = true
	is_visible = true
	
	# Animate the screen appearing
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

func hide_completion_screen():
	visible = false
	is_visible = false

func format_time(time_seconds: float) -> String:
	var minutes = int(time_seconds) / 60
	var seconds = int(time_seconds) % 60
	var centiseconds = int((time_seconds - int(time_seconds)) * 10)
	return "%02d:%02d.%d" % [minutes, seconds, centiseconds]