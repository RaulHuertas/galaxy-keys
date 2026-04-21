extends Node2D

@onready var enemy_ship_scene_1 : Resource = preload("res://enemy_ship_1.tscn")

var enemy_ships : Array = []
var current_ship : EnemyShip = null
# Called when the node enters the scene tree for the first time.
const characters_level_1 = ["f","g","h","j"]
@onready var main_ship = %main_ship
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

func spawn_enemies():
	enemy_ships.clear()
	var viewport_size = get_viewport_rect().size
	var radius = min(viewport_size.x, viewport_size.y)/2.0
	var max_radius = radius*0.95
	var min_radius = radius*0.7
	
	
	for enemy in character_levels[current_level].size():
		var new_ship = enemy_ship_scene_1.instantiate()
		var random_angle = randf_range(0.0, 2.0*PI)
		var random_radius = randf_range(min_radius, max_radius)
		#new_ship.position.x = viewport_size.x*0.5+viewport_size.x*0.5*cos(random_angle)
		#new_ship.position.y = viewport_size.y*0.5+viewport_size.y*0.5*sin(random_angle)
		new_ship.position.x = viewport_size.x*0.5+random_radius*cos(random_angle)
		new_ship.position.y = viewport_size.y*0.5+random_radius*sin(random_angle)
		self.add_child(new_ship)
		enemy_ships.append(new_ship)
		new_ship.show()
		print("enemy created")
	
	var random_offset:int = randi()
	for i in enemy_ships.size():
		var ship = enemy_ships[i]
		
		ship.set_assignations(
			character_levels[current_level][(i+random_offset)%enemy_ships.size()],
			get_target_array(current_level,5)
		)
		
func _ready():
	print(%nuty_ship)
	main_ship.play()
	state = State.FREE		
	%enemy_ship_1.hide()
	var viewport_size = get_viewport_rect().size
	main_ship.position.x = viewport_size.x/2
	main_ship.position.y = viewport_size.y/2
	#Initialize enemies
	spawn_enemies()
	
func aim_to_ship(ship_to_rotate:Node2D, target : Node2D):
	var direction = target.global_position - ship_to_rotate.global_position
	ship_to_rotate.rotation = direction.angle() - PI
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#make the main ship aim it's locked enemy
	if state == State.LOCKED:
		aim_to_ship(main_ship, current_ship.get_sprite())
	else:
		main_ship.rotation = main_ship.rotation+0.5*delta
		
	for i in enemy_ships.size():
			var ship = enemy_ships[i]
			aim_to_ship(ship.get_sprite(), main_ship)
	
	pass

func remaining_ships()->int:
	var ret : int = 0
	for ship in enemy_ships.size():
		if enemy_ships[ship].is_destroyed():
			ret = ret+1
	
	return enemy_ships.size()-ret
	
func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		var key = OS.get_keycode_string(event.keycode).to_lower()
		if state == State.FREE:
			for ship in enemy_ships:
				if ship.visible && ship.lock_sequence == key:
					ship.make_locked()
					current_ship = ship
					self.state = State.LOCKED
					break
		elif state == State.LOCKED:
			var hit = current_ship.target_try(key)
			print("Hit!")
			if current_ship.is_destroyed():
				print("Hit and destroyed!")
				state = State.FREE
				if remaining_ships()==0:
					spawn_enemies()
			pass
			
			
			
