extends Task
class_name TaskPen

var recoil_distance: float = 20.0
var recoil_time: float = 0.45
var shoot_distance: float = 190.0
var warning_position: Vector2
var reload_time: float = 1

const WARNING_PATH: String = "res://objects/arcade/tasks/obj_task_pen/task_pen_warning.tscn"
var warning_scene: Resource
var warning: Node2D

func _ready():
	super()
	warning_scene = preload(WARNING_PATH)
	while true: 
		await attack()

func die():
	if is_instance_valid(warning):
		warning.queue_free()
	super()

func spawn_warning() -> Node2D:
	warning = warning_scene.instantiate()
	var sprite: Sprite2D = warning.get_node("sprite")
	sprite.scale = Vector2.ZERO
	warning.position = pivot_pos
	warning.rotation = rotation
	sprite.self_modulate.a = 0
	get_parent().add_child.call_deferred(warning)
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "self_modulate:a", 0.5, recoil_time/3) \
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2(shoot_distance+13, 9), recoil_time/3)
	return sprite

func attack() -> void:
	# aim and recoil
	var aim_dir: Vector2 = Vector2.from_angle(rotation)
	var recoil_target = pivot_pos - aim_dir * recoil_distance
	var recoil_tween = get_tree().create_tween()
	recoil_tween.tween_property(self, "pivot_pos", recoil_target, recoil_time) \
		.set_ease(Tween.EASE_OUT)
	var warningsprite: Node2D = spawn_warning()
	await recoil_tween.finished
	
	# FIRE!
	var shoot_tween = get_tree().create_tween()
	shoot_tween.tween_property(self, "pivot_pos", (aim_dir * shoot_distance) + pivot_pos, 0.2) \
		.set_ease(Tween.EASE_IN)
	await shoot_tween.finished
	
	# reload...
	var cleanup_tween = get_tree().create_tween()
	cleanup_tween.tween_property(warningsprite, "self_modulate:a", 0, reload_time)
	cleanup_tween.tween_property(self, "rotation_degrees", rotation_degrees + 180, reload_time/2) \
		.set_delay(reload_time/2)
	await cleanup_tween.finished
	warningsprite.get_parent().queue_free()
