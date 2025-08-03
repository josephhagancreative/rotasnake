extends Area2D
class_name Goal

@onready var color_rect = $ColorRect
@onready var collision = $CollisionShape2D

var time = 0.0
var audio_player1: AudioStreamPlayer2D
var audio_player2: AudioStreamPlayer2D

func _ready():
	# Set collision layers
	collision_layer = 32  # Layer 6
	collision_mask = 1    # Detect layer 1 (snake head)
	
	# Set up audio players for double chime effect
	audio_player1 = AudioStreamPlayer2D.new()
	audio_player1.stream = preload("res://assets/audio/chime.wav")
	audio_player1.pitch_scale = 1.2  # First pitch
	add_child(audio_player1)
	
	audio_player2 = AudioStreamPlayer2D.new()
	audio_player2.stream = preload("res://assets/audio/chime.wav")
	audio_player2.pitch_scale = 1.5  # Higher pitch
	add_child(audio_player2)

func _process(delta):
	time += delta
	# Simple pulsing animation
	var scale_factor = 1.0 + sin(time * 3.0) * 0.2
	scale = Vector2(scale_factor, scale_factor)
	
	# Rotate slowly
	rotation += delta * 0.5

func play_completion_sound():
	# Play first chime at normal pitch
	audio_player1.play()
	
	# Play second chime at higher pitch after a short delay
	var timer = get_tree().create_timer(0.15)
	timer.timeout.connect(func(): audio_player2.play())
