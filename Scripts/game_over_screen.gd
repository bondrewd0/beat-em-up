extends MarginContainer


func _on_restart_button_pressed() -> void:
	SignalBus.restart.emit()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
