extends BaseLevel

# Level 5: Obstacle Gauntlet - Multiple moving hazards
# Challenge: Timing through multiple obstacles with different patterns

func _ready():
	level_name = "Level 5: Danger Zone"
	super._ready()
	
	hint_label.text = "Time your movements carefully! Multiple hazards ahead!"