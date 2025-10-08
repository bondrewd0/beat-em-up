extends Button

@export_file("*.tscn") var Next_screen:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(go_to_screen)

func go_to_screen():
	var aux=load(Next_screen)
	SignalBus.change_level.emit(aux)
