extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	%sprite.play()
	
	
func kill():
	%sprite.hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
