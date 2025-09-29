extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var attack_timer: Timer = $AttackTimer

@onready var attack_1: Area2D = $Attackcolliders/Attack1
@onready var attack_2: Area2D = $Attackcolliders/Attack2
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var Speed:float=10
var can_move:bool=true
var can_attack:bool=true
var vertical_movement:float=0.0
var horizontal_movement:float=0.0
var attack_counter:int=0
var load_next_attack:bool=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.animation_changed.connect(_on_sprite_animation_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction=Vector2(horizontal_movement,vertical_movement)
	velocity=direction*Speed
	if can_move:
		move_and_slide()

func _input(event: InputEvent) -> void:
	vertical_movement=Input.get_axis("Up","Down")
	horizontal_movement=Input.get_axis("Left","Right")
	if can_move:
		if horizontal_movement==-1:
			sprite.flip_h=true
			attack_1.position=Vector2(-25.5,1.5)
			attack_2.position=Vector2(-32,-10.5)
		if horizontal_movement==1:
			sprite.flip_h=false
			attack_1.position=Vector2(32,1.5)
			attack_2.position=Vector2(23,-10.5)
		if horizontal_movement!=0 or vertical_movement!=0:
			if load_next_attack:
				load_next_attack=false
			sprite.play("Walk")
		else:
			sprite.play("Idle")
	if event.is_action_pressed("Attack") and not can_attack:
		load_next_attack=true
	if event.is_action_pressed("Attack") and can_attack:
		can_move=false
		can_attack=false
		attack_counter+=1
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

func _on_attack_timer_timeout() -> void:
	attack_counter=0


func _on_sprite_animation_changed() -> void:
	if sprite.animation=="Attack1":
		animation_player.play("TriggerAttack1")
	if sprite.animation=="Attack2":
		animation_player.play("TriggerAttack2")
