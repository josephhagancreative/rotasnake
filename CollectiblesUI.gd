class_name CollectiblesUI
extends Control

@onready var collectible_icons: Array[TextureRect] = []

func _ready():
	# Find the collectible icon nodes
	for i in range(3):
		var icon = get_node("CollectibleIcon" + str(i + 1))
		collectible_icons.append(icon)
	
	# Connect to GameManager's collectible signal
	GameManager.collectible_collected.connect(_on_collectible_collected)
	
	# Initialize UI state
	_update_ui(0, 3)

func _on_collectible_collected(collected: int, total: int):
	_update_ui(collected, total)

func _update_ui(collected: int, total: int):
	for i in range(collectible_icons.size()):
		if i < collected:
			# Collected - full opacity yellow
			collectible_icons[i].modulate = Color(1.0, 0.8, 0.0, 1.0)
		else:
			# Not collected - dark silhouette
			collectible_icons[i].modulate = Color(0.3, 0.3, 0.3, 0.8)