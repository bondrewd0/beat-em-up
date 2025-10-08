extends MarginContainer

@export var Initial_level:PackedScene



func _on_play_button_pressed() -> void:
	SignalBus.change_level.emit(Initial_level)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
