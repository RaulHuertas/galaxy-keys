class_name HealthBar
extends Node2D
@onready var bar = %bar

@export var health = 100:
	set(value):
		health = value
		bar.value = value
		if bar.has_theme_stylebox_override("fill"):
			var style = bar.get_theme_stylebox("fill")
			if value < bar.max_value * 0.3:
				style.bg_color = Color.RED
			if value < bar.max_value * 0.6:
				style.bg_color = Color.YELLOW
			else:
				style.bg_color = Color.GREEN

	get():
		return health

# Called when the node enters the scene tree for the first time.
func _ready():
	var style = bar.get_theme_stylebox("fill").duplicate()
	bar.add_theme_stylebox_override("fill", style)
	bar.value = health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
