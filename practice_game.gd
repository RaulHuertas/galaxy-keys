extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	print(%nuty_ship)
	%nuty_ship.play()
	
	#%enemy_ship.hide()
	pass # Replace with function body.


func aim_to_ship(ship_to_rotate:Node2D, target : Node2D):
	var direction = target.global_position - ship_to_rotate.global_position
	ship_to_rotate.rotation = direction.angle() - PI
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#make the main ship aim it's locked enemy
	aim_to_ship(%nuty_ship, %enemy_ship_1.sprite())
	
	#make the enemy shis aim the main ship
	aim_to_ship(%enemy_ship_1.sprite(), %nuty_ship)
	pass
