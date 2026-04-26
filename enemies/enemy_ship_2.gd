class_name EnemyShip2
extends EnemyShip

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	super.assign(%sprite,%lock,%target,%aim,%aim_anims)
	damage = 13
