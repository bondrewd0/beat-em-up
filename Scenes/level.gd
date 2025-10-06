extends Node2D

@export var Player_node:Player=null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for enemy in get_children():
		if enemy is Enemy:
			enemy.player_ref=Player_node
