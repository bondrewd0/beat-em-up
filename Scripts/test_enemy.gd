extends CharacterBody2D
class_name Enemy
@export var AttackZone:Area2D=null

var knckback:Vector2=Vector2.ZERO
var timeknockback=0.0
var can_be_knocked:bool=true
var player_ref:Player=null
var player_close:bool=false
var tracking:bool=true
var can_move:bool=true
func _ready() -> void:
	AttackZone.area_entered.connect(player_on_range)
	AttackZone.area_exited.connect(player_out_of_range)

func player_on_range(area:Area2D):
	var player_node=area.get_parent()
	if player_node is Player:
		print("hittable")
		tracking=false
		velocity=Vector2.ZERO
		if not player_ref.dead:
			player_close=true

func player_out_of_range(area:Area2D):
	player_close=false
	tracking=true

func move_to_target(delta:float):
	var player_pos=player_ref.global_position
	var current_pos=global_position
	var direction=(player_pos-current_pos).normalized()
	if direction.x<0:
		flip_stuff(false)
	else:
		flip_stuff(true)
	velocity=direction*10

func _on_hit_box_area_entered(area: Area2D) -> void:
	var hit_dir=(global_position-area.get_parent().global_position).normalized()
	if $AnimatedSprite2D.is_playing() and $AnimatedSprite2D.animation=="hit":
		$AnimatedSprite2D.stop()
	$AnimatedSprite2D.play("hit")
	if can_be_knocked:
		apply_knockback(hit_dir,50,0.2)
		can_be_knocked=false
func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation=="hit":
		$AnimatedSprite2D.play("Idle")

func apply_knockback(dir:Vector2, force:float, duration:float):
	can_move=false
	tracking=false
	velocity=Vector2.ZERO
	print("dir:", dir)
	knckback=dir*force
	timeknockback=duration

func _process(delta: float) -> void:
	if timeknockback>0.0:
		get_knocked(delta)
	if can_move and tracking:
		move_to_target(delta)
	move_and_slide()

func get_knocked(delta:float):
	velocity.x=knckback.x
	timeknockback-=delta
	if timeknockback<=0.0:
		knckback=Vector2.ZERO
		can_be_knocked=true
		can_move=true
		if not player_close:
			tracking=true
		print("knock done")

func apply_damage():
	if not player_ref.dead:
		player_ref.take_damage(2,self)

func flip_stuff(flip:bool):
	if flip and $AnimatedSprite2D.flip_h!=true:
		$AnimatedSprite2D.flip_h=true
		AttackZone.scale.x=-1
	if not flip and $AnimatedSprite2D.flip_h==true:
		$AnimatedSprite2D.flip_h=false
		AttackZone.scale.x=1
