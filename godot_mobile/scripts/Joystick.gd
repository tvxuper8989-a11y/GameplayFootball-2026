extends Control

signal direction_changed(direction: Vector2)

var direction: Vector2 = Vector2.ZERO
var tracking_finger: int = -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(false)

func _draw() -> void:
	var center: Vector2 = size * 0.5
	var radius: float = minf(size.x, size.y) * 0.47
	draw_circle(center, radius, Color(0.08, 0.19, 0.24, 0.66))
	draw_arc(center, radius, 0.0, TAU, 44, Color(0.57, 0.88, 0.91, 0.65), 3.0, true)
	draw_circle(center + direction * radius * 0.53, radius * 0.37, Color(0.65, 0.96, 0.95, 0.86))
	draw_arc(center + direction * radius * 0.53, radius * 0.37, 0.0, TAU, 24, Color.WHITE, 2.0, true)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and tracking_finger == -1:
			tracking_finger = event.index
			_update_direction(to_local(event.position))
			accept_event()
		elif not event.pressed and event.index == tracking_finger:
			_reset()
			accept_event()
	elif event is InputEventScreenDrag and event.index == tracking_finger:
		_update_direction(to_local(event.position))
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			tracking_finger = -2
			_update_direction(event.position)
		else:
			_reset()
		accept_event()
	elif event is InputEventMouseMotion and tracking_finger == -2:
		_update_direction(event.position)
		accept_event()

func _update_direction(local_pos: Vector2) -> void:
	var center: Vector2 = size * 0.5
	var radius: float = maxf(1.0, minf(size.x, size.y) * 0.42)
	direction = (local_pos - center) / radius
	if direction.length() > 1.0:
		direction = direction.normalized()
	queue_redraw()
	direction_changed.emit(direction)

func _reset() -> void:
	tracking_finger = -1
	direction = Vector2.ZERO
	queue_redraw()
	direction_changed.emit(direction)

func _exit_tree() -> void:
	direction = Vector2.ZERO
