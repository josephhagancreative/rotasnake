extends Control
class_name MainMenu

@onready var title_label = $VBoxContainer/TitleLabel
@onready var play_game_button = $VBoxContainer/NewGameButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	# Connect button signals
	play_game_button.pressed.connect(_on_play_game_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Focus the play game button by default
	play_game_button.grab_focus()

func _on_play_game_pressed():
	GameManager.start_new_game()

func _on_quit_pressed():
	get_tree().quit()

func _input(event):
	# Allow ESC to quit from main menu
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()