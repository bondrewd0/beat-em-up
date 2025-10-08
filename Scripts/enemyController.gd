extends  CharacterBody2D
class_name Enemy
@export var AttackZone:Area2D=null
@export var HitBox:Area2D=null
@export var TrackTimer:Timer=null
@export var AttackTimer:Timer=null
@export var RangeTimer:Timer=null
@export var Speed:float=20
@export var Health_Points:int=5
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var after_spawn_timer: Timer = $AfterSpawnTimer
@onready var floor_detection: CollisionShape2D = $FloorDetection
@onready var collision_shape_2d: CollisionShape2D = $HitBox/CollisionShape2D
@onready var collision_shape_2d2: CollisionShape2D = $AttackZone/CollisionShape2D
@onready var enemy_hp_bar: EnemyHealth = $EnemyHPBar
@onready var sfx: AudioStreamPlayer2D = $Sfx
@onready var attacksfx: AudioStreamPlayer2D = $Attacksfx
@onready var hitted_sfx: AudioStreamPlayer2D = $HittedSfx

var knckback:Vector2=Vector2.ZERO
var timeknockback=0.0
var can_be_knocked:bool=true
var player_ref:Player=null
var player_close:bool=false
var tracking:bool=false
var can_move:bool=false
var dead:bool=false
func _ready() -> void:
	sprite.play("Spawn")
	AttackZone.area_entered.connect(player_on_range)
	AttackZone.area_exited.connect(player_out_of_range)
	TrackTimer.timeout.connect(track_switch)
	AttackTimer.timeout.connect(attack_timeout)
	SignalBus.player_dead.connect(stop)

func stop():
	tracking=false
	can_move=false
	sprite.stop()
	TrackTimer.stop()
	AttackTimer.stop()
	player_close=false
	AttackZone.set_deferred("monitoring",false)
	AttackZone.set_deferred("monitorable",false)
	HitBox.set_deferred("monitoring",false)
	HitBox.set_deferred("monitorable",false)
	floor_detection.set_deferred("disable",true)
	collision_shape_2d.set_deferred("disable",true)
	collision_shape_2d2.set_deferred("disable",true)
	player_ref=null
	if not dead:
		print(1)
		sprite.play("Idle")
		sfx.stop()

func attack_timeout():
	#print(player_close)
	if player_close and not player_ref.dead:
		sprite.position=Vector2(-10,-29)
		sprite.play("Attack")
		await sprite.animation_finished
		if player_close:
			apply_damage()
			AttackTimer.start()
	else:
		if not dead:
			print(2)
			sprite.play("Idle")
			sfx.stop()

func track_switch():
	if not player_close:
		tracking=!tracking
		#print("Tracking: ",tracking)
		if not tracking:
			sprite.play("Idle")
			print(3)
			TrackTimer.wait_time=1
			can_move=false
			velocity=Vector2.ZERO
			sfx.stop()
		else:
			sprite.play("Move")
			sfx.play()
			TrackTimer.wait_time=4
			can_move=true
		TrackTimer.start()

func player_on_range(area:Area2D):
	if dead:
		return
	var player_node=area.get_parent()
	if player_node is Player:
		#print("hittable")
		RangeTimer.start()
		TrackTimer.stop()
		if not player_ref.dead:
			player_close=true
		TrackTimer.stop()
		await RangeTimer.timeout
		tracking=false
		velocity=Vector2.ZERO
		print(4.1)
		if not dead:
			sprite.play("Idle")
			AttackTimer.start()
		

func player_out_of_range(area:Area2D):
	player_close=false
	#print("out of range")
	AttackTimer.stop()
	TrackTimer.wait_time=4
	TrackTimer.start()
	tracking=true

func move_to_target(delta:float):
	if player_ref.dead:
		tracking=false
		can_move=false
	var player_pos=player_ref.global_position
	var current_pos=global_position
	var direction=(player_pos-current_pos).normalized()
	if direction.x<0:
		flip_stuff(false)
	else:
		flip_stuff(true)
	if sprite.animation!="Move" and can_move:
		sprite.play("Move")
		sfx.play()
	velocity=direction*Speed

func _on_hit_box_area_entered(area: Area2D) -> void:
	if dead:
		return
	sprite.stop()
	take_damage()
	var hit_dir=(global_position-area.get_parent().global_position).normalized()
	if can_be_knocked and Health_Points>0:
		apply_knockback(hit_dir,50,0.4)
		can_be_knocked=false


func apply_knockback(dir:Vector2, force:float, duration:float):
	velocity=Vector2.ZERO
	can_move=false
	tracking=false
	AttackTimer.stop()
	TrackTimer.stop()
	#print("dir:", dir)
	knckback=dir*force
	timeknockback=duration
	sprite.play("hit")


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
			TrackTimer.start()
			sprite.play("Move")
			sfx.play()
		#print("knock done")

func apply_damage():
	if not player_ref.dead and player_close:
		player_ref.take_damage(2,self)

func flip_stuff(flip:bool):
	if flip and $AnimatedSprite2D.flip_h!=true:
		$AnimatedSprite2D.flip_h=true
		AttackZone.scale.x=-1
	if not flip and $AnimatedSprite2D.flip_h==true:
		$AnimatedSprite2D.flip_h=false
		AttackZone.scale.x=1

func take_damage():
	hitted_sfx.play()
	Health_Points-=1
	
	#print("Health: ",Health_Points)
	if Health_Points<=0:
		dead=true
		AttackZone.set_deferred("monitoring",false)
		AttackZone.set_deferred("monitorable",false)
		HitBox.set_deferred("monitoring",false)
		HitBox.set_deferred("monitorable",false)
		player_close=false
		can_move=false
		tracking=false
		velocity=Vector2.ZERO
		TrackTimer.stop()
		AttackTimer.stop()
		
		floor_detection.set_deferred("disable",true)
		collision_shape_2d.set_deferred("disable",true)
		collision_shape_2d2.set_deferred("disable",true)
		sprite.play("Die")
	enemy_hp_bar.value=Health_Points
	SignalBus.enemy_hit.emit(enemy_hp_bar)


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation=="Spawn":
		enemy_hp_bar.show()
		floor_detection.disabled=false
		collision_shape_2d.disabled=false
		collision_shape_2d2.disabled=false
		after_spawn_timer.start()
		await after_spawn_timer.timeout
		tracking=true
		TrackTimer.start()
		can_move=true
		sprite.play("Move")
	if sprite.animation=="Attack":
		sprite.position=Vector2(-2,-19)
		if not player_close:
			sprite.play("Move")
		else:
			print(6)
			sprite.play("Idle")
			sfx.stop()
	if sprite.animation=="Die":
		after_spawn_timer.start()
		await after_spawn_timer.timeout
		SignalBus.enemy_dead.emit()
		queue_free()
