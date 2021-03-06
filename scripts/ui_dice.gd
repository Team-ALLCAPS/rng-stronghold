extends Area2D

var val
var original_position
var lifted = false
var old_mouse_pos
var interactable = false

func _ready():
	original_position = position
	$Sprite.texture = load("res://res/dice/dice_" + str(val) + ".png")

func _input_event(viewport, event, shape_idx):
	if interactable and event is InputEventMouseButton:
		if not lifted and event.pressed and Input.is_action_just_pressed("lmb"):
			lifted = true
		elif lifted and Input.is_action_just_released("lmb"):
			lifted = false

func _process(delta):
	var new_mouse_pos = get_global_mouse_position()
	if input_pickable and not lifted:
		position = position.linear_interpolate(original_position, delta*5)
	elif lifted:
		global_position = global_position + (new_mouse_pos - old_mouse_pos)
	old_mouse_pos = new_mouse_pos
	
	if not interactable:
		rotation = 0 + rotation / 1.5
		if rotation < 0.01:
			rotation = 0
			interactable = true
			var grandparent = get_parent().get_parent()
			if grandparent.has_method("finished_rolling"):
				grandparent.finished_rolling(self)
