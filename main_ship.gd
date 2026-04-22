class_name MainShip
extends Node2D

@onready var sprite: AnimatedSprite2D = %main_ship
@onready var shoot_sound : AudioStreamPlayer2D = %shoot_sound
@onready var lock_sound : AudioStreamPlayer2D = %lock_sound
@onready var failed_sound : AudioStreamPlayer2D = %failed_sound

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play():
	sprite.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func play_shoot_sound():
	shoot_sound.play()
	
func play_lock_sound():
	lock_sound.play()
	
func play_failed_sound():
	failed_sound.play()
	
