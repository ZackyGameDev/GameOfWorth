extends Node2D
class_name ArcadeGame


@onready var pressup: Node2D = $tutorials/pressup
@onready var holdup: Node2D = $tutorials/holdup
@onready var player_start_position = $player.position


func _ready() -> void:
	$fg.self_modulate.a = 1
	$fg.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property($fg, "self_modulate:a", 0, 1)

func show_nice_stamp() -> void:
	var nicestampscene = preload("res://objects/arcade/misc/nice!/nicestamp.tscn")
	var stamp: PromptStamp = nicestampscene.instantiate()
	stamp.global_position = get_viewport_rect().size/2
	add_child(stamp)

func process_tutorials() -> void:
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

func _physics_process(_delta: float) -> void:
	process_tutorials()
