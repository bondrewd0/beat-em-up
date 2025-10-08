extends Control

@export var MainMenu:PackedScene
@onready var game_over_screen: MarginContainer = $GameOverScreen
@onready var victory_screen: MarginContainer = $VictoryScreen

var current_level=null
var level_ref:PackedScene=null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	SignalBus.change_level.connect(load_level)
	SignalBus.restart.connect(restart_level)
	SignalBus.player_dead.connect(load_death_screen)
	SignalBus.level_completed.connect(show_victory_screen)
	add_child(MainMenu.instantiate())
	move_child(game_over_screen,2)
	move_child(victory_screen,3)
	current_level=get_child(0)
	
	print(current_level)

func load_death_screen():
	game_over_screen.show()

func show_victory_screen():
	victory_screen.show()

func load_level(level:PackedScene):
	game_over_screen.hide()
	victory_screen.hide()
	level_ref=level
	remove_child(current_level)
	add_child(level.instantiate())
	move_child(game_over_screen,2)
	move_child(victory_screen,3)
	current_level=get_child(0)
	#print(current_level)

func restart_level():
	game_over_screen.hide()
	victory_screen.hide()
	remove_child(current_level)
	current_level.queue_free()
	add_child(level_ref.instantiate())
	move_child(game_over_screen,2)
	move_child(victory_screen,3)
	current_level=get_child(0)
