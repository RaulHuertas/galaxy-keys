class_name MainShip
extends Node2D

@onready var sprite: AnimatedSprite2D = %main_ship
@onready var shoot_sound : AudioStreamPlayer2D = %shoot_sound
@onready var lock_sound : AudioStreamPlayer2D = %lock_sound
@onready var unlock_sound : AudioStreamPlayer2D = %unlock_sound
@onready var failed_sound : AudioStreamPlayer2D = %failed_sound

@export var camouflaged : bool = true:
	set(value):
		if(camouflaged==value):
			return
		camouflaged = value
		if value:
			sprite.modulate.a = 1.0
		else:
			sprite.modulate.a = 255.0
	get():
		return camouflaged
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if free:
		sprite.rotation = sprite.rotation+0.5*delta

func play_shoot_sound():
	shoot_sound.play()
	
func play_lock_sound():
	lock_sound.play()

func play_unlock_sound():
	unlock_sound.play()

func play_failed_sound():
	failed_sound.play()
	
