extends Node2D

@export var Player_node:Player=null
@export var Enemy_dir:PackedScene

var enemy_counter:int=0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for enemy in get_children():
		if enemy is Enemy:
			enemy.player_ref=Player_node
	for area in get_children():
		if area is EnemySpawner:
			area.Player_ref=Player_node
			enemy_counter+=1
	SignalBus.enemy_dead.connect(check_level_complete)

func check_level_complete():
	#print("checking")
	enemy_counter-=1
	if enemy_counter==0:
		print("victory")
	else: print("left: ", enemy_counter)
