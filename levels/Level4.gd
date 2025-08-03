extends BaseLevel

# Level 4: Precision Corridors - Tight spaces requiring careful navigation
# Challenge: Navigate narrow zigzag paths while managing growing tail

func _ready():
	level_name = "Level 4: Tight Squeeze"
	super._ready()
	
	hint_label.text = "Navigate the narrow corridors! Watch your tail length!"