extends Node2D
class_name EnemySpawner

var paper_scene = preload("res://objects/arcade/tasks/obj_task_paper/TaskPaper.tscn")
var pen_scene = preload("res://objects/arcade/tasks/obj_task_pen/task_pen.tscn")
var pencil_scene = preload("res://objects/arcade/tasks/obj_task_pencil/task_pencil.tscn")
var keyboard_scene = preload("res://objects/arcade/tasks/obj_task_keyboard/task_keyboard.tscn")

@export var player_path: NodePath
var player: Node2D

var spawn_timer := 0.0
var difficulty_timer := 0.0
var current_max_enemies := 2
var enemies_on_screen := []
var keyboard_exists := false
var keyboard_cooldown := 0.0
var rng := RandomNumberGenerator.new()

const SCREEN_SIZE = Vector2(320, 180)
const SAFE_MARGIN = 16
const OFFSCREEN_OFFSET = 32
const PLAYER_SAFETY_RADIUS = 64

func cleanup():
	for child in get_children():
		child.queue_free()


func _ready() -> void:
	rng.randomize()
	if has_node(player_path):
		player = get_node(player_path)

func _process(delta: float) -> void:
	spawn_timer += delta
	difficulty_timer += delta
	if keyboard_cooldown > 0:
		keyboard_cooldown -= delta

	if difficulty_timer > 20:
		difficulty_timer = 0
		current_max_enemies += 1

	enemies_on_screen = enemies_on_screen.filter(func(e): return e != null and e.is_inside_tree())

	if enemies_on_screen.size() < current_max_enemies and spawn_timer > 1.5:
		spawn_timer = 0
		_spawn_enemy()

func _spawn_enemy() -> void:
	var roll = rng.randf()
	if roll < 0.5:
		_spawn_paper()
	elif roll < 0.75:
		_spawn_pencil()
	elif roll < 0.95:
		_spawn_pen()
	else:
		if not keyboard_exists and keyboard_cooldown <= 0:
			_spawn_keyboard()
			keyboard_exists = true
			keyboard_cooldown = 15.0
		else:
			_spawn_paper()

# --------------------------------------------------------
func _spawn_paper() -> void:
	var paper = paper_scene.instantiate()
	add_child(paper)

	var target_pos = _get_safe_target_position()
	var start_pos = _get_safe_offscreen_spawn_point(target_pos)

	paper.pivot_pos = start_pos
	paper.fly_to(target_pos, 3)
	enemies_on_screen.append(paper)

func _spawn_pencil() -> void:
	var pencil = pencil_scene.instantiate()

	var target_pos = _get_safe_target_position()
	var start_pos = _get_safe_offscreen_spawn_point(target_pos)

	# Make sure pencils don't face directly at player during entry
	var direction = (target_pos - start_pos).normalized()
	var to_player = player.position - start_pos if player else Vector2.ZERO
	if player and abs(direction.angle_to(to_player.normalized())) < deg_to_rad(20):
		# Slightly alter rotation so it doesn't go through player
		direction = direction.rotated(deg_to_rad(rng.randf_range(25, 45)) * sign(rng.randf() - 0.5))

	pencil.rotation = direction.angle()
	#pencil.fly_to(target_pos, 0.4)
	pencil.position = -100*Vector2(cos(pencil.rotation), sin(pencil.rotation))
	add_child(pencil)
	pencil.attack()
	enemies_on_screen.append(pencil)

func _spawn_pen() -> void:
	var pen = pen_scene.instantiate()
	add_child(pen)

	var target_pos = _get_safe_target_position()
	var start_pos = _get_safe_offscreen_spawn_point(target_pos)

	# Pen spawns offscreen and flies to its target spot
	pen.pivot_pos = start_pos
	pen.rotation = (SCREEN_SIZE / 2 - target_pos).angle() + rng.randf_range(-0.1, 0.1)
	pen.fly_to(target_pos, 0.6)
	enemies_on_screen.append(pen)

	# Fire 2–3 pencils in parallel directions (no overlap)
	var base_angle = pen.rotation
	var count = rng.randi_range(2, 3)
	for i in range(count):
		var pencil = pencil_scene.instantiate()
		add_child(pencil)

		var offset_angle = base_angle + deg_to_rad(-10 + i * (20.0 / (count - 1)))
		var dir = Vector2.RIGHT.rotated(offset_angle)
		var pencil_start = target_pos + dir * 8  # renamed to avoid shadowing

		pencil.pivot_pos = pencil_start
		pencil.rotation = offset_angle
		pencil.attack()
		enemies_on_screen.append(pencil)


func _spawn_keyboard() -> void:
	var keyboard = keyboard_scene.instantiate()
	add_child(keyboard)

	var start_pos = Vector2(SCREEN_SIZE.x / 2, -20)
	var target_pos = SCREEN_SIZE / 2
	keyboard.pivot_pos = start_pos
	keyboard.fly_to(target_pos, 5)
	keyboard.attack()
	enemies_on_screen.append(keyboard)
	keyboard.connect("tree_exited", Callable(self, "_on_keyboard_freed"))

func _on_keyboard_freed() -> void:
	keyboard_exists = false

# --------------------------------------------------------
# Utility: Safe spawn logic
# --------------------------------------------------------
func _get_closest_side(screen_res: Vector2, point: Vector2) -> String:
	var rect: Rect2 = Rect2(Vector2.ZERO, screen_res)
	var left_dist = abs(point.x - rect.position.x)
	var right_dist = abs(rect.position.x + rect.size.x - point.x)
	var top_dist = abs(point.y - rect.position.y)
	var bottom_dist = abs(rect.position.y + rect.size.y - point.y)
	
	var distances = {
		"left": left_dist,
		"right": right_dist,
		"top": top_dist,
		"bottom": bottom_dist
	}
	
	var closest_side = "left"
	var min_dist = left_dist
	
	for side in distances.keys():
		if distances[side] < min_dist:
			min_dist = distances[side]
			closest_side = side
	
	return closest_side

func _get_safe_target_position() -> Vector2:
	var pos: Vector2
	while true:
		pos = Vector2(
			rng.randf_range(SAFE_MARGIN * 2, SCREEN_SIZE.x - SAFE_MARGIN * 2),
			rng.randf_range(SAFE_MARGIN, SCREEN_SIZE.y - SAFE_MARGIN)
		)
		if not player or pos.distance_to(player.position) > PLAYER_SAFETY_RADIUS:
			break
	return pos

func _get_safe_offscreen_spawn_point(target: Vector2) -> Vector2:
	var side: String = _get_closest_side(SCREEN_SIZE, target)
	var pos: Vector2
	match side:
		"top": pos = Vector2(target.x, -OFFSCREEN_OFFSET)                    # Top
		"right": pos = Vector2(SCREEN_SIZE.x + OFFSCREEN_OFFSET, target.y)     # Right
		"bottom": pos = Vector2(target.x, SCREEN_SIZE.y + OFFSCREEN_OFFSET)     # Bottom
		"left": pos = Vector2(-OFFSCREEN_OFFSET, target.y)                    # Left

	## Ensure spawn path doesn’t go through player
	#if player:
		#var path_vec = target - pos
		#var player_vec = player.position - pos
		#if abs(path_vec.angle_to(player_vec)) < deg_to_rad(30):
			## offset perpendicular to avoid path overlap
			#var perp = Vector2(-path_vec.y, path_vec.x).normalized()
			#pos += perp * 32 * sign(rng.randf() - 0.5)
	return pos
