extends Control


@export var Load_Scene:PackedScene
@export var in_time:float=0.5
@export var Fade_time:float=1.5
@export var pause_time:float=1.5
@export var Fade_out_time:float=1.5
@export var out_time:float=0.5
@export var splash_screen:TextureRect

func _ready() -> void:
	fade()

func fade():
	splash_screen.modulate.a=0.0
	var tween=self.create_tween()
	tween.tween_interval(in_time)
	tween.tween_property(splash_screen, "modulate:a",1.0,Fade_time)
	tween.tween_interval(pause_time)
	tween.tween_property(splash_screen, "modulate:a",0.0,Fade_out_time)
	tween.tween_interval(out_time)
	await  tween.finished
	get_tree().change_scene_to_packed(Load_Scene)
