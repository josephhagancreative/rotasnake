extends Control
class_name MainMenu

@onready var title_label = $VBoxContainer/TitleLabel
@onready var new_game_button = $VBoxContainer/NewGameButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	# Connect button signals
	new_game_button.pressed.connect(_on_new_game_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Focus the new game button by default
	new_game_button.grab_focus()

func _on_new_game_pressed():
	GameManager.start_new_game()

func _on_quit_pressed():
	get_tree().quit()

func _input(event):
	# Allow ESC to quit from main menu
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()