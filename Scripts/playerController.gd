extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var attack_timer: Timer = $AttackTimer

@export var Speed:float=10
var can_move:bool=true
var can_attack:bool=true
var vertical_movement:float=0.0
var horizontal_movement:float=0.0
var attack_counter:int=0
var load_next_attack:bool=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
		if horizontal_movement==1:
			sprite.flip_h=false
		if horizontal_movement!=0 or vertical_movement!=0:
			sprite.play("Walk")
		else:
			sprite.play("Idle")
	if event.is_action_pressed("Attack") and not can_attack:
		print("Loading")
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
		print("attack finished")
		if load_next_attack:
			print("playing")
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
		print("attack finished")
		can_move=true
		can_attack=true
		if vertical_movement==0 and horizontal_movement==0:
			sprite.play("Idle")
		else:
			sprite.play("Walk")
		attack_timer.start()
		attack_counter=0

func _on_attack_timer_timeout() -> void:
	print("Done")
	attack_counter=0
