extends KinematicBody

export var max_speed = 10
export var gravity = 100
export var jump = 25

#var Starter
var velocity =- Vector3.ZERO
var pellet_res = load("res://Scenes/Pellet.tscn")

onready var cam = get_node("CameraStand/FP")
onready var second_cam = get_node("AC/Cam")
onready var real_cam = cam.get_node("Cam")
onready var light = get_node("SpotLight")
onready var cam_stand = get_node("CameraStand")
onready var cam_stand_colision = get_node("Stand")
onready var TireSounds = get_node("Tires")
onready var control = get_node("Control")
onready var button_exit = control.get_node("Button_Lord/exit")

onready var button_cam_f = control.get_node("Button_Lord/Cam_forward")
onready var button_cam_m = control.get_node("Button_Lord/Cam_mid")
onready var button_cam_b = control.get_node("Button_Lord/Cam_back")
onready var button_switch_cam = control.get_node("Button_Lord/Switch_cam")

onready var cam_move_buttons = control.get_node("CenterContainer")
onready var move_buttons = []

onready var delta = (cam_stand.translation-cam_stand_colision.translation)
onready var length = sqrt(delta.x*delta.x+delta.y*delta.y+delta.z*delta.z)

var max_arm_angle = (80*PI)/180

var paused = false

func cam_to_forward():
	moveCamUp = false
	moveCamBack = false
	moveCamForward = true
func cam_to_back():
		moveCamUp = false
		moveCamForward = false
		moveCamBack = true
func cam_to_up():
		moveCamBack = false
		moveCamForward = false
		moveCamUp = true

func arm(x):
	## rotate cam arm
	cam_stand.rotate_x(x * get_process_delta_time())
	## rotate colision box and normalize
	cam_stand.rotation.x = clamp(cam_stand.rotation.x, -max_arm_angle, max_arm_angle)
	var offset = Vector3(0, length*cos((cam_stand.rotation.x)), length*sin((cam_stand.rotation.x)))
	cam_stand_colision.translation = cam_stand.translation + offset
	cam_stand_colision.rotation = cam_stand.rotation
	return cam_stand.rotation.x

func _ready():
	move_buttons.append(cam_move_buttons.get_node("NinePatchRect/Up"))
	move_buttons.append(cam_move_buttons.get_node("NinePatchRect/Left"))
	move_buttons.append(cam_move_buttons.get_node("NinePatchRect/Right"))
	move_buttons.append(cam_move_buttons.get_node("NinePatchRect/Down"))
	
	button_exit.connect("pressed", self, "exit")
	button_cam_f.connect("pressed", self, "cam_to_forward")
	button_cam_m.connect("pressed", self, "cam_to_up")
	button_cam_b.connect("pressed", self, "cam_to_back")
	button_switch_cam.connect("pressed", self, "switch_Cameras")
	move_buttons[0].connect("pressed", self, "cam_up")
	move_buttons[1].connect("pressed", self, "cam_left")
	move_buttons[2].connect("pressed", self, "cam_right")
	move_buttons[3].connect("pressed", self, "cam_down")
	

var moveCamForward = false
var moveCamBack = false
var moveCamUp = false
var button_time = 0
func _process(delta):
	real_cam.get_tree().call_group("mirrors","update_cam",real_cam.global_transform)
	if(button_time >= 0):
		button_time -= delta
	elif(Input.get_action_strength("Light")):
		button_time += 0.2
		light.visible = !light.visible
	elif(translation.y <= -0.2):
		get_tree().change_scene("res://Scenes/Lvl_1.tscn")
	
	if(moveCamForward) and (arm(-0.5) <= -max_arm_angle+0.1):
			moveCamForward = false
	elif(moveCamBack) and arm(0.5) >= max_arm_angle-0.1:
			moveCamBack = false
	elif(moveCamUp):
		var rot = arm(0)
		if(-0.01 > rot):
			arm(0.5)
		elif(rot > 0.01):
			arm(-0.5)
		else:
			moveCamUp = false

func switch_Cameras():
	if(button_time < 0):
		button_time += 0.2
		if(real_cam.current):
			real_cam.current = false
			second_cam.current = true
		else:
			real_cam.current = true
			second_cam.current = false

func _physics_process(delta):
	var input_vector = get_input_vector()
	apply_moveset(input_vector)
	velocity.y -= gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)

func get_input_vector():
	var input_vector = Vector3.ZERO
	input_vector.z = Input.get_action_strength("Strafe_Right") - Input.get_action_strength("Strafe_Left")
	input_vector.x = Input.get_action_strength("Forward") - Input.get_action_strength("Back")
	if(input_vector.x != 0 or input_vector.z != 0):
		if(!TireSounds.playing):
			TireSounds.playing = true
	else:
		TireSounds.playing = false
	
	return input_vector.normalized()

func apply_moveset(input_vector):
	pass
	## | Tank Controlls |
	velocity.z = -input_vector.x * cos((rotation_degrees.y * PI )/180) * max_speed
	velocity.x = -input_vector.x * sin((rotation_degrees.y * PI )/180) * max_speed
	rotate_y(-input_vector.z * get_process_delta_time() * 1.5)
	## | First Person Relative movment |
	#velocity.z = -input_vector.z * sin((rotation_degrees.y * PI )/180) * max_speed 
	#velocity.z -= input_vector.x * cos((rotation_degrees.y * PI )/180) * max_speed
	#velocity.x = input_vector.z * cos((rotation_degrees.y * PI )/180) * max_speed
	#velocity.x -= input_vector.x * sin((rotation_degrees.y * PI )/180) * max_speed
	## | World relative movement |
	#velocity.z = input_vector.z * max_speed
	#velocity.x = input_vector.x * max_speed

func cam_up():
	turn_camera(0,-10)
func cam_left():
	turn_camera(-10,0)
func cam_right():
	turn_camera(10,0)
func cam_down():
	turn_camera(0,10)

var _total_pitch = 0.0
var max_y_up = 80
var max_y_down = 45
func turn_camera(x, y):
	var pitch = clamp(y, -max_y_up - _total_pitch, max_y_down - _total_pitch)
	_total_pitch += pitch
	cam.rotate_y(-x * get_process_delta_time())
	cam.rotate_object_local(Vector3(1,0,0), deg2rad(-pitch))
func _input(event):
	##--==Move Camera==--
	if event is InputEventMouseMotion:
		if get_node("CameraStand/FP/Cam").get("mouse"):
			##--Tank Control--
			turn_camera(event.relative.x, event.relative.y)
			cam_move_buttons.visible = false
		else:
			cam_move_buttons.visible = true
	##--==Keyboard Inputs==--
	elif(event is InputEventKey):
		##--==Exit Game==--
		if event.as_text() == 'L':
			exit()
		##--==Move Camera arm+collision box==--
		elif (Input.get_action_strength("ArmUp")):
			arm(-Input.get_action_strength("ArmUp"))
		elif (Input.get_action_strength("ArmDown")):
			arm(Input.get_action_strength("ArmDown"))

## Brute force closes game
func exit():
	get_tree().quit()
