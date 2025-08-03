extends BaseLevel

# Level 7: Timing Puzzle - Synchronized obstacles
# Challenge: Wait for perfect timing, manage rotation while waiting

func _ready():
	level_name = "Level 7: Synchronicity"
	super._ready()
	
	hint_label.text = "Watch the pattern and wait for your moment!"