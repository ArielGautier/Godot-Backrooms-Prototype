extends Camera

onready var mouse = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_toggle_mouse()
	
func _toggle_mouse():
	if(mouse):
		mouse = false
		#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		mouse = true
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
var timer_button = 0
func _process(delta):
	if(timer_button >= 0):
		timer_button -= delta
	elif(Input.get_action_strength("ShowMouse")):
		_toggle_mouse()
		timer_button += 0.2
