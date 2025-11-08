extends Task
class_name TaskKeyboard

var fuse_time: float = 7.0
var keys_amount: int = 30
var shake_intensity: float = 2
var shake_delta: Vector2 = Vector2(0, 0)
var critical_threshhold = 0.5

var warning_scene: Resource
var warning: Node2D

func _ready():
	warning_scene = preload("res://objects/arcade/tasks/obj_task_keyboard/task_keyboard_warning.tscn")
	super()
	attack()
	hp = 15

func die():
	if is_instance_valid(warning):
		warning.queue_free()
	super()

func spawn_warning() -> Node2D:
	warning = warning_scene.instantiate()
	var sprite: Sprite2D = warning.get_node("sprite")
	sprite.scale = Vector2.ZERO
	sprite.self_modulate.a = 0
	add_child.call_deferred(warning)
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "self_modulate:a", 0.5, fuse_time*critical_threshhold) \
		.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "scale", 3*Vector2.ONE, fuse_time*critical_threshhold)
	return sprite

func command_player_to_screen_shake():
	var player: ArcadePlayer = get_tree().current_scene.find_child("player", true)
	if player == null:
		print("keyboard did not find players")
		return
	player.shake_strength = 5

func attack() -> void:
	
	var t: Timer = Timer.new()
	t.wait_time = fuse_time
	t.one_shot = true
	add_child(t)
	t.start()
	
	# blinking
	var tweak = get_tree().create_tween()
	tweak.set_loops()
	tweak.tween_property($sprite, "self_modulate", Color(10, 10, 10), 0.5)
	tweak.tween_property($sprite, "self_modulate", Color(1, 1, 1), 0.5)
	
	while t.time_left > 0:
		if t.time_left/t.wait_time < critical_threshhold and tweak.is_valid():
			tweak.kill()
			var tweak_harder = get_tree().create_tween()
			tweak_harder.set_loops()
			tweak_harder.tween_property($sprite, "self_modulate", Color(10, 10, 10), 0.2)
			tweak_harder.tween_property($sprite, "self_modulate", Color(1, 1, 1), 0.2)
			spawn_warning()
			
		shake_delta = Vector2(
			randf_range(-shake_intensity, shake_intensity), 
			randf_range(-shake_intensity, shake_intensity)
		) * (1 - t.time_left/t.wait_time)
		
		await get_tree().process_frame
	
	var scene = preload("res://objects/arcade/tasks/obj_task_keyboard/keyboard_key.tscn")
	for i in range(keys_amount):
		var key: Node2D = scene.instantiate()
		key.global_position = global_position
		get_parent().add_child(key)
	
	command_player_to_screen_shake()
	warning.queue_free()
	queue_free()

func _physics_process(_delta: float) -> void:
	super(_delta)
	position += shake_delta
