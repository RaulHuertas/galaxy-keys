extends Node2D

@onready var enemy_ship_scene_1 : Resource = preload("res://enemy_ship_1.tscn")

var enemy_ships : Array = []
var current_ship : EnemyShip = null
# Called when the node enters the scene tree for the first time.
const characters_level_1 = ["f","g","h","j"]

const character_levels : Array = [characters_level_1]

enum State {
	FREE,
	LOCKED
}
var state = State.FREE

var current_level : int = 0
func get_target_array(level: int =0, limit: int = 1)->String:
	var result : String = ""
	for i in limit:
		var random_index : int = randi()%character_levels[level].size()
		result = result+(character_levels[level][random_index])
	return result

func _ready():
	print(%nuty_ship)
	%nuty_ship.play()
	state = State.FREE		
	%enemy_ship_1.hide()
	
	#Initialize enemies
	#enemy_ships.append(%enemy_ship_1)
	for enemy in character_levels[current_level].size():
		var new_ship = enemy_ship_scene_1.instantiate()
		new_ship.position.x= 600
		new_ship.position.y= 400
		self.add_child(new_ship)
		enemy_ships.append(new_ship)
		new_ship.show()
		print("enemy created")
	
	for i in enemy_ships.size():
		var ship = enemy_ships[i]
		ship.set_assignations(get_target_array(current_level,1),get_target_array(current_level,5))
	
func aim_to_ship(ship_to_rotate:Node2D, target : Node2D):
	var direction = target.global_position - ship_to_rotate.global_position
	ship_to_rotate.rotation = direction.angle() - PI
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#make the main ship aim it's locked enemy
	if state == State.LOCKED:
		aim_to_ship(%nuty_ship, %enemy_ship_1.get_sprite())
	else:
		%nuty_ship.rotation = %nuty_ship.rotation+0.5*delta
	
	
	#make the enemy shis aim the main ship
	aim_to_ship(%enemy_ship_1.get_sprite(), %nuty_ship)
	pass

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		var key = OS.get_keycode_string(event.keycode).to_lower()
		if state == State.FREE:
			for ship in enemy_ships:
				if ship.visible && ship.lock_sequence == key:
					ship.make_locked()
					current_ship = ship
					self.state = State.LOCKED
		elif state == State.LOCKED:
			var hit = current_ship.target_try(key)
			print("Hit!")
			if current_ship.is_destroyed():
				print("Hit and destroyed!")
				state = State.FREE
			pass
			
			
			
