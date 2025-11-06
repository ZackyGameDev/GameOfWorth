extends Node2D

func _ready() -> void:
	$Boot.play("booting")



func _on_boot_animation_finished() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Purple, "scale", Vector2(1, 1), 2)
