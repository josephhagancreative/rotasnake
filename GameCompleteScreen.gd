class_name GameCompleteScreen
extends Control

var jersey_font = preload("res://assets/fonts/Jersey15-Regular.ttf")

@onready var background: ColorRect
@onready var title_label: Label
@onready var total_time_label: Label
@onready var total_collectibles_label: Label
@onready var level_stats_container: VBoxContainer
@onready var continue_label: Label

var is_visible: bool = false

func _ready():
	# Initially hidden
	visible = false
	
	# Create semi-transparent background
	background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.8)
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	add_child(background)
	
	# Create title label
	title_label = Label.new()
	title_label.text = "CONGRATULATIONS!\nGAME COMPLETE!"
	title_label.add_theme_font_override("font", jersey_font)
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color(1, 1, 0, 1))  # Gold
	title_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	title_label.add_theme_constant_override("shadow_offset_x", 1)
	title_label.add_theme_constant_override("shadow_offset_y", 1)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.anchor_left = 0.5
	title_label.anchor_right = 0.5
	title_label.anchor_top = 0.1
	title_label.anchor_bottom = 0.1
	title_label.offset_left = -300
	title_label.offset_right = 300
	title_label.offset_top = -40
	title_label.offset_bottom = 40
	add_child(title_label)
	
	# Create total time label
	total_time_label = Label.new()
	total_time_label.text = "Total Time: 00:00.0"
	total_time_label.add_theme_font_override("font", jersey_font)
	total_time_label.add_theme_font_size_override("font_size", 20)
	total_time_label.add_theme_color_override("font_color", Color(0, 1, 1, 1))  # Cyan
	total_time_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	total_time_label.add_theme_constant_override("shadow_offset_x", 1)
	total_time_label.add_theme_constant_override("shadow_offset_y", 1)
	total_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	total_time_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	total_time_label.anchor_left = 0.5
	total_time_label.anchor_right = 0.5
	total_time_label.anchor_top = 0.22
	total_time_label.anchor_bottom = 0.22
	total_time_label.offset_left = -200
	total_time_label.offset_right = 200
	total_time_label.offset_top = -15
	total_time_label.offset_bottom = 15
	add_child(total_time_label)
	
	# Create total collectibles label
	total_collectibles_label = Label.new()
	total_collectibles_label.text = "Total Collectibles: 0/21"
	total_collectibles_label.add_theme_font_override("font", jersey_font)
	total_collectibles_label.add_theme_font_size_override("font_size", 20)
	total_collectibles_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0, 1.0))  # Golden yellow
	total_collectibles_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	total_collectibles_label.add_theme_constant_override("shadow_offset_x", 1)
	total_collectibles_label.add_theme_constant_override("shadow_offset_y", 1)
	total_collectibles_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	total_collectibles_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	total_collectibles_label.anchor_left = 0.5
	total_collectibles_label.anchor_right = 0.5
	total_collectibles_label.anchor_top = 0.3
	total_collectibles_label.anchor_bottom = 0.3
	total_collectibles_label.offset_left = -200
	total_collectibles_label.offset_right = 200
	total_collectibles_label.offset_top = -15
	total_collectibles_label.offset_bottom = 15
	add_child(total_collectibles_label)
	
	# Create scroll container for level stats
	var scroll_container = ScrollContainer.new()
	scroll_container.anchor_left = 0.5
	scroll_container.anchor_right = 0.5
	scroll_container.anchor_top = 0.4
	scroll_container.anchor_bottom = 0.8
	scroll_container.offset_left = -300
	scroll_container.offset_right = 300
	scroll_container.offset_top = 0
	scroll_container.offset_bottom = 0
	add_child(scroll_container)
	
	# Create container for level stats
	level_stats_container = VBoxContainer.new()
	level_stats_container.anchor_right = 1.0
	level_stats_container.anchor_bottom = 1.0
	scroll_container.add_child(level_stats_container)
	
	# Create continue instruction
	continue_label = Label.new()
	continue_label.text = "Press SPACE to return to main menu"
	continue_label.add_theme_font_override("font", jersey_font)
	continue_label.add_theme_font_size_override("font_size", 18)
	continue_label.add_theme_color_override("font_color", Color.WHITE)
	continue_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	continue_label.add_theme_constant_override("shadow_offset_x", 1)
	continue_label.add_theme_constant_override("shadow_offset_y", 1)
	continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	continue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	continue_label.anchor_left = 0.5
	continue_label.anchor_right = 0.5
	continue_label.anchor_top = 0.85
	continue_label.anchor_bottom = 0.85
	continue_label.offset_left = -200
	continue_label.offset_right = 200
	continue_label.offset_top = -15
	continue_label.offset_bottom = 15
	add_child(continue_label)

func show_game_complete_screen():
	var stats = GameManager.get_game_completion_stats()
	
	# Update total stats
	total_time_label.text = "Total Time: " + format_time(stats["total_time"])
	total_collectibles_label.text = "Total Collectibles: %d/%d" % [stats["total_collectibles"], stats["max_collectibles"]]
	
	# Clear existing level stats
	for child in level_stats_container.get_children():
		child.queue_free()
	
	# Add level stats
	for level_data in stats["levels"]:
		var level_container = HBoxContainer.new()
		level_container.add_theme_constant_override("separation", 20)
		
		# Level number
		var level_label = Label.new()
		level_label.text = "Level %d:" % level_data["level"]
		level_label.add_theme_font_override("font", jersey_font)
		level_label.add_theme_font_size_override("font_size", 16)
		level_label.add_theme_color_override("font_color", Color.WHITE)
		level_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		level_label.add_theme_constant_override("shadow_offset_x", 1)
		level_label.add_theme_constant_override("shadow_offset_y", 1)
		level_label.custom_minimum_size.x = 70
		level_container.add_child(level_label)
		
		# Level time
		var time_label = Label.new()
		time_label.text = format_time(level_data["time"])
		time_label.add_theme_font_override("font", jersey_font)
		time_label.add_theme_font_size_override("font_size", 16)
		time_label.add_theme_color_override("font_color", Color(0, 1, 1, 1))  # Cyan
		time_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		time_label.add_theme_constant_override("shadow_offset_x", 1)
		time_label.add_theme_constant_override("shadow_offset_y", 1)
		time_label.custom_minimum_size.x = 90
		level_container.add_child(time_label)
		
		# Level collectibles
		var collectibles_label = Label.new()
		collectibles_label.text = "%d/3 collectibles" % level_data["collectibles"]
		collectibles_label.add_theme_font_override("font", jersey_font)
		collectibles_label.add_theme_font_size_override("font_size", 16)
		collectibles_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0, 1.0))  # Golden
		collectibles_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		collectibles_label.add_theme_constant_override("shadow_offset_x", 1)
		collectibles_label.add_theme_constant_override("shadow_offset_y", 1)
		collectibles_label.custom_minimum_size.x = 120
		level_container.add_child(collectibles_label)
		
		level_stats_container.add_child(level_container)
		
		# Add some spacing between levels
		var spacer = Control.new()
		spacer.custom_minimum_size.y = 5
		level_stats_container.add_child(spacer)
	
	visible = true
	is_visible = true
	
	# Animate the screen appearing
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8)

func hide_game_complete_screen():
	visible = false
	is_visible = false

func format_time(time_seconds: float) -> String:
	var minutes = int(time_seconds) / 60
	var seconds = int(time_seconds) % 60
	var centiseconds = int((time_seconds - int(time_seconds)) * 10)
	return "%02d:%02d.%d" % [minutes, seconds, centiseconds]