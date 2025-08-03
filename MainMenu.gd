extends Control
class_name MainMenu

@onready var title_label = $VBoxContainer/TitleLabel
@onready var easy_mode_button = $VBoxContainer/NewGameButton
@onready var hard_mode_button = $VBoxContainer/HardModeButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	# Connect button signals
	easy_mode_button.pressed.connect(_on_easy_mode_pressed)
	hard_mode_button.pressed.connect(_on_hard_mode_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Focus the easy mode button by default
	easy_mode_button.grab_focus()

func _on_easy_mode_pressed():
	GameManager.start_new_game()

func _on_hard_mode_pressed():
	GameManager.start_hard_mode()

func _on_quit_pressed():
	get_tree().quit()

func _input(event):
	# Allow ESC to quit from main menu
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()