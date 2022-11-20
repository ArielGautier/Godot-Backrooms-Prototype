extends RigidBody

var time_elapsed = 0

var velocity =- Vector3.ZERO
export var gravity = 2

func _ready():
	velocity = get_linear_velocity()
	connect("body_entered", self, "_on_Area_body_entered")

func _physics_process(delta):
	time_elapsed += delta
	#velocity.y -= gravity * delta
	#velocity.x = velocity.x * 0.99
	#velocity.z = velocity.z * 0.99
	#set_linear_velocity(velocity)
	if time_elapsed > 2.5:
		queue_free()
	
func _on_Area_body_entered(body:Node) -> void:
	print("Collided")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
