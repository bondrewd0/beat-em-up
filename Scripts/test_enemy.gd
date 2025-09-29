extends CharacterBody2D

var knckback:Vector2=Vector2.ZERO
var timeknockback=0.0

func _on_hit_box_area_entered(area: Area2D) -> void:
	var hit_dir=(global_position-area.get_parent().global_position).normalized()
	if $AnimatedSprite2D.is_playing() and $AnimatedSprite2D.animation=="hit":
		$AnimatedSprite2D.stop()
	$AnimatedSprite2D.play("hit")
	apply_knockback(hit_dir,50,0.2)
func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation=="hit":
		$AnimatedSprite2D.play("Idle")

func apply_knockback(dir:Vector2, force:float, duration:float):
	knckback=dir*force
	timeknockback=duration

func _process(delta: float) -> void:
	if timeknockback>0.0:
		velocity.x=knckback.x
		timeknockback-=delta
		if timeknockback<=0.0:
			knckback=Vector2.ZERO
	else:velocity=Vector2.ZERO
	move_and_slide()
