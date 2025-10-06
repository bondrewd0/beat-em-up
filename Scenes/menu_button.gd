extends Button

@export_file("*.tscn") var Next_screen:String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(go_to_screen)


func go_to_screen():
	get_tree().change_scene_to_file(Next_screen)
