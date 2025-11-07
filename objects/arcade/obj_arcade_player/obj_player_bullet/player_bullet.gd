extends Node2D
class_name PlayerBullet

var speed = 300;
var player: ArcadePlayer # set by the player while spawning this bullet.

func connect_player(_player: ArcadePlayer) -> void: # who shot
	player = _player

func give_points_to_player(points: int) -> void: 
	player.update_points(points)

func _physics_process(delta: float) -> void:
	position.x += cos(rotation) * speed * delta
	position.y += sin(rotation) * speed * delta
	
	if global_position.x > 400 \
	  or global_position.x < -100\
	  or global_position.y > 300 \
	  or global_position.y < -100:
		queue_free()
