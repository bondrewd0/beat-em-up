extends Node2D

var first_level=preload("res://Scenes/level.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var level_inst=first_level.instantiate()
	add_child(level_inst)
