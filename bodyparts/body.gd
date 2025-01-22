extends Line2D

var _char_body : CharacterBody2D
var _default_positions : Dictionary = {
	Line_Joints.Head : Vector2(0,0),
	Line_Joints.Legs : Vector2(0,0)
}
var _body_tween: Tween
var _default_y : float

var _length : float

var _up : bool = true
var _down : bool = false
var _mov : bool = false
var _stop : bool = false

enum Line_Joints {
	Head = 0,
	Legs = 1
}

func _ready():
	_char_body = get_parent()
	_default_positions[Line_Joints.Head] = _get_head_position()
	_default_positions[Line_Joints.Legs] = _get_leg_position()
	_length = _get_head_position().distance_to(_get_leg_position())
	_default_y = position.y

func _process(delta: float):
	_adjust_to_velocity()
	if Input.is_action_pressed("ui_left") != Input.is_action_pressed("ui_right"):
			_stop = true
	if not _mov and _stop:
		if _char_body.velocity.x != 0:
			if _up:
				_body_tween_up()
			elif _down:
				_body_tween_down()
	if Input.is_action_pressed("ui_left") == Input.is_action_pressed("ui_right") and _body_tween != null:
		_body_tween.kill()
		_body_tween_default()
		_stop = false


func _body_tween_default():
	_mov = true
	_down = false
	var tw = get_tree().create_tween();
	await tw.tween_property($".", "position:y", _default_y, 0.2).finished
	_mov = false
	_up = true

func _body_tween_down():
	_mov = true
	_down = false
	_body_tween = get_tree().create_tween();
	await _body_tween.tween_property($".", "position:y", position.y + 20, 0.3).finished
	_mov = false
	_up = true

func _body_tween_up():
	_mov = true
	_up = false
	_body_tween = get_tree().create_tween();
	await _body_tween.tween_property($".", "position:y", position.y - 20, 0.3).finished
	_mov = false
	_down = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dbg1"):
		_adjust_to_velocity()
	if event.is_action_pressed("dbg2"):
		_return_to_default_position()

func _get_leg_position() -> Vector2:
	return get_point_position(Line_Joints.Legs)

func _get_head_position() -> Vector2:
	return get_point_position(Line_Joints.Head)

func _adjust_to_velocity():
	var vel = _char_body.velocity
	var x = sqrt(pow(_length/2,2)-pow(_default_positions[Line_Joints.Head].y,2)) * (1 / _char_body._max_velocity * vel.x)
	var target = Vector2(x, _default_positions[Line_Joints.Head].y)
	set_point_position(Line_Joints.Head,target)

func _return_to_default_position():
	set_point_position(Line_Joints.Head,_default_positions[Line_Joints.Head])
	set_point_position(Line_Joints.Legs,_default_positions[Line_Joints.Legs])