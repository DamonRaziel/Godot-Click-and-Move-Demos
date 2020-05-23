extends KinematicBody

var maxspeed = 400
var speed = 0
var movedirection
var acceleration = 120
var moving = false
var destination = Vector3()
var movement = Vector3()
var position = Vector3(0, 0, 0) # ?

# added vars
var player_position = Vector3()
var marker_position = Vector3()
var move_speed = 15.0
var slow_speed = 3.0
var travel_speed = 5.0
var velocity = Vector3()
var gravity = 0.0

func _input(event):
#func _unhandled_input(event):
#	if event.isactionpressed('Botonderecho'):
#		moving = true
		#destination = globaltransform # here is wherei had the most trouble so far
	if (event.is_class("InputEventMouseButton") and event.button_index == BUTTON_LEFT and event.pressed):
		var from = get_parent().get_node("Cam").project_ray_origin(event.position)#*100

		var to = from + get_parent().get_node("Cam").project_ray_normal(event.position)*100
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [self], collision_mask)
		print ("RESULT : ", result.position)
		moving = true
		destination = result.position

func  _physics_process(delta):
	move_to_marker(destination, delta)
#	MovementLoop(delta)

#func MovementLoop(delta):
#	if moving == false:
#		speed = 0
#	else:
#		speed += acceleration * delta
#	if speed > maxspeed:
#		speed = maxspeed
#		movement = position.direction_to(destination) * speed #move_direction(destination) * speed
#		movedirection = rad2deg(destination.angle_to(destination)) #angleto doesnt work on 3.2.1
#	if position.distance_to(destination) > 5:
#		movement = move_and_slide(movement)
#	else:
#		moving = false

func move_to_marker (marker, delta):
	player_position = self.get_global_transform().origin
	marker_position = marker
	var offset = Vector3()
	offset = marker_position - player_position
	var dir = Vector3()
	dir += offset
	dir = dir.normalized()
	velocity.y += delta*gravity
	var hv = velocity
	var target = dir
	var attacking = false
	target *= move_speed
	var ATTACK_ACCEL = 1
	var SPRINT_ACCEL = 2
	var accel
	if dir.dot(hv) > 0:
		accel = travel_speed
	else:
		accel = slow_speed
	hv = hv.linear_interpolate(target, accel*delta)
	velocity.x = hv.x
	velocity.z = hv.z
	velocity.y = hv.y
	velocity = move_and_slide(velocity, Vector3(0,1,0))

