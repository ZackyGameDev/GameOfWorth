extends Task
class_name TaskPencil

var aim_distance: float = 90.0
var aim_time: float = 3.9
var recoil_distance: float = 20.0
var recoil_time: float = 0.45
var warning_scale: Vector2

func _ready():
	super()
	$warning.self_modulate.a = 0
	warning_scale = $warning.scale
	$warning.scale.x = 0
	hp = 1
	attack()

func attack() -> void:
	var player = get_tree().current_scene.find_child("player", true, false)
	if player == null:
		print("did not find players")
		return

	var aim_dir: Vector2 = Vector2.from_angle(rotation)
	var aim_target = player.position - (aim_dir * aim_distance)

	fly_to(aim_target, 0.5)

	var timer = Timer.new()
	timer.wait_time = aim_time
	timer.one_shot = true
	add_child(timer)
	timer.start()
	while timer.time_left > 0:
		pivot_pos = player.position - (aim_dir * aim_distance)
		await get_tree().process_frame
	timer.queue_free()

	var recoil_target = pivot_pos - aim_dir * recoil_distance
	var recoil_tween = get_tree().create_tween()
	recoil_tween.tween_property(self, "pivot_pos", recoil_target, recoil_time).set_ease(Tween.EASE_OUT)
	recoil_tween.tween_property($warning, "self_modulate:a", 0.5, recoil_time).set_ease(Tween.EASE_OUT)
	recoil_tween.tween_property($warning, "scale:x", warning_scale.x, recoil_time)
	await recoil_tween.finished

	var shoot_tween = get_tree().create_tween()
	shoot_tween.tween_property(self, "pivot_pos", (aim_dir * 700) + pivot_pos, 1).set_ease(Tween.EASE_IN)
	await shoot_tween.finished
	
	# this enemy only attacks once.
	queue_free()
