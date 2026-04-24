class_name HealthBar
extends Node2D
@onready var health_bar = %health
@onready var camouflage_bar = %camouflage

@export var health = 100:
	set(value):
		health = value
		health_bar.value = value
		if health_bar.has_theme_stylebox_override("fill"):
			var style = health_bar.get_theme_stylebox("fill")
			if value < health_bar.max_value * 0.3:
				style.bg_color = Color.RED
			elif value < health_bar.max_value * 0.6:
				style.bg_color = Color.YELLOW
			else:
				style.bg_color = Color.GREEN
	get():
		return health
		
@export var camouflage : float = 100.0:
	set(value):
		camouflage = value
		camouflage_bar.value = value
	get():
		return camouflage

# Called when the node enters the scene tree for the first time.
func _ready():
	var style = health_bar.get_theme_stylebox("fill").duplicate()
	health_bar.add_theme_stylebox_override("fill", style)
	health_bar.value = health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
