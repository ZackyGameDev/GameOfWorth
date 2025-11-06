extends Node2D
class_name ArcadeGame


@onready var pressup: Node2D = $tutorials/pressup
@onready var holdup: Node2D = $tutorials/holdup
@onready var player_start_position = $player.position

func show_nice_stamp() -> void:
	var nicestampscene = preload("res://objects/arcade/misc/nice!/nicestamp.tscn")
	var stamp: ApprovalStampNice = nicestampscene.instantiate()
	stamp.global_position = get_viewport_rect().size/2
	add_child(stamp)

func _physics_process(delta: float) -> void:
	if (Input.is_action_just_pressed("ui_up")):
		if (pressup.visible):
			pressup.visible = false
			holdup.visible = true
			show_nice_stamp()
			return
	
	if Input.is_action_pressed("ui_up"):
		if ($player.position - player_start_position).length() > 50:
			if holdup.visible:
				holdup.visible = false
				show_nice_stamp()
