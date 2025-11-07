extends Node2D
class_name ArcadeHUD

var power: float = 1.0
var time: float = 12.0
var points: int = 0
var next_task_at: int = 150
var last_tast_at: int = 0
var tasks_done: int = 0
var hi_score: int = 0

@onready var score_hud_start_pos: Vector2 = $progress.position
@onready var power_hud_start_pos: Vector2 = $power.position
@onready var time_hud_start_pos: Vector2 = $time.position

@onready var scoreboard: RichTextLabel = $progress/scorelabels/score

const TASKDONESTAMPPATH: String = "res://objects/arcade/misc/task_done.tscn"


func _ready() -> void:
	print("hud ready", self)
	hi_score = SaveSystem.load_game()[0]
	

func show_task_complete_stamp(task_number: int):
	var stamp_scene = preload(TASKDONESTAMPPATH)
	var stamp: Node2D = stamp_scene.instantiate()
	stamp.scale *= 0.7
	stamp.position = Vector2(320.0/2, 90-75)
	var task_label: RichTextLabel = stamp.get_node("task")
	task_label.text = "Task " + str(task_number)
	get_parent().add_child(stamp)

func start_next_task():
	tasks_done += 1
	show_task_complete_stamp(tasks_done)
	last_tast_at = next_task_at
	@warning_ignore("narrowing_conversion")
	next_task_at = last_tast_at * 1.5

func show_element(node: Node2D):
	var tween = get_tree().create_tween()
	tween.tween_property(node, "position", Vector2.ZERO, 0.25) \
		.set_ease(Tween.EASE_OUT)
	await tween.finished
	tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(node, "position", Vector2.ZERO, 3) # hold it there for a while
	await tween.finished 
	tween.kill()

func show_power() -> void: 
	show_element($power)

func show_score() -> void:
	show_element($progress)

func show_time() -> void:
	show_element($time)

func _physics_process(delta: float) -> void:
	# the position of the scoreboard is updated by the tween, and held in visible 
	# position for a few seconds. if the tween is not actively holding it, 
	# then this code will make the progress bar go back
	var speed = 8
	$progress.position = $progress.position.lerp(score_hud_start_pos, delta*speed)
	$power.position = $power.position.lerp(power_hud_start_pos, delta*speed)
	$time.position = $time.position.lerp(time_hud_start_pos, delta*speed)
	
	# update scoreboard text
	var this_task_points: int = points - last_tast_at
	var total_task_points: int = next_task_at - last_tast_at
	var task_percent: float = float(this_task_points)/total_task_points
	scoreboard.text = str(points) + '\n' + str(hi_score)
	$progress/tasknumber.text = "Task " \
		+ str(tasks_done + 1) \
		+ " (" + str(this_task_points) \
		+ "/" + str(total_task_points) \
		+ ")"
	$progress/bar/taskpercent.text = "%.2f" % (task_percent*100) + "%"
	$progress/bar/juice.scale.x = task_percent
	
	# save high score
	if points > hi_score:
		hi_score = points
		SaveSystem.save_hi_score(hi_score)
	
	# task completed
	if points >= next_task_at:
		start_next_task()

	if power < 0: power = 0
	$power/box/bar/juice.scale.x = power
