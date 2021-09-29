extends KinematicBody

# modified and cut down from RTS example
# uses GDQuests steering behaviours and miziziziz AStar gridmaps

# RMB - set target position
# LMB - hold to move to target position


export (float, 0, 100, 5) var linear_speed_max := 10.0 #setget set_linear_speed_max
export (float, 0, 100, 0.1) var linear_acceleration_max := 1.0 #setget set_linear_acceleration_max
export (float, 0, 50, 0.1) var arrival_tolerance := 1.0 #0.5 #setget set_arrival_tolerance
export (float, 0, 50, 0.1) var deceleration_radius := 5.0 #setget set_deceleration_radius
export (int, 0, 1080, 10) var angular_speed_max := 270 #setget set_angular_speed_max
export (int, 0, 2048, 10) var angular_accel_max := 45 #setget set_angular_accel_max
export (int, 0, 178, 2) var align_tolerance := 5 #setget set_align_tolerance
export (int, 0, 180, 2) var angular_deceleration_radius := 45 #setget set_angular_deceleration_radius


onready var priority := GSAIPriority.new(agent)
onready var agent := GSAIKinematicBody3DAgent.new(self)
onready var target := GSAIAgentLocation.new()
onready var accel := GSAITargetAcceleration.new()
onready var blend := GSAIBlend.new(agent)
onready var look := GSAILookWhereYouGo.new(agent)

onready var amap = get_node("/root/Main/AStarControl")
#var _valid := false
var amap_path = []
var amap_path_ind = 0
onready var unit_target = null

onready var path := GSAIPath.new(
	[
		Vector3(global_transform.origin.x, global_transform.origin.y, global_transform.origin.z),
		Vector3(global_transform.origin.x, global_transform.origin.y, global_transform.origin.z)
	],
	true
)
onready var follow := GSAIFollowPath.new(agent, path, 0, 0)
onready var follow_blend := GSAIBlend.new(agent)
var _valid := false

var allow_move = false


# Called when the node enters the scene tree for the first time.
func _ready():
	
	setup(align_tolerance, #: float,
	angular_deceleration_radius, #: float,
	angular_accel_max, #: float,
	angular_speed_max, #: float,
	deceleration_radius, #: float,
	arrival_tolerance, #: float,
	linear_acceleration_max, #: float,
	linear_speed_max #: float,
#	_target #: Spatial)
	)
	
	priority.add(follow_blend)


func _physics_process(delta):
	priority.calculate_steering(accel)
	
	if Input.is_action_pressed("LMBClick"):
		allow_move = true
	if Input.is_action_just_released("LMBClick"):
		allow_move = false
	# could put inside if LMB_pressed above
	if allow_move == true:
		agent._apply_steering(accel, delta)



func _unhandled_input(event):
	if Input.is_action_just_pressed("RMBClick"):
		# get move to coordinates from mouse click position
		var from = get_parent().get_node("Cam").project_ray_origin(event.position)#*100
		var to = from + get_parent().get_node("Cam").project_ray_normal(event.position)*100
		print ("From : ", from, " and To : ", to)
		var space_state = get_world().direct_space_state
		var result = space_state.intersect_ray(from, to, [self], collision_mask)
		print ("RESULT : ", result.position)
		
		calc_a_path(result.position)
	

func calc_a_path(res_pos):
	# path calculate stuff
	amap_path = amap.calc_path(self.global_transform.origin, res_pos)
	amap_path_ind = 0
	if amap_path.size() > 2:
		path.create_path(amap_path)
		_valid = true
		follow_blend.is_enabled = true
		print(" AMAP path: ", amap_path)
		print(" path: ", path)
	else:
		follow_blend.is_enabled = false
		_valid = false


func setup(
	align_tolerance, #: float,
	angular_deceleration_radius, #: float,
	angular_accel_max, #: float,
	angular_speed_max, #: float,
	deceleration_radius, #: float,
	arrival_tolerance, #: float,
	linear_acceleration_max, #: float,
	linear_speed_max #: float,
#	_target #: Spatial
) -> void:
	agent.linear_speed_max = linear_speed_max
	agent.linear_acceleration_max = linear_acceleration_max
	agent.linear_drag_percentage = 0.05
	agent.angular_acceleration_max = angular_accel_max
	agent.angular_speed_max = angular_speed_max
	agent.angular_drag_percentage = 0.1
	
	follow.path_offset = 1.0#path_offset
	follow.prediction_time = 1.5#predict_time
	
	blend.is_enabled = true
	
	follow_blend.add(follow, 1)
	follow_blend.add(look, 1)
	follow_blend.is_enabled = false
	



