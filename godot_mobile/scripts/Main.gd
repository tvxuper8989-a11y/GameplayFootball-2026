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

func _clear_gui() -> void:
	for child in gui.get_children():
		gui.remove_child(child)
		child.queue_free()
	clock_label = null
	score_label = null
	notice_label = null

func _panel(rect: Rect2, fill: Color, rounded: int = 12, border: Color = Color.TRANSPARENT) -> Panel:
	var p: Panel = Panel.new()
	p.position = rect.position
	p.size = rect.size
	var st: StyleBoxFlat = StyleBoxFlat.new()
	st.bg_color = fill
	st.corner_radius_top_left = rounded
	st.corner_radius_top_right = rounded
	st.corner_radius_bottom_left = rounded
	st.corner_radius_bottom_right = rounded
	st.border_color = border
	if border.a > 0:
		st.set_border_width_all(2)
	p.add_theme_stylebox_override("panel", st)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gui.add_child(p)
	return p

func _label(text_value: String, rect: Rect2, font_size: int = 22, ink: Color = Color.WHITE, center: bool = false) -> Label:
	var l: Label = Label.new()
	l.text = text_value
	l.position = rect.position
	l.size = rect.size
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", ink)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if center else HORIZONTAL_ALIGNMENT_LEFT
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gui.add_child(l)
	return l

func _button(text_value: String, rect: Rect2, callback: Callable, primary: bool = false) -> Button:
	var b: Button = Button.new()
	b.text = text_value
	b.position = rect.position
	b.size = rect.size
	b.add_theme_font_size_override("font_size", 19)
	b.add_theme_color_override("font_color", Color("#d8f5f6"))
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color("#127d85") if primary else Color("#11394b")
	normal.border_color = Color("#27d6be") if primary else Color("#35788b")
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(11)
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = Color("#1eac9b")
	var pressed: StyleBoxFlat = normal.duplicate()
	pressed.bg_color = Color("#0c7e6d")
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.pressed.connect(callback)
	gui.add_child(b)
	return b

func _add_title(title: String, subtitle: String) -> void:
	_panel(Rect2(0, 0, 1280, 82), Color("#091c2ce8"), 0)
	_panel(Rect2(38, 24, 7, 35), Color("#2be0c3"), 0)
	_label(title, Rect2(62, 13, 800, 43), 31)
	_label(subtitle, Rect2(62, 52, 900, 23), 15, Color("#8eccd0"))
	_label("GAMEPLAY FOOTBALL  ·  2026 / 2027", Rect2(940, 18, 310, 40), 16, Color("#46e6c9"), true)

func _fill_menu() -> void:
	_clear_gui()
	_panel(Rect2(0, 0, 1280, 720), Color(0.015, 0.043, 0.073, 0.91), 0)

func _show_home() -> void:
	screen_name = "inicio"
	running = false
	_fill_menu()
	_add_title("GAMEPLAY FOOTBALL", "VERSIÓN 3D  ·  ANDROID  ·  ESPAÑOL")
	_label("EL FÚTBOL", Rect2(80, 138, 660, 92), 66)
	_label("EMPIEZA ACÁ.", Rect2(80, 229, 760, 95), 66, Color("#35edc9"))
	_label("Elegí tus equipos, armá la táctica y jugá un partido 3D.", Rect2(86, 333, 760, 48), 23, Color("#c6e2eb"))
	_button("▶  JUGAR PARTIDO", Rect2(83, 424, 337, 76), func(): _show_select(), true)
	_button("PLANES DE JUEGO", Rect2(437, 424, 290, 76), func(): _show_lineup())
	_button("CONFIGURACIÓN", Rect2(83, 521, 300, 67), func(): _show_settings())
	_button("CÓMO SE JUEGA", Rect2(403, 521, 324, 67), func(): _show_help())
	_panel(Rect2(822, 157, 360, 380), Color("#0a2e40bb"), 23, Color("#218a91"))
	_label("TEMPORADA", Rect2(864, 189, 275, 50), 27, Color("#b0d4df"), true)
	_label("26", Rect2(849, 247, 301, 146), 139, Color("#eafaff"), true)
	_panel(Rect2(864, 425, 267, 4), Color("#23dab8"), 0)
	_label("FOOTBALL 2026 / 27", Rect2(859, 457, 284, 36), 24, Color("#32edc8"), true)
	_label("FLECHAS  ·  S PASE  ·  D REMATE  ·  Q CAMBIAR", Rect2(87, 651, 1070, 38), 18, Color("#9ac4d2"))

func _change_team(side: int, direction: int) -> void:
	var id_value: int = team_home if side == 0 else team_away
	id_value = posmod(id_value + direction, TEAM_NAMES.size())
	if side == 0:
		team_home = id_value
		if team_home == team_away:
			team_away = posmod(team_away + 1, TEAM_NAMES.size())
	else:
		team_away = id_value
		if team_home == team_away:
			team_home = posmod(team_home + 1, TEAM_NAMES.size())
	_show_select()

func _show_select() -> void:
	screen_name = "equipos"
	_fill_menu()
	_add_title("ELEGIR EQUIPOS", "PARTIDO RÁPIDO  /  MODO LOCAL CONTRA IA")
	_button("‹ VOLVER", Rect2(40, 615, 215, 56), func(): _show_home())
	_panel(Rect2(120, 143, 452, 405), Color("#0b2c42"), 22, Color("#278a96"))
	_panel(Rect2(710, 143, 452, 405), Color("#0b2c42"), 22, Color("#278a96"))
	_label("LOCAL", Rect2(200, 161, 290, 41), 21, Color("#35eac3"), true)
	_label("VISITANTE", Rect2(790, 161, 290, 41), 21, Color("#35eac3"), true)
	_label(ABBREVIATIONS[team_home], Rect2(226, 208, 248, 148), 88, Color("#c7f8fa"), true)
	_label(ABBREVIATIONS[team_away], Rect2(816, 208, 248, 148), 88, Color("#eacd77"), true)
	_label(TEAM_NAMES[team_home], Rect2(154, 363, 390, 70), 25, Color.WHITE, true)
	_label(TEAM_NAMES[team_away], Rect2(743, 363, 390, 70), 25, Color.WHITE, true)
	_label("VS", Rect2(578, 260, 115, 100), 54, Color("#e7fff4"), true)
	_button("◀", Rect2(192, 459, 107, 54), func(): _change_team(0, -1))
	_button("▶", Rect2(396, 459, 107, 54), func(): _change_team(0, 1))
	_button("◀", Rect2(782, 459, 107, 54), func(): _change_team(1, -1))
	_button("▶", Rect2(986, 459, 107, 54), func(): _change_team(1, 1))
	_button("CONTINUAR  ›", Rect2(900, 607, 300, 66), func(): _show_lineup(), true)

func _show_lineup() -> void:
	screen_name = "tactica"
	_fill_menu()
	_add_title("PLAN DE JUEGO", "FORMACIONES Y POSICIONES REALES DEL PARTIDO")
	_panel(Rect2(75, 124, 695, 526), Color("#092f35"), 12, Color("#2c9291"))
	_panel(Rect2(116, 169, 620, 424), Color("#145c48"), 0)
	_panel(Rect2(429, 169, 2, 424), Color("#8ed7be"), 0)
	_panel(Rect2(116, 169, 620, 2), Color("#8ed7be"), 0)
	_panel(Rect2(116, 591, 620, 2), Color("#8ed7be"), 0)
	var positions: Array[Vector2] = _positions(formation_name)
	for i in range(positions.size()):
		var pos: Vector2 = positions[i]
		var px: float = 136 + (pos.x + 52.5) / 105.0 * 576.0
		var py: float = 193 + (pos.y + 34) / 68.0 * 378.0
		_panel(Rect2(px - 24, py - 23, 48, 46), Color("#163f4d"), 13, Color("#d3c581"))
		_label("%d" % (i + 1), Rect2(px - 20, py - 23, 40, 44), 22, Color("#effefa"), true)
	_panel(Rect2(804, 127, 397, 520), Color("#0e2a40"), 20, Color("#25607b"))
	_label("FORMACIÓN", Rect2(833, 163, 325, 49), 31)
	_label(formation_name, Rect2(833, 210, 320, 90), 62, Color("#2af0c7"))
	_label("Elegí cómo se distribuyen tus jugadores.\nLos compañeros seguirán este esquema\ndurante el partido.", Rect2(830, 309, 340, 115), 21, Color("#bfd9e0"))
	var forms: Array[String] = ["4-3-3", "4-4-2", "3-5-2"]
	for i in range(3):
		var choice: String = forms[i]
		_button(choice, Rect2(817 + i * 122, 464, 113, 60), func(): _set_formation(choice), choice == formation_name)
	_button("CONTINUAR", Rect2(827, 552, 345, 66), func(): _show_intro(), true)
	_button("‹ VOLVER", Rect2(76, 661, 210, 45), func(): _show_home())

func _show_intro() -> void:
	screen_name = "presentacion"
	_fill_menu()
	_add_title("CARA A CARA", "ESTADIO METROPOLITANO  ·  PARTIDO DE EXHIBICIÓN")
	_panel(Rect2(82, 164, 430, 337), Color("#11354a"), 20, Color("#3c9caa"))
	_panel(Rect2(762, 164, 430, 337), Color("#11354a"), 20, Color("#3c9caa"))
	_label(ABBREVIATIONS[team_home], Rect2(176, 188, 245, 152), 95, Color("#bfe8fc"), true)
	_label(ABBREVIATIONS[team_away], Rect2(854, 188, 245, 152), 95, Color("#f0d57e"), true)
	_label(TEAM_NAMES[team_home], Rect2(112, 369, 373, 64), 25, Color.WHITE, true)
	_label(TEAM_NAMES[team_away], Rect2(798, 369, 366, 64), 25, Color.WHITE, true)
	_label("VS", Rect2(528, 274, 220, 120), 78, Color("#2ff0cb"), true)
	_label("LOCAL", Rect2(201, 450, 195, 34), 17, Color("#8ad9d4"), true)
	_label("VISITANTE", Rect2(887, 450, 195, 34), 17, Color("#8ad9d4"), true)
	_label("ESQUEMA " + formation_name + "  ·  90 MINUTOS DE JUEGO", Rect2(366, 528, 550, 48), 24, Color("#bfd5df"), true)
	_button("‹ VOLVER", Rect2(118, 611, 230, 57), func(): _show_lineup())
	_button("▶  COMENZAR PARTIDO", Rect2(794, 602, 371, 75), func(): _start_match(), true)

func _show_help() -> void:
	_fill_menu()
	screen_name = "ayuda"
	_add_title("CONTROLES", "CONSEJOS PARA ANDROID Y PC")
	_label("ANDROID", Rect2(90, 145, 420, 52), 34, Color("#28edc4"))
	_label("JoystICK izquierdo: mover al jugador.\nPASE: pasar al compañero.\nREMATE: disparar.\nCAMBIAR: elegir el jugador más cercano.\nCORRER: mantener presionado.", Rect2(92, 220, 650, 268), 25)
	_label("TECLADO", Rect2(725, 145, 420, 52), 34, Color("#28edc4"))
	_label("Flechas: moverse.\nS: pase.    D: remate.\nQ: cambiar jugador.    E: correr.\nEsc: pausa.", Rect2(727, 220, 470, 240), 25)
	_button("VOLVER AL INICIO", Rect2(458, 572, 363, 71), func(): _show_home(), true)

func _show_settings() -> void:
	screen_name = "ajustes"
	_fill_menu()
	_add_title("CONFIGURACIÓN", "AJUSTES DE RENDIMIENTO PARA ANDROID")
	_label("LÍMITE DE FOTOGRAMAS", Rect2(124, 166, 570, 60), 32)
	_label("Los FPS reales dependen de la GPU y la pantalla del teléfono.", Rect2(124, 220, 795, 45), 20, Color("#95c1cb"))
	for i in range(3):
		var choice: int = [30, 60, 120][i]
		_button(str(choice) + " FPS", Rect2(124 + i * 257, 305, 231, 70),
			func(): _change_fps(choice), choice == fps_target)
	_label("CÁMARA", Rect2(124, 430, 420, 47), 31)
	for i in range(3):
		var camera_name: String = ["TV", "TÁCTICA", "DINÁMICA"][i]
		_button(camera_name, Rect2(124 + i * 257, 504, 231, 62),
			func(): _set_camera(camera_name), camera_name == camera_mode)
	_button("VOLVER", Rect2(124, 615, 300, 64), func(): _show_home(), true)

func _change_fps(fps: int) -> void:
	fps_target = fps
	Engine.max_fps = fps
	_show_settings()

func _set_camera(mode: String) -> void:
	camera_mode = mode
	_show_settings()

func _show_hud() -> void:
	_clear_gui()
	_panel(Rect2(24, 18, 456, 72), Color("#061c2aeb"), 12, Color("#1a9b95"))
	_label(ABBREVIATIONS[team_home], Rect2(35, 23, 115, 58), 26, Color("#c8f7fc"), true)
	score_label = _label("%d  :  %d" % scoreboard, Rect2(146, 23, 159, 58), 32, Color.WHITE, true)
	_label(ABBREVIATIONS[team_away], Rect2(304, 23, 104, 58), 26, Color("#ffe6ab"), true)
	clock_label = _label("00:00", Rect2(401, 24, 81, 57), 21, Color("#29f2be"), true)
	_panel(Rect2(855, 20, 396, 65), Color("#062a38d7"), 12, Color("#1b8d9b"))
	_button("CÁMARA", Rect2(865, 28, 131, 49), func(): _cycle_camera())
	_button("TÁCTICA", Rect2(1006, 28, 130, 49), func(): _show_pause())
	_button("☰", Rect2(1147, 28, 94, 49), func(): _show_pause())
	_panel(Rect2(16, 638, 478, 53), Color("#092c3abb"), 12)
	_label("JOYSTICK  ·  CONTROL DEL JUGADOR", Rect2(37, 639, 432, 52), 17, Color("#b2e5e9"))
	notice_label = _label("", Rect2(364, 120, 552, 69), 39, Color("#28f9bf"), true)
	var j: Control = Control.new()
	j.set_script(load("res://scripts/Joystick.gd"))
	j.position = Vector2(63, 440)
	j.size = Vector2(176, 176)
	gui.add_child(j)
	j.connect("direction_changed", Callable(self, "_set_joystick_dir"))
	_button("PASE", Rect2(1005, 497, 118, 84), func(): _pass_ball(), true)
	_button("REMATE", Rect2(1135, 381, 126, 89), func(): _shoot_ball(), true)
	_button("CAMBIAR", Rect2(872, 573, 130, 85), func(): _switch_player())
	var sprint_button: Button = _button("CORRER", Rect2(1128, 575, 133, 91), func(): pass, true)
	sprint_button.button_down.connect(func(): pressed_sprint = true)
	sprint_button.button_up.connect(func(): pressed_sprint = false)

func _set_joystick_dir(value: Vector2) -> void:
	joystick_dir = value

func _cycle_camera() -> void:
	if camera_mode == "TV":
		camera_mode = "TÁCTICA"
	elif camera_mode == "TÁCTICA":
		camera_mode = "DINÁMICA"
	else:
		camera_mode = "TV"
	_notice("CÁMARA: " + camera_mode)

func _notice(message: String, duration: float = 1.0) -> void:
	notice_timer = duration
	if is_instance_valid(notice_label):
		notice_label.text = message

func _show_pause() -> void:
	if screen_name != "partido":
		return
	screen_name = "pausa"
	running = false
	pressed_sprint = false
	joystick_dir = Vector2.ZERO
	_fill_menu()
	_add_title("PARTIDO EN PAUSA", "ESTADIO METROPOLITANO")
	_label(ABBREVIATIONS[team_home] + "  " + str(scoreboard[0]) + "  -  " +
		str(scoreboard[1]) + "  " + ABBREVIATIONS[team_away], Rect2(270, 160, 750, 110), 62, Color("#ddfff5"), true)
	_button("▶  CONTINUAR", Rect2(452, 315, 365, 69), func(): _resume_match(), true)
	_button("CAMBIAR CÁMARA: " + camera_mode, Rect2(451, 406, 367, 66), func(): _cycle_camera_pause())
	_button("CAMBIAR FORMACIÓN: " + formation_name, Rect2(451, 489, 367, 66), func(): _cycle_formation_pause())
	_button("SALIR DEL PARTIDO", Rect2(451, 576, 367, 64), func(): _show_home())

func _cycle_camera_pause() -> void:
	_cycle_camera()
	_show_pause_repaint()

func _show_pause_repaint() -> void:
	screen_name = "partido"
	_show_pause()

func _cycle_formation_pause() -> void:
	if formation_name == "4-3-3":
		formation_name = "4-4-2"
	elif formation_name == "4-4-2":
		formation_name = "3-5-2"
	else:
		formation_name = "4-3-3"
	var poses: Array[Vector2] = _positions(formation_name)
	for i in range(players.size()):
		var pi: int = i % 11
		var team_side: int = players[i]["side"]
		var pos: Vector2 = poses[pi]
		players[i]["start"] = Vector3(pos.x if team_side == 0 else -pos.x, 0,
			pos.y if team_side == 0 else -pos.y)
	_show_pause_repaint()

func _resume_match() -> void:
	screen_name = "partido"
	running = true
	_show_hud()

func _show_results() -> void:
	screen_name = "resultado"
	_fill_menu()
	_add_title("FINAL DEL PARTIDO", "RESUMEN DEL ENCUENTRO")
	_label(TEAM_NAMES[team_home], Rect2(115, 183, 455, 68), 32, Color.WHITE, true)
	_label(TEAM_NAMES[team_away], Rect2(710, 183, 455, 68), 32, Color.WHITE, true)
	_label("%d   -   %d" % scoreboard, Rect2(375, 283, 536, 152), 110, Color("#33efca"), true)
	var headline: String = "EMPATE"
	if scoreboard[0] > scoreboard[1]:
		headline = "VICTORIA LOCAL"
	elif scoreboard[1] > scoreboard[0]:
		headline = "VICTORIA VISITANTE"
	_label(headline, Rect2(392, 456, 495, 66), 35, Color("#e9fbf5"), true)
	_button("REVANCHA", Rect2(304, 594, 320, 76), func(): _start_match(), true)
	_button("INICIO", Rect2(654, 594, 320, 76), func(): _show_home())
