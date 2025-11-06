extends Node2D
class_name PlayerBullet

var speed = 300;

func _physics_process(delta: float) -> void:
	position.x += cos(rotation) * speed * delta
	position.y += sin(rotation) * speed * delta
	
	if global_position.x > 400 \
	  or global_position.x < -100\
	  or global_position.y > 300 \
	  or global_position.y < -100:
		queue_free()
