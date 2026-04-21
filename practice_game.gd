extends Node2D

var enemy_ships : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	print(%nuty_ship)
	%nuty_ship.play()
	
	
	#Initialize enemies
	enemy_ships.append(%enemy_ship_1)
	for i in enemy_ships.size():
		var ship = enemy_ships[i]
		ship.set_assignations("jj","fghjfh")
	


func aim_to_ship(ship_to_rotate:Node2D, target : Node2D):
	var direction = target.global_position - ship_to_rotate.global_position
	ship_to_rotate.rotation = direction.angle() - PI
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#make the main ship aim it's locked enemy
	aim_to_ship(%nuty_ship, %enemy_ship_1.get_sprite())
	
	#make the enemy shis aim the main ship
	aim_to_ship(%enemy_ship_1.get_sprite(), %nuty_ship)
	pass
