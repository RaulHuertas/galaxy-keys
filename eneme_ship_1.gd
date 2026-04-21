class_name EnemyShip
extends Node2D

@onready var sprite = %sprite
@onready var lock_label = %lock
@onready var sprite_label = %target

enum State {
	FREE,
	LOCKED,
	DESTROYED
}

enum FreedMode {
	ERROR_LIMIT,
	
}

var state : State = State.FREE
var lock_sequence : String = ""
var target: String = ""
var target_position: int = 0
var index : int = 0
var error_limit = 3
var error_count = 0

signal wrong_target_code(position:int, total:int)
signal destroyed()
signal freed()

# Called when the node enters the scene tree for the first time.
func _ready():
	%sprite.play()
	
func get_sprite():
	return %sprite

func set_assignations(lock_sequence:String, target:String, index : int =0, error_limit:int =3 ):
	self.lock_sequence = lock_sequence
	self.target = target
	self.index = index
	self.error_limit = error_limit
	self.error_count = 0
	#UI [color=blue]blue[/color][color=red]red[/color]
	%lock.text = "[color=blue]"+lock_sequence+"[/color]"
	%target.text = "[color=blue]"+target+"[/color]"
	%lock.show()
	%target.hide()
	
func make_locked()->void:
	self.state = State.LOCKED
	%lock.hide()
	%target.show()
	
func target_try(typed: String)->bool:
	if target == null:
		return false
	if state == State.FREE:
		return false
	if state == State.DESTROYED:
		return false
	if(target[target_position]==typed):
		target_position = target_position+1
		#update ui
		var ready_str = target.substr(0,target_position)
		var missing_str = target.substr(target_position,target.length()-target_position)
		%target.text = "[color=transparent]"+ready_str+"[/color]"+"[color=blue]"+missing_str+"[/color]"
		if(target_position==target.length()):
			destroyed.emit()
			hide()
			state = State.DESTROYED
		return true
	else :
		error_count = error_count+1
		if error_count==error_limit:
			state = State.FREE
			freed.emit()
		else:
			wrong_target_code.emit(target_position, target.length())
		
		return false
		
func is_destroyed()->bool:
	return state == State.DESTROYED
	
func kill():
	%sprite.hide()

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
