extends CharacterBody2D
class_name Player
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var attack_timer: Timer = $AttackTimer
@onready var sfx: AudioStreamPlayer2D = $Sfx
@onready var attack_1: Area2D = $Attackcolliders/Attack1
@onready var attack_2: Area2D = $Attackcolliders/Attack2
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var HP_Bar:TextureProgressBar=null
@export var Speed:float=10
@export var Knock_strength:float=50
@export var HealthPoints:int=10
var knckback:Vector2=Vector2.ZERO
var timeknockback=0.0
var can_move:bool=true
var can_attack:bool=true
var vertical_movement:float=0.0
var horizontal_movement:float=0.0
var attack_counter:int=0
var load_next_attack:bool=false
var can_be_knocked:bool=true
var dead:bool=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.animation_changed.connect(_on_sprite_animation_changed)
	HP_Bar.max_value=HealthPoints
	HP_Bar.value=HealthPoints

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction=Vector2(horizontal_movement,vertical_movement)
	velocity=direction*Speed
	if timeknockback>0.0:
		get_knocked(delta)
	if can_move:
		move_and_slide()


func _input(event: InputEvent) -> void:
	vertical_movement=Input.get_axis("Up","Down")
	horizontal_movement=Input.get_axis("Left","Right")
	if event.is_action_released("Restart"):
		SignalBus.restart.emit()
	if event.is_action_pressed("Test"):
		print("Testing")
		print("Testing complete")
	if can_move:
		if horizontal_movement==-1:
			flip_stuff(true)
		if horizontal_movement==1:
			flip_stuff(false)
		if horizontal_movement!=0 or vertical_movement!=0:
			if load_next_attack:
				load_next_attack=false
			sprite.play("Walk")
			if not sfx.playing:
				sfx.play()
		else:
			if not dead:
				if sfx.playing:
					sfx.stop()
				sprite.play("Idle")
	if event.is_action_pressed("Attack") and not can_attack:
		load_next_attack=true
	if event.is_action_pressed("Attack") and can_attack:
		can_move=false
		can_attack=false
		attack_counter+=1
		if sfx.playing:
					sfx.stop()
		match attack_counter:
			1:
				sprite.play("Attack1")
			2:
				sprite.play("Attack2")
				attack_counter=0
	

func _on_sprite_animation_finished() -> void:
	if sprite.animation=="Attack1":
		if load_next_attack:
			sprite.play("Attack2")
			attack_counter=0
			attack_timer.start()
			load_next_attack=false
			return
		can_move=true
		can_attack=true
		attack_timer.start()
		if vertical_movement==0 and horizontal_movement==0:
			sprite.play("Idle")
		else:
			sprite.play("Walk")
	if sprite.animation=="Attack2":
		if load_next_attack:
			sprite.play("Attack1")
			attack_counter=0
			attack_timer.start()
			load_next_attack=false
			return
		can_move=true
		can_attack=true
		if vertical_movement==0 and horizontal_movement==0:
			sprite.play("Idle")
		else:
			sprite.play("Walk")
		attack_timer.start()
		attack_counter=0
	if sprite.animation=="Dead":
		SignalBus.player_dead.emit()
		print("dead xd")

func _on_attack_timer_timeout() -> void:
	attack_counter=0

func _on_sprite_animation_changed() -> void:
	if sprite.animation=="Attack1":
		animation_player.play("TriggerAttack1")
	if sprite.animation=="Attack2":
		animation_player.play("TriggerAttack2")

func take_damage(damage:int, source:Node2D):
	if sfx.playing:
		sfx.stop()
	var hit_dir=(global_position-source.global_position).normalized()
	if hit_dir.x <0:
		flip_stuff(false)
	else:
		flip_stuff(true)
	apply_knockback(hit_dir,Knock_strength,0.2)
	HealthPoints-=damage
	HP_Bar.value=HealthPoints
	if HealthPoints<=0:
		
		can_move=false
		dead=true
		can_attack=false
		can_be_knocked=false
		sprite.play("Dead")
		


func apply_knockback(dir:Vector2, force:float, duration:float):
	interrupt()
	sprite.play("Hitted")
	can_attack=false
	can_move=false
	knckback=dir*force
	timeknockback=duration

func get_knocked(delta:float):
	velocity.x=knckback.x
	timeknockback-=delta
	move_and_slide()
	if timeknockback<=0.0:
		knckback=Vector2.ZERO
		can_be_knocked=true
		can_attack=true
		can_move=true
		await sprite.animation_finished
		if not dead:
			if horizontal_movement!=0 or vertical_movement!=0:
				sprite.play("Walk")
			else:
				print(3)
				sprite.play("Idle")
			#print("knock done")

func interrupt():
	animation_player.call_deferred("play","RESET")
	sprite.stop()

func flip_stuff(flip:bool):
	if flip and sprite.flip_h!=true:
		sprite.flip_h=true
		attack_1.position=Vector2(-25.5,1.5)
		attack_2.position=Vector2(-32,-10.5)
	if not flip and sprite.flip_h==true:
		sprite.flip_h=false
		attack_1.position=Vector2(32,1.5)
		attack_2.position=Vector2(23,-10.5)
