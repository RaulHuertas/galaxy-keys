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
var lock : String = ""
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

func set_assignations(lock:String, target:String, index : int =0, error_limit:int =3 ):
	self.lock = lock
	self.target = lock
	self.index = index
	self.error_limit = error_limit
	self.error_count = 0
	#UI
	$lock.text = lock
	$target.text = target
	$lock.show()
	$target.hide()
	

func target_try(typed: String)->bool:
	if target == null:
		return false
	if state == State.FREE:
		return false
	if(target[target_position]==typed):
		target_position = target_position+1
		if(target_position==target.length()):
			destroyed.emit()
		return true
	else :
		error_count = error_count+1
		if error_count==error_limit:
			state = State.FREE
			freed.emit()
		else:
			wrong_target_code.emit(target_position, target.length())
		
		return false
		

func kill():
	%sprite.hide()

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
