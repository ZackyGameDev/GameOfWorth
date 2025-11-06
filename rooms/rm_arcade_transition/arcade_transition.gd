extends Node2D

func _ready() -> void:
	$Boot.play("booting")

func _on_boot_animation_finished() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Purple, "scale", Vector2(2, 2), 2)
	await tween.finished
	
	tween = get_tree().create_tween()
	tween.tween_property($Lightpurple, "self_modulate:a", 1, 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://rooms/rm_arcade_game/arcade_game.tscn")
	
