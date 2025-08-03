extends Node
# Singleton: Add to Project Settings > Autoload as "GameManager"

var current_level = 1
var total_levels = 10
var level_completed = false

# Level scenes paths
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
	
	if level_scenes.has(level_number):
		get_tree().change_scene_to_file(level_scenes[level_number])
	else:
		print("Level " + str(level_number) + " not found!")

func complete_level():
	level_completed = true
	print("Level " + str(current_level) + " completed!")
	
	# Wait a moment then load next level
	await get_tree().create_timer(1.0).timeout
	
	if current_level < total_levels:
		load_level(current_level + 1)
	else:
		print("All levels completed!")
		# Return to level 1 for now
		load_level(1)

func restart_current_level():
	get_tree().reload_current_scene()

func _ready():
	# Start from level 1
	process_mode = Node.PROCESS_MODE_ALWAYS