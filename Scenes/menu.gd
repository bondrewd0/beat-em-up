extends MarginContainer

@export_file("*.tscn") var Initial_level:String



func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(Initial_level)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
