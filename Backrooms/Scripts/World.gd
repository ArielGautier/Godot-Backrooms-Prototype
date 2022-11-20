extends Spatial

var rng = RandomNumberGenerator.new()

export var world_width = 15
export var world_height = 15

var player = load("res://Scenes/Player.tscn").instance()
var platform_res = load("res://Scenes/Platform.tscn")
var ambient_1_res = load("res://Scenes/Table_and_Chairs.tscn")

var world = []
var gen_world = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(world_width):
		world.append([])
		for y in range(world_height):
			world[x].append([])
			world[x][y] = _plat.new(x,y)
	add_child(player)
	_create_world()

var valid_rooms = 0
var _walls = 0
var rooms_to_gen = world_height * world_width
func _create_world():
	var romm_numbers
	var x = 0
	var y = 0
	for i in range(rooms_to_gen):
		var chosen = ""
		
		var possible = getValids(x,y, false)
		var door_type = 2 + rng.randi()%2
		rng.randomize()
		if possible.size() > 0:
			chosen = possible[ rng.randi()%possible.size() ]
			valid_rooms += 1
			match chosen:
				'U':
					world[x][y].up = door_type
					world[x][y].active = true
					normalize_wall(x,y)
					y+=1
				'L':
					world[x][y].left = door_type
					world[x][y].active = true
					normalize_wall(x,y)
					x-=1
				'R':
					world[x][y].right = door_type
					world[x][y].active = true
					normalize_wall(x,y)
					x+=1
				'D':
					world[x][y].down = door_type
					world[x][y].active = true
					normalize_wall(x,y)
					y-=1
		else:
			possible = getValids(x,y, true)
			chosen = possible[ rng.randi()%possible.size() ]
			match chosen:
				'U':
					if(world[x][y+1].down == 0):
						world[x][y].up = door_type
					else:
						world[x][y+1].down = door_type
					world[x][y].active = true
					normalize_wall(x,y)
					y+=1
				'L':
					if(world[x-1][y].right == 0):
						world[x][y].left = door_type
					else:
						world[x-1][y].right = door_type
					world[x][y].active = true
					normalize_wall(x,y)
					x-=1
				'R':
					if(world[x+1][y].left == 0):
						world[x][y].right = door_type
					else:
						world[x+1][y].left = door_type
					world[x][y].active = true
					normalize_wall(x,y)
					x+=1
				'D':
					if(world[x][y-1].up == 0):
						world[x][y].down = door_type
					else:
						world[x][y-1].up = door_type
					world[x][y].active = true
					normalize_wall(x,y)
					y-=1
		if(rooms_to_gen-1 == i+1):
			world[x][y].is_end = true
		elif(rng.randi()%30):
			world[x][y].audio_node = true
	print(valid_rooms,"/",rooms_to_gen)
	print(_walls,"/",valid_rooms)
	gen_world = true

func normalize_wall(x,y):
	var p = world[x][y]
	if(p.up == 0):
		if(y+1 >= world_height):
			p.up = 1
			_walls += 1
		elif not (world[x][y+1].active):
			p.up = 1
			_walls += 1
	if(p.left == 0):
		if(x-1 < 0):
			p.left = 1
			_walls += 1
		elif not (world[x-1][y].active):
			p.left = 1
			_walls += 1
	if(p.right == 0):
		if(x+1 >= world_width):
			p.right = 1
			_walls += 1
		elif not (world[x+1][y].active):
			p.right = 1
			_walls += 1
	if(p.down == 0):
		if(y-1 < 0):
			p.down = 1
			_walls += 1
		elif not (world[x][y-1].active):
			p.down = 1
			_walls += 1

func getValids(x,y, plat_is_valid):
	var possible = []
	##check Up
	if(y+1 < world_height) and (not (world[x][y+1].active) or plat_is_valid):
			possible.append('U')
	##check Left
	if(x-1 >= 0) and (not (world[x-1][y].active) or plat_is_valid):
		possible.append('L')
	##check Right
	if(x+1 < world_width) and (not (world[x+1][y].active) or plat_is_valid):
		possible.append('R')
	##check Down
	if(y-1 >= 0) and (not (world[x][y-1].active) or plat_is_valid):
		possible.append('D')
	return possible

func wall_to_text(n):
	match n:
		0:
			return null 
		1:
			return "Wall"
		2:
			return "Door"
		3:
			return "Empty"

var gx = 0
var gy = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(gen_world):
		#print(x, ", ",y)
		var plat = world[gx][gy]
		if(plat.active):
			var platform = platform_res.instance()
			platform.set_translation(Vector3(gy*20,0,gx*20))
			var nodeName = ""
			var type = ""

			nodeName = "Top/"
			type = wall_to_text(plat.up)
			if (type != null):
				platform.get_node(nodeName+type).visible = true
				platform.get_node(nodeName+type+"/Col").disabled = false
				
			nodeName = "Left/"
			type = wall_to_text(plat.left)
			if(type != null):
				platform.get_node(nodeName+type).visible = true
				platform.get_node(nodeName+type+"/Col").disabled = false
				
			nodeName = "Right/"
			type = wall_to_text(plat.right)
			if(type != null):
				platform.get_node(nodeName+type).visible = true
				platform.get_node(nodeName+type+"/Col").disabled = false
				
			nodeName = "Bottom/"
			type = wall_to_text(plat.down)
			if(type != null):
				platform.get_node(nodeName+type).visible = true
				platform.get_node(nodeName+type+"/Col").disabled = false
			
			if(plat.is_end):
				#platform.get_node("Floor").visible = false
				platform.get_node("Floor").use_collision = false
				#platform.add_child(mirror.instance())
			##Generate ambient objects
			#if(plat.audio_node):
			#	platform.get_node("Audio")._set_playing(true)
				
			if 0 == rng.randi()%20:
				var amb = ambient_1_res.instance()
				amb.set_translation(Vector3(rng.randi()%12-5,0,rng.randi()%12-5))
				amb.rotate_y(rng.randi()%360)
				platform.add_child(amb)
				pass
			add_child(platform)
		gx += 1
		if(gx >= world_width):
			gx = 0
			gy += 1
		if(gy >= world_height):
			gx = 0
			gy = 0
			gen_world = false

class _plat:
	var audio_node = false
	var active = false
	var is_end = false
	var up = 0
	var left = 0
	var right = 0
	var down = 0
	
	var x
	var y
	
	func _init(sx,sy):
		x = sx
		y = sy
