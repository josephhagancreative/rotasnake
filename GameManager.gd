extends Node
# Singleton: Add to Project Settings > Autoload as "GameManager"

var current_level = 1
var total_levels = 10
var level_completed = false
var awaiting_next_level = false
var is_hard_mode = false

# Collectible tracking
var collectibles_per_level = 3
var current_level_collectibles_collected = 0
signal collectible_collected(collected_count: int, total_count: int)

# Scene paths
var main_menu_scene = "res://MainMenu.tscn"
var level_scenes = {
	1: "res://levels/Level1.tscn",
	2: "res://levels/Level2.tscn",
	3: "res://levels/Level3.tscn",
	4: "res://levels/Level4.tscn",
	5: "res://levels/Level5.tscn",
	6: "res://levels/Level6.tscn",
	7: "res://levels/Level7.tscn",
	8: "res://levels/Level8.tscn",
	9: "res://levels/Level9.tscn",
	10: "res://levels/Level10.tscn"
}

func load_level(level_number: int):
	current_level = level_number
	level_completed = false
	current_level_collectibles_collected = 0
	
	if level_scenes.has(level_number):
		get_tree().change_scene_to_file(level_scenes[level_number])

func complete_level():
	level_completed = true
	awaiting_next_level = true

func restart_current_level():
	awaiting_next_level = false
	level_completed = false
	current_level_collectibles_collected = 0
	get_tree().reload_current_scene()

func start_new_game():
	current_level = 1
	level_completed = false
	awaiting_next_level = false
	is_hard_mode = false
	current_level_collectibles_collected = 0
	load_level(1)

func start_hard_mode():
	current_level = 1
	level_completed = false
	awaiting_next_level = false
	is_hard_mode = true
	current_level_collectibles_collected = 0
	load_level(1)

func advance_to_next_level():
	if not awaiting_next_level:
		return
	
	awaiting_next_level = false
	
	if current_level < total_levels:
		load_level(current_level + 1)
	else:
		# Game completed, return to main menu
		return_to_main_menu()

func return_to_main_menu():
	current_level = 1
	level_completed = false
	awaiting_next_level = false
	is_hard_mode = false
	current_level_collectibles_collected = 0
	get_tree().change_scene_to_file(main_menu_scene)

func collect_collectible():
	current_level_collectibles_collected += 1
	collectible_collected.emit(current_level_collectibles_collected, collectibles_per_level)

func get_collectible_progress() -> Array:
	return [current_level_collectibles_collected, collectibles_per_level]

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS