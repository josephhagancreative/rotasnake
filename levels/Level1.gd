extends BaseLevel

# Level 1: Introduction - Simple path to goal
# Teaches: Basic movement and goal

func _ready():
	level_name = "Level 1: First Steps"
	super._ready()
	
	# Set hint
	hint_label.text = "Use arrow keys to move. Reach the yellow goal!"