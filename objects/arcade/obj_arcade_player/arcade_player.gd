extends Node2D
class_name ArcadePlayer

signal got_hurt(resultant_hp: float)
signal got_distracted(remaining_time: float)


var hsp: float = 0.0
var vsp: float = 0.0
var acceleration: float = 100.0
var retardation: float = 25.0
var dir: float = 0.0
var turnsp: float = 150.0 
var max_speed: float = 150.0

var shake_strength = 0.0
var shake_decay = 10.0  # higher = ends faster
var shake_amount = 2.0  # max pixels to shake

var points: int = 0 # OTHER NODES MUST USE update_points THAN MODIFY THIS
var stamina: float = 1.00 # range is [0, 1] (float)
var time_left: float = 12.0 # 12 hours very arbitrary
var iframes_active: bool = false

var hud: ArcadeHUD

func _ready() -> void:
	var hudscene = preload("res://objects/arcade/obj_arcade_player/HUD/arcade_hud.tscn")
	var _hud = hudscene.instantiate()
	print("Parent in tree:", get_parent().is_inside_tree())
	get_parent().add_child.call_deferred(_hud)
	hud = _hud
	print("Added hud: ", hud)

func process_wrap_around():
	var room_size = Vector2(320, 180)
	var player_size = Vector2(25, 25)

	if position.x > room_size.x:
		position.x = -player_size.x
	elif position.x < -player_size.x:
		position.x = room_size.x

	if position.y > room_size.y:
		position.y = -player_size.y
	elif position.y < -player_size.y:
		position.y = room_size.y


func show_damage_tutorial():
	var stampscene = preload("res://objects/arcade/misc/dont_be_hurt_stamp.tscn")
	var stamp: PromptStamp = stampscene.instantiate()
	stamp.global_position = get_viewport_rect().size/2
	stamp.global_position.y += 69
	get_parent().add_child(stamp)

func get_hurt(damage: float) -> void:
	stamina -= damage
	shake_strength = 2.0
	got_hurt.emit(stamina)
	hud.power = stamina
	hud.show_power()

func update_points(points_to_add: int):
	points += points_to_add
	hud.points = points
	hud.show_score()

func process_shake(delta):
	if shake_strength > 0.0:
		get_tree().current_scene.position = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		) * shake_strength
		shake_strength = max(shake_strength - delta * shake_decay, 0.0)
	else:
		get_tree().current_scene.position = Vector2.ZERO

func shoot() -> PlayerBullet:
	var bullet_scene = preload("res://objects/arcade/obj_arcade_player/obj_player_bullet/player_bullet.tscn")
	var bullet: PlayerBullet = bullet_scene.instantiate()
	bullet.position = position
	bullet.position += Vector2.from_angle(rotation) * 10
	bullet.rotation = rotation
	get_parent().add_child(bullet)
	bullet.connect_player(self)
	shake_strength = 1.0
	$shootparticles.emitting = true
	return bullet

func flash():
	iframes_active = true
	$sprite.self_modulate = Color("#ff1933")
	var tween = get_tree().create_tween()
	tween.tween_property($sprite, "self_modulate", Color(1, 1, 1), 3)
	await tween.finished
	iframes_active = false

func _physics_process(delta: float) -> void:
	process_shake(delta)
	
	var input_dir: float = 0.0
	
	if Input.is_action_pressed("ui_left"):
		input_dir -= 1.0
	if Input.is_action_pressed("ui_right"):
		input_dir += 1.0
	
	dir += input_dir * turnsp * delta
	
	var thrust: float = 0.0
	if Input.is_action_pressed("ui_up"):
		thrust = 1.0
	#elif Input.is_action_pressed("ui_down"):
		#thrust = -0.4
	
	var target_hsp = cos(deg_to_rad(dir)) * thrust * max_speed * stamina
	var target_vsp = sin(deg_to_rad(dir)) * thrust * max_speed * stamina
	
	hsp = move_toward(hsp, target_hsp, acceleration * delta)
	vsp = move_toward(vsp, target_vsp, acceleration * delta)
	
	if thrust == 0.0:
		hsp = move_toward(hsp, 0.0, retardation * delta)
		vsp = move_toward(vsp, 0.0, retardation * delta)
	
	position.x += hsp * delta
	position.y += vsp * delta
	rotation_degrees = dir
	process_wrap_around()
	
	# shooting
	if Input.is_action_just_pressed("ui_up"):
		shoot()


func _on_hurtbox_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent is Task and area.name == "hitbox" and not iframes_active:
		get_hurt(0.1)
		update_points(parent.points)
		parent.die()
		flash()


func _on_got_hurt(resultant_hp: float) -> void:
	if resultant_hp == 0.9:
		show_damage_tutorial()
