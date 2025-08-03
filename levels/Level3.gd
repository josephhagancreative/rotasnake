extends BaseLevel

# Level 3: Moving Danger - Introduction to moving obstacles
# Teaches: Timing and waiting (which triggers rotation)

func _ready():
	level_name = "Level 3: Moving Hazards"
	super._ready()
	
	hint_label.text = "Red obstacles will destroy you! Time your movement!"