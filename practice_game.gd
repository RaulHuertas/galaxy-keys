extends Node2D

@onready var enemy_ship_scene_1 : Resource = preload("res://enemy_ship_1.tscn")

#ui controls
@onready var main_ship : MainShip = %main_ship
@onready var target_beam : Line2D = %target_beam
@onready var main_ship_beam : Sprite2D = %main_ship_beam
@onready var health_bar : HealthBar = %health_bar
@onready var dead_label : Control = %dead_label

var enemy_ships : Array = []
var current_ship : EnemyShip = null

const characters_level_1 = ["f","g","h","j"]
const character_levels : Array = [characters_level_1]

enum State {
	FREE,
	LOCKED,
	DEAD
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
	for ship in enemy_ships:
		ship.queue_free()
	enemy_ships.clear()
	var viewport_size = get_viewport_rect().size
	var radius = min(viewport_size.x, viewport_size.y)/2.0
	const min_range : float = 0.65
	const max_range : float = 0.9
	var max_radius = radius*min_range
	var min_radius = radius*max_range
	
	var enemies_to_spawn = min(character_levels[current_level].size(),9)
	for enemy in enemies_to_spawn:
		var new_ship = enemy_ship_scene_1.instantiate()
		var random_angle = randf_range(0.25*PI, -1.25*PI)
		var random_range = randf_range(min_range, max_range)
		var random_radius = random_range*radius
		#new_ship.position.x = viewport_size.x*0.5+viewport_size.x*0.5*cos(random_angle)
		#new_ship.position.y = viewport_size.y*0.5+viewport_size.y*0.5*sin(random_angle)
		#new_ship.position.x = viewport_size.x*0.5+random_radius*cos(random_angle)
		#new_ship.position.y = viewport_size.y*0.5+random_radius*sin(random_angle)
		new_ship.position.x = viewport_size.x*0.5+viewport_size.x*0.5*random_range*cos(random_angle)
		new_ship.position.y = viewport_size.y*0.5+viewport_size.y*0.5*random_range*sin(random_angle)
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
	state = State.FREE		
	%enemy_ship_1.hide()
	var viewport_size = get_viewport_rect().size
	main_ship.position.x = viewport_size.x/2
	main_ship.position.y = viewport_size.y/2
	restart_game()
	#ui
	dead_label.hide()
	
func restart_game():
	health_bar.health = 100
	main_ship_beam.hide()
	target_beam.hide()
	main_ship.free = true
	spawn_enemies()
	
func aim_to_ship(ship_to_rotate:Node2D, target : Node2D):
	var direction = target.global_position - ship_to_rotate.global_position
	ship_to_rotate.rotation = direction.angle() - PI
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#make the main ship aim it's locked enemy
	if state == State.LOCKED:
		aim_to_ship(main_ship.sprite, current_ship.get_sprite())
		target_beam.set_point_position(0, main_ship.position)
		target_beam.set_point_position(1, current_ship.position)
		
		aim_to_ship( current_ship.get_sprite(), main_ship.sprite)
	else:
		pass
		
	
	#for i in enemy_ships.size():
	#		var ship = enemy_ships[i]
	#		aim_to_ship(ship.get_sprite(), main_ship)
	
	pass

func remaining_ships()->int:
	var ret : int = 0
	for ship in enemy_ships.size():
		if enemy_ships[ship].is_destroyed():
			ret = ret+1
	
	return enemy_ships.size()-ret
	
func key_missed():
	shoot_received(12)
	
func shoot_received(hit_value : int):
	if(health_bar.health>hit_value):
		health_bar.health = health_bar.health-hit_value 
	else:
		health_bar.health = 0
		die()
	
func die():
	state = State.DEAD
	dead_label.show()
	pass
	


func animate_shot(posA: Node2D, posB: Node2D):
	var tween = get_tree().create_tween()
	main_ship_beam.position = posA.position
	main_ship_beam.scale = Vector2(1.0, 1.0)
	main_ship_beam.show()
	tween.tween_property(main_ship_beam, "position", posB.position, 0.25)
	tween.tween_property(main_ship_beam, "scale", Vector2(), 0.05)				
	tween.tween_callback(main_ship_beam.hide)
	pass
	
func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		var key = OS.get_keycode_string(event.keycode).to_lower()
		if state == State.DEAD:
			if key == "a": ##### RESTART THE GAME
				dead_label.hide()
				state = State.FREE
				restart_game()			
		if state == State.FREE:
			for ship in enemy_ships:
				if ship.visible && ship.lock_sequence == key:
					print("Locked")
					ship.make_locked()
					main_ship.play_lock_sound()
					main_ship.free = false
					current_ship = ship
					self.state = State.LOCKED
					target_beam.show()
					break
		elif state == State.LOCKED:
			var hit = current_ship.target_try(key)
			if hit:
				print("Hit!")
				main_ship.play_shoot_sound()
				animate_shot(main_ship, current_ship)
				#var tween = get_tree().create_tween()
				#main_ship_beam.position = main_ship.position
				#main_ship_beam.scale = Vector2(1.0, 1.0)
				#main_ship_beam.show()
				#tween.tween_property(main_ship_beam, "position", current_ship.position, 0.25)
				#tween.tween_property(main_ship_beam, "scale", Vector2(), 0.05)				
				#tween.tween_callback(main_ship_beam.hide)				
			else:
				print("No Hit!")
				main_ship.play_failed_sound()
				animate_shot(current_ship,main_ship)
				key_missed()
			if current_ship.is_destroyed():
				print("Hit and destroyed!")
				state = State.FREE
				target_beam.hide()
				main_ship.free = true
				main_ship.play_unlock_sound()
				if remaining_ships()==0:
					spawn_enemies()
