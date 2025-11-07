extends Node2D
class_name Task

var hp: int = 3
var points: int = 50
var float_delta: Vector2 = Vector2.ZERO
@onready var pivot_pos: Vector2 = position
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

var fly_tween: Tween
var float_tween: Tween

func attack():
	print("attack function used on base Task class!")
	print("Task.attack() is only defined for other nodes that extend Task")

func die():
	var scene = preload("res://objects/arcade/tasks/task_grave.tscn")
	var grave = scene.instantiate()
	grave.global_position = global_position
	grave.displayed_points = points
	get_parent().add_child(grave)
	died.emit(points)
	queue_free()

func fly_to(destination: Vector2, time_taken: float):
	if fly_tween.is_running():
		print("already flying somewhere")
		return
	if fly_tween.is_valid(): 
		fly_tween.kill() # free this variable for my new fly tween
	fly_tween = get_tree().create_tween()
	fly_tween.tween_property(self, "pivot_pos", destination, time_taken) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN_OUT)

func _ready():
	pivot_pos = position
	
	float_tween = create_tween().set_loops()  # loop forever
	float_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(self, "float_delta:y", -2.0, 1.0)
	float_tween.tween_property(self, "float_delta:y", 2.0, 1.0)
	
	# initializing this varaible.
	fly_tween = get_tree().create_tween()
	fly_tween.kill()
	
	#fly_to(Vector2(220, 85), 1) # testing out this function 


func _physics_process(_delta: float) -> void:
	position = pivot_pos + float_delta


func _on_hurtbox_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if (area.name == "hitbox" and parent is PlayerBullet):
		hp -= 1
		parent.queue_free()
		if hp == 0:
			parent.give_points_to_player(points)
			die()
	flash()

func flash():
	$sprite.self_modulate = Color(20, 20, 20)
	var tween = get_tree().create_tween()
	tween.tween_property($sprite, "self_modulate", Color(1, 1, 1), 0.05)
