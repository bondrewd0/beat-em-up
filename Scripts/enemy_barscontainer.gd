extends VBoxContainer


@onready var defeated_removal: Timer = $DefeatedRemoval
var bar_amount=0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.enemy_hit.connect(add_bars)


func add_bars(enemy_bar:EnemyHealth):
	if bar_amount<=3 and enemy_bar.in_use==false:
		bar_amount+=1
		
		add_child(enemy_bar)
		enemy_bar.in_use=true
	pass
