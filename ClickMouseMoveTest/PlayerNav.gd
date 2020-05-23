extends KinematicBody

var maxspeed = 400
#var speed = 0
var movedirection
var acceleration = 120
var moving = false
var destination = Vector3()
var movement = Vector3()
var position = Vector3(0, 0, 0) # ?

func _ready():
	navmesh = get_parent().get_node("Ground/Navigation")

func _input(event):
	if Input.is_action_pressed("LMBClick"):
		var from = get_parent().get_node("Cam").project_ray_origin(event.position)#*100
		var to = from + get_parent().get_node("Cam").project_ray_normal(event.position)*100
		print ("From : ", from, " and To : ", to)
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [self], collision_mask)
		print ("RESULT : ", result.position)
		
		var p = navmesh.get_closest_point_to_segment(from, to)
		
		begin = navmesh.get_closest_point(self.get_translation())#.get_translation()
		end = p
		
		moving = true
		destination = result.position
		target = destination
		calculate_path()

var speed = 6.5
var target = null
var navmesh
var path = []
var begin = Vector3()
var end = Vector3()

func _process(delta):
	if (path.size() > 1):
		var to_walk = delta*speed
		var to_watch = Vector3(0, 1, 0)
		while(to_walk > 0 and path.size() >= 2):
			var pfrom = path[path.size() - 1]
			var pto = path[path.size() - 2]
			to_watch = (pto - pfrom).normalized()
			var d = pfrom.distance_to(pto)
			if (d <= to_walk):
				path.remove(path.size() - 1)
				to_walk -= d
			else:
				path[path.size() - 1] = pfrom.linear_interpolate(pto, to_walk/d)
				to_walk = 0
			
			var atpos = path[path.size() - 1]
			var atdir = to_watch
			atdir.y = 0
			
			var t = Transform()
			t.origin = atpos
			t=t.looking_at(atpos + atdir, Vector3(0, 1, 0))
			set_transform(t)
			if (path.size() < 2):
				path = []
	else:
		set_process(false)

func calculate_path():
	begin = navmesh.get_closest_point(self.get_translation())
	end = navmesh.get_closest_point(target)
	var p = navmesh.get_simple_path(begin, end, true) 
	path = Array(p)
	path.invert()
	set_process(true)
#	set_physics_process(false)

