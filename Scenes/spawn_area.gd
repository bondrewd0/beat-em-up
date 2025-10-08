extends Area2D
class_name EnemySpawner
@export var Used:bool=false
@export var Enemy_dir:PackedScene
@export var Player_ref:Player
func _on_area_entered(area: Area2D) -> void:
	if not Used:
		var enemy_ins=Enemy_dir.instantiate()
		enemy_ins.player_ref=Player_ref
		get_parent().call_deferred("add_child",enemy_ins)
		enemy_ins.global_position=global_position
		print("Spawning")
		
		Used=true
