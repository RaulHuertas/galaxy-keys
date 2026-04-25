extends Node2D


#ui controls
@onready var main_ship : MainShip = %main_ship
@onready var target_beam : Line2D = %target_beam
@onready var enemy_beam : Line2D = %enemy_beam
@onready var main_ship_beam : Sprite2D = %main_ship_beam
@onready var enemy_ship_beam : Sprite2D = %enemy_ship_beam
@onready var status_bar : HealthBar = %status_bar
@onready var dead_label : Control = %dead_label

var enemy_ships : Array = []
var current_ship : EnemyShip = null

const characters_level_1 = ["f","g","h","j"]
const characters_level_2 = ["f","g","h","j","r","t","y","u","c","v","n","m"]
const character_levels : Array = [characters_level_1,characters_level_2]


@onready var enemy_ship_scene_1 : Resource = preload("res://enemies/enemy_ship_1.tscn")
@onready var enemy_ship_scene_2 : Resource = preload("res://enemies/enemy_ship_2.tscn")
@onready var enemies_level_1 : Array = [enemy_ship_scene_1]
@onready var enemies_level_2 : Array = [enemy_ship_scene_1,enemy_ship_scene_2]
@onready var enemies = [
	enemies_level_1,
	enemies_level_2
]

func getRandomEnemyInstance(level: int)->Node:
	var n_enemies : int = enemies[level].size()
	var index : int = randi_range(0, n_enemies-1)
	return enemies[level][index].instantiate()

enum State {
	FREE,
	LOCKED,
	DEAD
}

@export var state = State.FREE:
	set(value):
		state = value
	get():
		return state

var current_level : int = 0
func get_target_array(level: int =0, limit: int = 1)->String:
	var result : String = ""
	for i in limit:
		var random_index : int = randi()%character_levels[level].size()
		result = result+(character_levels[level][random_index])
	return result

var camo_tween : Tween = null
func reactivate_camo():
	cancel_camo() # Abort the previous animation.
	if (state==State.FREE) or (state==State.LOCKED):
		camo_tween = create_tween()
		camo_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		main_ship.camouflaged = true
		status_bar.camouflage = 100
		camo_tween.tween_property(status_bar, "camouflage", 0, 1.0)
		camo_tween.tween_callback(camo_down)
	
func cancel_camo():
	if camo_tween:
		camo_tween.kill()

func camo_down():
	shoot_received(18)
	print("NO CAMO")
	trigger_enemy_shot()
	reactivate_camo()
	
	
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
		#var new_ship = enemy_ship_scene_2.instantiate()
		var new_ship = getRandomEnemyInstance(1)
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
	status_bar.health = 100
	main_ship_beam.hide()
	enemy_ship_beam.hide()
	target_beam.hide()
	enemy_beam.hide()
	main_ship.camouflaged = true
	spawn_enemies()
	reactivate_camo()
	
func aim_to_ship(ship_to_rotate:Node2D, target : Node2D):
	var direction = target.global_position - ship_to_rotate.global_position
	ship_to_rotate.rotation = direction.angle() - PI
	
	
@onready var prev_state = state
@onready var was_camouflaged = main_ship.camouflaged
func _process(delta):
	#make the main ship aim it's locked enemy
	var state_has_changed = prev_state != state
	if state == State.LOCKED :
		aim_to_ship(main_ship.sprite, current_ship.get_sprite())
		target_beam.set_point_position(0, main_ship.position)
		target_beam.set_point_position(1, current_ship.position)
		aim_to_ship( current_ship.get_sprite(), main_ship.sprite)
		
	prev_state = state

func remaining_ships()->int:
	var ret : int = 0
	for ship in enemy_ships.size():
		if enemy_ships[ship].is_destroyed():
			ret = ret+1
	return enemy_ships.size()-ret
	
func key_missed():
	shoot_received(12)
	
func shoot_received(hit_value : int):
	if(status_bar.health>hit_value):
		status_bar.health = status_bar.health-hit_value 
	else:
		status_bar.health = 0
		die()
	
func die():
	state = State.DEAD
	dead_label.show()
	
func free_time()->float:
	if state == State.FREE:
		return 0.4
	else:
		return 0.3
	
func animate_shot(posA: Node2D, posB: Node2D, sprite:Node2D = main_ship_beam):
	var tween = get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite.position = posA.position
	sprite.scale = Vector2(1.0, 1.0)
	sprite.show()
	tween.tween_property(sprite, "position", posB.position, free_time())
	tween.tween_property(sprite, "scale", Vector2(), 0.05)				
	tween.tween_callback(sprite.hide)
	
func trigger_enemy_shot():
	for ship in enemy_ships:
		if state == State.FREE:
			if ship.visible:
				animate_shot(ship, main_ship, enemy_ship_beam)
				main_ship.play_failed_sound()
		if state == State.LOCKED:
			animate_shot(current_ship, main_ship, enemy_ship_beam)
			main_ship.play_failed_sound()

	
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
				if ship.visible and ship.lock_sequence == key:# ENTER LOCKED STATE
					print("Locked")
					ship.make_locked()
					main_ship.play_lock_sound()
					current_ship = ship
					self.state = State.LOCKED
					target_beam.show()
					reactivate_camo()
					# CAMO
					#main_ship.camouflaged = false
					#cancel_camo()
					break
			
			
		elif state == State.LOCKED: # SHOOT TO THE ENEMIES
			var hit = current_ship.target_try(key)
			if hit:
				print("Hit!")
				main_ship.play_shoot_sound()
				animate_shot(main_ship, current_ship)
				reactivate_camo()
			else:
				print("No Hit!")
				main_ship.play_failed_sound()
				animate_shot(current_ship,main_ship)
				key_missed()
			if current_ship.is_destroyed():
				print("Enemy destroyed!")
				state = State.FREE
				target_beam.hide()
				reactivate_camo()
				main_ship.play_unlock_sound()
				if remaining_ships()==0:
					spawn_enemies()
