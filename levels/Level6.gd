extends BaseLevel

# Level 6: Spiral Challenge - Forces rotation management
# Challenge: Navigate spiral inward while managing tail rotation

func _ready():
	level_name = "Level 6: The Spiral"
	super._ready()
	
	hint_label.text = "Follow the spiral inward! Use rotation wisely!"