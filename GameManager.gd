extends Node
# Singleton: Add to Project Settings > Autoload as "GameManager"

var current_level = 1
var total_levels = 7  # Updated to reflect actual levels (1-7)
var level_completed = false
var awaiting_next_level = false

# Collectible tracking
var collectibles_per_level = 3
var current_level_collectibles_collected = 0
signal collectible_collected(collected_count: int, total_count: int)

# Level statistics tracking
var level_stats = {}  # Dictionary to store stats for each level
var game_start_time: float = 0.0
var total_game_time: float = 0.0

# Scene paths
var main_menu_scene = "res://MainMenu.tscn"
var level_scenes = {
	1: "res://levels/Level1.tscn",
	2: "res://levels/Level2.tscn",
	3: "res://levels/Level3.tscn",
	4: "res://levels/Level4.tscn",
	5: "res://levels/Level5.tscn",
	6: "res://levels/Level6.tscn",
	7: "res://levels/Level7.tscn"
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
	current_level_collectibles_collected = 0
	
	# Reset game statistics
	level_stats.clear()
	game_start_time = 0.0
	total_game_time = 0.0
	
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
	current_level_collectibles_collected = 0
	get_tree().change_scene_to_file(main_menu_scene)

func collect_collectible():
	current_level_collectibles_collected += 1
	collectible_collected.emit(current_level_collectibles_collected, collectibles_per_level)

func get_collectible_progress() -> Array:
	return [current_level_collectibles_collected, collectibles_per_level]

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

# Level statistics functions
func record_level_completion(level_number: int, completion_time: float, collectibles_collected: int):
	level_stats[level_number] = {
		"time": completion_time,
		"collectibles": collectibles_collected
	}

func calculate_total_game_time() -> float:
	var total = 0.0
	for level in level_stats:
		total += level_stats[level]["time"]
	return total

func get_level_stats() -> Dictionary:
	return level_stats

func is_final_level() -> bool:
	return current_level >= total_levels

func get_game_completion_stats() -> Dictionary:
	var stats = {
		"total_time": calculate_total_game_time(),
		"total_collectibles": 0,
		"max_collectibles": total_levels * collectibles_per_level,
		"levels": []
	}
	
	# Calculate total collectibles and build level array
	for level_num in range(1, total_levels + 1):
		if level_stats.has(level_num):
			var level_data = level_stats[level_num]
			stats["total_collectibles"] += level_data["collectibles"]
			stats["levels"].append({
				"level": level_num,
				"time": level_data["time"],
				"collectibles": level_data["collectibles"]
			})
		else:
			# If level wasn't completed (shouldn't happen), add default
			stats["levels"].append({
				"level": level_num,
				"time": 0.0,
				"collectibles": 0
			})
	
	return stats