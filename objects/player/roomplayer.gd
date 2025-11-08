extends Node2D
class_name RoomPlayer

var walk_sp: float = 25
var controllable: bool = true
var has_shown_interact_tutorial: bool = false

@onready var sprite = $sprite

func _ready() -> void:
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	var moving := false
	
	if position.x < 73: position.x = 73
	if position.x > 240: position.x = 240
	
	if not controllable:
		return
	
	if Input.is_action_pressed("ui_left"):
		sprite.flip_h = true
		sprite.play("walking")
		position.x -= walk_sp * delta
		moving = true
	
	elif Input.is_action_pressed("ui_right"):
		sprite.flip_h = false
		sprite.play("walking")
		position.x += walk_sp * delta
		moving = true
	
	if not moving:
		sprite.play("idle")
