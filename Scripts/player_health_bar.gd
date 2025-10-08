extends TextureProgressBar

@onready var effect: AnimationPlayer = $Effect


func _on_value_changed(value: float) -> void:
	print(1)
	effect.play("Flash")
