extends Control

@export var MainMenu:PackedScene

var current_level=null
var level_ref:PackedScene=null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.change_level.connect(load_level)
	SignalBus.restart.connect(restart_level)
	add_child(MainMenu.instantiate())
	current_level=get_child(0)
	#print(current_level)

func load_level(level:PackedScene):
	level_ref=level
	remove_child(current_level)
	add_child(level.instantiate())
	current_level=get_child(0)
	#print(current_level)

func restart_level():
	
	remove_child(current_level)
	current_level.queue_free()
	add_child(level_ref.instantiate())
	current_level=get_child(0)
