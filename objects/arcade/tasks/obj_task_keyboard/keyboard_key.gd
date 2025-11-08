extends Node2D
class_name TaskKeyboardKey
var hsp: float
var vsp: float
var rotsp_deg: float
var grv: float
var hrv: float

func _ready(): 
	grv = 0.1
	hrv = 0.001
	rotsp_deg = randf_range(-10, 10)
	hsp = randf_range(-2, 2)
	vsp = randf_range(-4, -1)
	scale *= randf_range(0.5, 2.0)

func _physics_process(delta: float) -> void:
	position.x += hsp
	position.y += vsp
	vsp += grv
	hsp = hsp - sign(hsp)*hrv
	rotation_degrees += rotsp_deg
