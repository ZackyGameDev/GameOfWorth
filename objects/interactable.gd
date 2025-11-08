extends Node2D

class_name Interactable

'''
children:
	- area - Area2D
		- shape - CollisionShape2D
	- ping - Sprite2D
'''

var float_tween: Tween
var ping_pos: Vector2
var ping_delta: Vector2 = Vector2.ZERO
var active: bool = false
var action_in_progress: bool = false
var player: RoomPlayer

func _ready():
	ping_pos = $ping.position
	
	float_tween = create_tween().set_loops() 
	float_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	float_tween.tween_property(self, "ping_delta:y", -2.0, 1.0)
	float_tween.tween_property(self, "ping_delta:y", 2.0, 1.0)

func do_action():
	print("This is to be overriden in child class")
	action_in_progress = true

func _physics_process(_delta: float) -> void:
	$ping.position = ping_pos + ping_delta - Vector2(0, (5 * int(active)))
	
	if Input.is_action_pressed("ui_up") and active and not action_in_progress:
		player.controllable = false
		do_action()

func _on_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is RoomPlayer:
		active = true
		player = area.get_parent()
		if not player.has_shown_interact_tutorial:
			var scene = preload("res://objects/player/tutorial_interaction_stamp.tscn")
			var stamp = scene.instantiate()
			stamp.global_position = Vector2(320.0/2, 160)
			stamp.delay = 3.9
			get_parent().add_child.call_deferred(stamp)
			player.has_shown_interact_tutorial = true
	
func _on_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is RoomPlayer:
		active = false
