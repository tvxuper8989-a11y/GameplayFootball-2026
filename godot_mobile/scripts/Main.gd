extends Node3D

const FIELD_HALF_X: float = 52.5
const FIELD_HALF_Z: float = 34.0
const TEAM_NAMES: Array[String] = ["ATLÉTICO DEL PLATA", "UNIÓN METROPOLITANA", "DEPORTIVO NORTE", "CLUB DEL LITORAL"]
const ABBREVIATIONS: Array[String] = ["ADP", "UM", "DN", "CDL"]
const ROSTER: Array[String] = ["GÓMEZ", "SILVA", "PÉREZ", "SOTO", "ARCE", "LEIVA", "MOLINA", "ACOSTA", "DUARTE", "RUIZ", "SUÁREZ"]

var materials: Dictionary = {}
var players: Array[Dictionary] = []
var ball_mesh: MeshInstance3D
var ball_position: Vector3 = Vector3.ZERO
var ball_velocity: Vector3 = Vector3.ZERO
var ball_owner: int = -1
var catch_delay: float = 0.0
var ai_timer: float = 0.0
var game_clock: float = 0.0
var goal_freeze: float = 0.0
var scoreboard: Array[int] = [0, 0]
var selected_player: int = 9
var team_home: int = 0
var team_away: int = 1
var formation_name: String = "4-3-3"
var camera_mode: String = "TV"
var fps_target: int = 60
var running: bool = false
var pressed_sprint: bool = false
var joystick_dir: Vector2 = Vector2.ZERO
var screen_name: String = "inicio"
var game_over: bool = false
var model_animation_time: float = 0.0
var camera_3d: Camera3D
var gui: Control
var layer: CanvasLayer
var clock_label: Label
var score_label: Label
var notice_label: Label
var notice_timer: float = 0.0

func _ready() -> void:
	Engine.max_fps = fps_target
	_create_stadium()
	_create_teams()
	_create_ball()
	_create_camera()
	layer = CanvasLayer.new()
	add_child(layer)
	gui = Control.new()
	layer.add_child(gui)
	gui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_show_home()
	set_physics_process(true)

func _mat(color: Color, metallic: float = 0.0) -> StandardMaterial3D:
	var key: String = color.to_html() + str(metallic)
	if materials.has(key):
		return materials[key]
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.8
	m.metallic = metallic
	materials[key] = m
	return m

func _mesh_box(parent: Node3D, dimensions: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var item: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = dimensions
	item.mesh = mesh
	item.material_override = _mat(color)
	item.position = at
	parent.add_child(item)
	return item

func _mesh_sphere(parent: Node3D, radius: float, at: Vector3, color: Color) -> MeshInstance3D:
	var item: MeshInstance3D = MeshInstance3D.new()
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 10
	mesh.rings = 6
	item.mesh = mesh
	item.material_override = _mat(color)
	item.position = at
	parent.add_child(item)
	return item

func _create_stadium() -> void:
	var env_node: WorldEnvironment = WorldEnvironment.new()
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#071827")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#e0f5ff")
	env.ambient_light_energy = 0.8
	env_node.environment = env
	add_child(env_node)
	var sunlight: DirectionalLight3D = DirectionalLight3D.new()
	sunlight.rotation_degrees = Vector3(-54.0, 26.0, 0.0)
	sunlight.light_energy = 1.1
	sunlight.shadow_enabled = false
	add_child(sunlight)
	_mesh_box(self, Vector3(109.0, 0.25, 72.0), Vector3(0, -0.19, 0), Color("#1c723e"))
	for i in range(14):
		if i % 2 == 0:
			_mesh_box(self, Vector3(7.5, 0.005, 68.0), Vector3(-48.75 + i * 7.5, -0.056, 0), Color("#237e47"))
	var white: Color = Color("#e2f8e8")
	_mesh_box(self, Vector3(105, 0.018, 0.14), Vector3(0, -0.036, -34.0), white)
	_mesh_box(self, Vector3(105, 0.018, 0.14), Vector3(0, -0.036, 34.0), white)
	for x in [-52.5, 0.0, 52.5]:
		_mesh_box(self, Vector3(0.14, 0.018, 68), Vector3(x, -0.032, 0), white)
	for side in [-1.0, 1.0]:
		_mesh_box(self, Vector3(16.5, 0.015, 0.13), Vector3(side * (52.5 - 8.25), -0.028, -20.16), white)
		_mesh_box(self, Vector3(16.5, 0.015, 0.13), Vector3(side * (52.5 - 8.25), -0.028, 20.16), white)
		_mesh_box(self, Vector3(0.12, 0.015, 40.32), Vector3(side * 36.0, -0.029, 0), white)
		_mesh_box(self, Vector3(5.5, 0.015, 0.12), Vector3(side * (52.5 - 2.75), -0.029, -9.16), white)
		_mesh_box(self, Vector3(5.5, 0.015, 0.12), Vector3(side * (52.5 - 2.75), -0.029, 9.16), white)
		_mesh_box(self, Vector3(0.12, 0.015, 18.32), Vector3(side * 47.0, -0.029, 0), white)
		_mesh_box(self, Vector3(0.17, 2.9, 0.17), Vector3(side * 53.0, 1.45, -7.32), white)
		_mesh_box(self, Vector3(0.17, 2.9, 0.17), Vector3(side * 53.0, 1.45, 7.32), white)
		_mesh_box(self, Vector3(0.17, 0.17, 14.8), Vector3(side * 53.0, 2.9, 0), white)
		_mesh_box(self, Vector3(2.0, 0.08, 14.8), Vector3(side * 54.0, 0.04, 0), Color("#d1ecf6"))
	for i in range(40):
		var a: float = TAU * float(i) / 40.0
		_mesh_box(self, Vector3(0.75, 0.014, 0.11), Vector3(cos(a) * 9.15, -0.025, sin(a) * 9.15), white).rotation.y = -a
	# Stadium is low-poly and uses no crowd textures or real-world logos.
	for side in [-1.0, 1.0]:
		_mesh_box(self, Vector3(115, 3.0, 8.0), Vector3(0, 1.0, side * 47.0), Color("#122b3c"))
		_mesh_box(self, Vector3(115, 0.4, 11.0), Vector3(0, 3.2, side * 47.0), Color("#224b5c"))
		_mesh_box(self, Vector3(115, 0.25, 12.0), Vector3(0, 6.4, side * 51.0), Color("#16374b"))
		for j in range(14):
			var xs: float = -52.0 + float(j) * 8.0
			_mesh_box(self, Vector3(4.0, 0.2, 1.0), Vector3(xs, 3.55, side * 46.5), Color("#2f8f9a"))
	for side in [-1.0, 1.0]:
		_mesh_box(self, Vector3(8.0, 4.8, 86.0), Vector3(side * 62.0, 1.5, 0), Color("#10283a"))

func _positions(formation: String) -> Array[Vector2]:
	if formation == "4-4-2":
		return [Vector2(-49, 0), Vector2(-34, -24), Vector2(-34, -8), Vector2(-34, 8), Vector2(-34, 24),
			Vector2(-17, -23), Vector2(-17, -8), Vector2(-17, 8), Vector2(-17, 23), Vector2(-5, -10), Vector2(-5, 10)]
	if formation == "3-5-2":
		return [Vector2(-49, 0), Vector2(-33, -21), Vector2(-33, 0), Vector2(-33, 21), Vector2(-17, -27),
			Vector2(-17, -13), Vector2(-17, 0), Vector2(-17, 13), Vector2(-17, 27), Vector2(-5, -10), Vector2(-5, 10)]
	return [Vector2(-49, 0), Vector2(-34, -25), Vector2(-34, -8), Vector2(-34, 8), Vector2(-34, 25),
		Vector2(-18, -20), Vector2(-18, 0), Vector2(-18, 20), Vector2(-5, -20), Vector2(-5, 0), Vector2(-5, 20)]

func _create_teams() -> void:
	var spots: Array[Vector2] = _positions(formation_name)
	for side in range(2):
		for number in range(11):
			var node: Node3D = Node3D.new()
			node.name = "Equipo_%d_Jugador_%d" % [side + 1, number + 1]
			add_child(node)
			var uniform: Color = Color("#eaf7ff") if side == 0 else Color("#182335")
			var trim: Color = Color("#16bde0") if side == 0 else Color("#e3ba59")
			var hair: Color = Color("#342a25")
			var torso: MeshInstance3D = _mesh_box(node, Vector3(0.78, 0.94, 0.41), Vector3(0, 1.42, 0), uniform)
			_mesh_box(node, Vector3(0.79, 0.12, 0.44), Vector3(0, 1.60, -0.225), trim)
			_mesh_box(node, Vector3(0.7, 0.37, 0.44), Vector3(0, 0.83, 0), trim)
			_mesh_sphere(node, 0.31, Vector3(0, 2.16, 0), Color("#bd875f"))
			_mesh_box(node, Vector3(0.65, 0.15, 0.56), Vector3(0, 2.46, 0), hair)
			var leg_l: MeshInstance3D = _mesh_box(node, Vector3(0.21, 0.74, 0.23), Vector3(-0.19, 0.37, 0), uniform)
			var leg_r: MeshInstance3D = _mesh_box(node, Vector3(0.21, 0.74, 0.23), Vector3(0.19, 0.37, 0), uniform)
			_mesh_box(node, Vector3(0.21, 0.6, 0.22), Vector3(-0.52, 1.34, 0), Color("#bd875f"))
			_mesh_box(node, Vector3(0.21, 0.6, 0.22), Vector3(0.52, 1.34, 0), Color("#bd875f"))
			if number == 0:
				torso.material_override = _mat(Color("#f9cb48") if side == 0 else Color("#f0645d"))
			var ring: MeshInstance3D = _mesh_box(node, Vector3(1.17, 0.06, 1.17), Vector3(0, 0.02, 0), Color("#16f9d0"))
			ring.visible = side == 0 and number == 9
			var spot: Vector2 = spots[number]
			var start: Vector3 = Vector3(spot.x if side == 0 else -spot.x, 0, spot.y if side == 0 else -spot.y)
			node.position = start
			players.append({"node":node,"start":start,"side":side,"number":number,"leg_l":leg_l,"leg_r":leg_r,"ring":ring})

func _create_ball() -> void:
	ball_mesh = _mesh_sphere(self, 0.35, Vector3(0, 0.37, 0), Color("#f9faf7"))
	ball_position = Vector3(-3, 0.36, 0)

func _create_camera() -> void:
	camera_3d = Camera3D.new()
	camera_3d.fov = 57.0
	camera_3d.far = 230.0
	camera_3d.current = true
	add_child(camera_3d)
	camera_3d.position = Vector3(0, 44, 61)
	camera_3d.look_at(Vector3(0, 0, 0), Vector3.UP)

func _physics_process(delta: float) -> void:
	model_animation_time += delta
	if screen_name == "partido" and running and not game_over:
		_step_game(delta)
		_move_camera(delta)
		if notice_timer > 0.0:
			notice_timer -= delta
			if notice_timer <= 0.0 and is_instance_valid(notice_label):
				notice_label.text = ""
	elif screen_name != "partido":
		camera_3d.position = camera_3d.position.lerp(Vector3(4, 46, 65), minf(1.0, delta * 1.8))
		camera_3d.look_at(Vector3.ZERO, Vector3.UP)

func _move_camera(delta: float) -> void:
	var target: Vector3 = Vector3.ZERO
	if camera_mode == "TÁCTICA":
		target = Vector3(ball_position.x * 0.16, 62, 75)
	elif camera_mode == "DINÁMICA":
		target = Vector3(ball_position.x * 0.9, 31, ball_position.z * 0.5 + 46)
	else:
		target = Vector3(ball_position.x * 0.48, 40, 58)
	camera_3d.position = camera_3d.position.lerp(target, minf(1.0, delta * 2.5))
	camera_3d.look_at(Vector3(ball_position.x * 0.60, 0, ball_position.z * 0.45), Vector3.UP)

func _input_dir() -> Vector2:
	var keys: Vector2 = Vector2.ZERO
	if Input.is_key_pressed(KEY_LEFT):
		keys.x -= 1.0
	if Input.is_key_pressed(KEY_RIGHT):
		keys.x += 1.0
	if Input.is_key_pressed(KEY_UP):
		keys.y -= 1.0
	if Input.is_key_pressed(KEY_DOWN):
		keys.y += 1.0
	return (keys + joystick_dir).limit_length(1.0)

func _step_game(delta: float) -> void:
	if goal_freeze > 0:
		goal_freeze -= delta
		if goal_freeze <= 0:
			_reset_kickoff()
		return
	game_clock += delta * 25.0
	if game_clock >= 5400:
		game_over = true
		running = false
		_show_results()
		return
	ai_timer += delta
	catch_delay = maxf(0.0, catch_delay - delta)
	var input_vector: Vector2 = _input_dir()
	var fastest: float = 12.4 if pressed_sprint or Input.is_key_pressed(KEY_E) else 8.8
	var mine: Node3D = players[selected_player]["node"]
	mine.position += Vector3(input_vector.x, 0, input_vector.y) * fastest * delta
	mine.position.x = clampf(mine.position.x, -51.0, 51.0)
	mine.position.z = clampf(mine.position.z, -32.0, 32.0)
	var defender: int = _nearest_to_ball(0, selected_player)
	var attacker: int = _nearest_to_ball(1, -1)
	for i in range(players.size()):
		if i == selected_player:
			continue
		var p: Dictionary = players[i]
		var body: Node3D = p["node"]
		var target: Vector3 = p["start"]
		if i == defender and (ball_owner < 0 or ball_owner >= 11):
			target = ball_position
		elif i == attacker and (ball_owner < 11 or ball_owner == -1):
			target = ball_position
		elif ball_owner == i and p["side"] == 1:
			target = Vector3(-48.0, 0, ball_position.z * 0.55)
		else:
			target.x += clampf(ball_position.x * 0.15, -11.0, 11.0)
			target.z += clampf(ball_position.z * 0.16, -7.0, 7.0)
		if p["number"] == 0:
			target.x = -49 if p["side"] == 0 else 49
			target.z = clampf(ball_position.z * 0.35, -7.0, 7.0)
		var shift: Vector3 = target - body.position
		shift.y = 0
		var travel: float = minf(shift.length(), (9.0 if i == attacker else 6.8) * delta)
		if shift.length() > 0.12:
			body.position += shift.normalized() * travel
			body.rotation.y = lerp_angle(body.rotation.y, atan2(-shift.x, -shift.z), minf(1.0, delta * 8.0))
		var stride: float = sin(model_animation_time * 10.0 + float(i)) * 0.26 if travel > 0.02 else 0.0
		p["leg_l"].rotation.x = stride
		p["leg_r"].rotation.x = -stride
	if input_vector.length() > 0.12:
		mine.rotation.y = lerp_angle(mine.rotation.y, atan2(-input_vector.x, -input_vector.y), minf(1.0, delta * 9.0))
		players[selected_player]["leg_l"].rotation.x = sin(model_animation_time * 12) * 0.28
		players[selected_player]["leg_r"].rotation.x = -sin(model_animation_time * 12) * 0.28
	if ball_owner >= 0:
		var holder: Node3D = players[ball_owner]["node"]
		ball_position = holder.position + Vector3(1.0 if ball_owner < 11 else -1.0, 0.35, 0.3)
		if ball_owner >= 11:
			if ai_timer > 2.0 and holder.position.x < -22.0:
				_ai_shoot()
			elif ai_timer > 3.2:
				_ai_pass()
	else:
		ball_position += ball_velocity * delta
		ball_velocity *= pow(0.982, delta * 60.0)
		if absf(ball_position.z) > 33.8:
			ball_position.z = signf(ball_position.z) * 33.8
			ball_velocity.z *= -0.45
		if absf(ball_position.x) > 52.7:
			if absf(ball_position.z) < 7.3:
				_goal(0 if ball_position.x > 0.0 else 1)
				return
			ball_position.x = signf(ball_position.x) * 52.7
			ball_velocity.x *= -0.48
		if catch_delay <= 0.0:
			for i in range(players.size()):
				var bod: Node3D = players[i]["node"]
				if bod.position.distance_to(Vector3(ball_position.x, 0, ball_position.z)) < 1.35:
					ball_owner = i
					ai_timer = 0
					break
	if ball_owner >= 0:
		var owner: Node3D = players[ball_owner]["node"]
		var opponent: int = _nearest_to_ball(1 if ball_owner < 11 else 0, -1)
		if opponent >= 0:
			var distance: float = owner.position.distance_to(players[opponent]["node"].position)
			if distance < 1.15 and randf() < delta * 0.85:
				ball_owner = -1
				catch_delay = 0.25
				ball_velocity = Vector3(randf_range(-5, 5), 0, randf_range(-8, 8))
	ball_mesh.position = ball_position
	if is_instance_valid(clock_label):
		var sec: int = mini(5400, int(game_clock))
		clock_label.text = "%02d:%02d" % [sec / 60, sec % 60]

func _nearest_to_ball(side: int, omit: int) -> int:
	var closest: int = -1
	var dist: float = INF
	for i in range(players.size()):
		if i == omit or players[i]["side"] != side or players[i]["number"] == 0:
			continue
		var p: Node3D = players[i]["node"]
		var d: float = p.position.distance_to(Vector3(ball_position.x, 0, ball_position.z))
		if d < dist:
			dist = d
			closest = i
	return closest

func _can_kick() -> bool:
	return running and screen_name == "partido" and (ball_owner == selected_player or
		(ball_owner == -1 and players[selected_player]["node"].position.distance_to(Vector3(ball_position.x, 0, ball_position.z)) < 2.0))

func _pass_ball() -> void:
	if not _can_kick():
		return
	var target_idx: int = -1
	var best: float = INF
	var pos: Vector3 = players[selected_player]["node"].position
	for i in range(1, 11):
		if i == selected_player:
			continue
		var target_pos: Vector3 = players[i]["node"].position
		var d: float = pos.distance_to(target_pos) + (15.0 if target_pos.x < pos.x else 0.0)
		if d < best:
			best = d
			target_idx = i
	if target_idx < 0:
		return
	var desired: Vector3 = (players[target_idx]["node"].position - pos).normalized()
	ball_owner = -1
	catch_delay = 0.35
	ball_position = pos + Vector3(desired.x * 1.6, 0.35, desired.z * 1.6)
	ball_velocity = desired * 30.0
	_notice("PASE A " + ROSTER[target_idx])

func _shoot_ball() -> void:
	if not _can_kick():
		return
	var pos: Vector3 = players[selected_player]["node"].position
	var desired: Vector3 = Vector3(53 - pos.x, 0, -pos.z * 0.75 + randf_range(-3.5, 3.5)).normalized()
	ball_owner = -1
	catch_delay = 0.35
	ball_position = pos + Vector3(1.5, 0.35, 0)
	ball_velocity = desired * 53.0
	_notice("¡REMATE!")

func _switch_player() -> void:
	var idx: int = _nearest_to_ball(0, selected_player)
	if idx < 0:
		return
	players[selected_player]["ring"].visible = false
	selected_player = idx
	players[selected_player]["ring"].visible = true
	_notice(ROSTER[selected_player])

func _ai_shoot() -> void:
	if ball_owner < 11:
		return
	var pos: Vector3 = players[ball_owner]["node"].position
	ball_owner = -1
	catch_delay = 0.45
	ball_position = pos + Vector3(-1.4, 0.35, 0)
	ball_velocity = Vector3(-48.0, 0, -pos.z * 0.5 + randf_range(-4.0, 4.0)).normalized() * 47.0
	ai_timer = 0.0

func _ai_pass() -> void:
	if ball_owner < 11:
		return
	var pos: Vector3 = players[ball_owner]["node"].position
	var target: int = 11 + randi_range(1, 10)
	if target == ball_owner:
		target = 20
	var delta_v: Vector3 = (players[target]["node"].position - pos).normalized()
	ball_owner = -1
	catch_delay = 0.4
	ball_position = pos + Vector3(delta_v.x * 1.5, 0.35, delta_v.z * 1.5)
	ball_velocity = delta_v * 28.0
	ai_timer = 0.0

func _goal(side: int) -> void:
	scoreboard[side] += 1
	goal_freeze = 1.6
	ball_owner = -1
	ball_velocity = Vector3.ZERO
	_notice("¡GOOOL! " + ABBREVIATIONS[team_home if side == 0 else team_away], 1.5)
	if is_instance_valid(score_label):
		score_label.text = "%d  :  %d" % scoreboard

func _reset_kickoff() -> void:
	for p in players:
		p["node"].position = p["start"]
		p["leg_l"].rotation.x = 0
		p["leg_r"].rotation.x = 0
	ball_owner = selected_player
	ball_position = players[selected_player]["node"].position + Vector3(1, 0.35, 0)
	ball_velocity = Vector3.ZERO
	goal_freeze = 0

func _start_match() -> void:
	game_clock = 0
	scoreboard = [0, 0]
	selected_player = 9
	game_over = false
	running = true
	pressed_sprint = false
	joystick_dir = Vector2.ZERO
	catch_delay = 0
	ai_timer = 0
	_reset_kickoff()
	for i in range(players.size()):
		players[i]["ring"].visible = (i == selected_player)
	screen_name = "partido"
	_show_hud()

func _set_formation(name: String) -> void:
	formation_name = name
	var places: Array[Vector2] = _positions(name)
	for i in range(players.size()):
		var idx: int = i % 11
		var side: int = players[i]["side"]
		var pt: Vector2 = places[idx]
		players[i]["start"] = Vector3(pt.x if side == 0 else -pt.x, 0, pt.y if side == 0 else -pt.y)
	_show_lineup()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if screen_name == "partido":
		match event.keycode:
			KEY_S:
				_pass_ball()
			KEY_D:
				_shoot_ball()
			KEY_Q:
				_switch_player()
			KEY_ESCAPE:
				_show_pause()
	elif screen_name == "pausa" and event.keycode == KEY_ESCAPE:
		_resume_match()
