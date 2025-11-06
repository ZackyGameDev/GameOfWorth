extends Node2D
class_name ApprovalStampNice

func _ready() -> void:
	var sprite = $sprite  # your Sprite2D or TextureRect or Label
	var original_scale = sprite.scale
	var original_modulate = sprite.modulate
	
	# start invisible and large
	sprite.modulate.a = 0.0
	sprite.scale = original_scale * 2.0
	
	var tween = create_tween()
	
	tween.tween_property(sprite, "scale", original_scale, 0.7) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "modulate:a", 1.0, 0.4) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(sprite, "modulate:a", 0.0, 0.8) \
		.set_delay(1) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN)
