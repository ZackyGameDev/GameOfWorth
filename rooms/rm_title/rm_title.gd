extends Node2D

func _ready() -> void:
	var chakra_tween = create_tween().set_loops()  # loop forever
	chakra_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	chakra_tween.tween_property($chakra, "self_modulate:a", 0.0, 1.0)
	chakra_tween.tween_property($chakra, "self_modulate:a", 0.2, 1.0)
	$endings.text = "Endings found: (" + str(SaveSystem.load_game()[1]) + "/2)"
	if SaveSystem.load_game()[1] == 2:
		$endings.text = $endings.text + "\n Thank you, for playing my game."


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_play_button_activated(_data: Variant) -> void:
	get_tree().change_scene_to_file("res://rooms/rm_cutscene1/rm_custcene1.tscn")
