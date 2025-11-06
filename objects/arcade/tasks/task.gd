extends Node2D
class_name Task

var hp: float = 10.0
var points: float = 50.0

'''
Tasks are always Node2D at root and have the following children at LEAST
sprite -> Sprite2D
hurtbox/shape -> Area2D/CollisionShape2D
hitbox/shape -> Area2D/CollisionShape2D

signals:
	died(points: float)
	emitted when the task is 'killed' by the player. argument is the points
	that should be awarded to the player.
'''

signal died(points: float);

func die():
	var scene = preload("res://objects/arcade/tasks/task_grave.tscn")
	var grave = scene.instantiate()
	grave.global_position = global_position
	grave.displayed_points = points
	get_parent().add_child(grave)
	died.emit(points)
	queue_free()

func _ready():
	var tween = create_tween().set_loops()  # loop forever
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var start_y = position.y
	tween.tween_property(self, "position:y", start_y - 2, 1.0)
	tween.tween_property(self, "position:y", start_y + 2, 1.0)


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if (area.name == "hitbox" and area.get_parent() is PlayerBullet):
		hp -= 1
		area.get_parent().queue_free()
		if hp == 0:
			die()
	flash()

func flash():
	$sprite.self_modulate = Color(20, 20, 20)
	var tween = get_tree().create_tween()
	tween.tween_property($sprite, "self_modulate", Color(1, 1, 1), 0.05)
