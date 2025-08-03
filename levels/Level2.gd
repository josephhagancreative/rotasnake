extends BaseLevel

# Level 2: Tail Danger - Narrow corridor forces tail awareness
# Teaches: Tail collision danger

func _ready():
	level_name = "Level 2: Watch Your Tail"
	super._ready()
	
	hint_label.text = "Your tail follows you! Don't hit it when rotating!"