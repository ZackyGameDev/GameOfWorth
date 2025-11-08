extends Sprite2D

@export var scroll_speed: float = 0.02
var _offset := Vector2.ZERO

func _process(delta: float) -> void:
	_offset.x -= scroll_speed * delta
	material.set_shader_parameter("offset", _offset)
