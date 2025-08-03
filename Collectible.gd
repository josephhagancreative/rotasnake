class_name Collectible
extends Area2D

signal collected

var is_collected: bool = false
var original_position: Vector2
var float_tween: Tween
var audio_player: AudioStreamPlayer2D

func _ready():
	body_entered.connect(_on_body_entered)
	
	# Set up collision detection for snake head
	collision_layer = 0
	collision_mask = 1  # Detect snake_head (layer 1)
	
	# Add to collectibles group for easy management
	add_to_group("collectibles")
	
	# Set up audio player
	audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = preload("res://assets/audio/chime.wav")
	add_child(audio_player)
	
	# Store original position and start floating animation
	original_position = position
	start_floating_animation()

func _on_body_entered(body):
	if body.is_in_group("snake") and not is_collected:
		collect()

func start_floating_animation():
	float_tween = create_tween()
	float_tween.set_loops()
	
	# Move up 3 pixels over 1 second, then down 3 pixels over 1 second
	float_tween.tween_property(self, "position:y", original_position.y - 3, 1.0)
	float_tween.tween_property(self, "position:y", original_position.y + 3, 1.0)

func collect():
	if is_collected:
		return
		
	is_collected = true
	
	# Play collection sound
	audio_player.play()
	
	collected.emit()
	
	# Stop floating animation
	if float_tween:
		float_tween.kill()
	
	# Visual feedback - fade out
	var tween = create_tween()
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)