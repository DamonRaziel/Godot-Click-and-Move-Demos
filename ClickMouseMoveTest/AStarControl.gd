extends Spatial

# AStar, Unit and Camera code based on codes from Miziziziz

var all_points = {}
var astar = null
onready var gridmap = $AStarGridMap

func _ready():
	astar = AStar.new()
#	var points_got = astar.get_points()
#	print ("Points Got : ", points_got)
	var cells = gridmap.get_used_cells()
	for cell in cells:
		var ind = astar.get_available_point_id()
		astar.add_point(ind, gridmap.map_to_world(cell.x, cell.y, cell.z))
		all_points[v3_to_index(cell)] = ind
	for cell in cells:
		for x in [-1, 0, 1]:
			for y in [-1, 0, 1]:
				for z in [-1, 0, 1]:
					var v3 = Vector3(x, y, z)
					if v3 == Vector3(0, 0, 0):
						continue
					if v3_to_index(v3 + cell) in all_points:
						var ind1 = all_points[v3_to_index(cell)]
						var ind2 = all_points[v3_to_index(cell + v3)]
						if !astar.are_points_connected(ind1, ind2):
						#if points are not connected >>
							astar.connect_points(ind1, ind2, true)
							# >> connect them
							# check for areas covered here?
							# and only connect if not covered
							# and if covered, add disconnect code to make sure
#	var points_got = astar.get_points()
#	print ("Points Got : ", points_got)
# code similar to above, but check for points which are covered by building and terrain
# areas, and disconnect them as needed, and rechecker code for when buildings are destroyed
 



func v3_to_index(v3):
	return str(int(round(v3.x))) + "," + str(int(round(v3.y))) + "," + str(int(round(v3.z)))
   


#var start = Vector3()
#var end = Vector3()
func calc_path(start, end):
#func get_path(start, end):
# renamed as calc_path, so not overriding parent get_path func
# as trying to override parent func causes some issues
	
	var gm_start = v3_to_index(gridmap.world_to_map(start)) #self pos
	var gm_end = v3_to_index(gridmap.world_to_map(end)) # target pos
	var start_id = 0
	var end_id = 0
	if gm_start in all_points:
		start_id = all_points[gm_start]
	else:
		start_id = astar.get_closest_point(start)
   
	if gm_end in all_points:
		end_id = all_points[gm_end]
	else:
		end_id = astar.get_closest_point(end)
   
	return astar.get_point_path(start_id, end_id)

#var points_disable_enable = []

func disable_astar_points_here(points_to_disable):
#	points_disable_enable = points_to_disable
	var number_of_points_to_disable = points_to_disable.size()
	print ("number of points to disable : ", number_of_points_to_disable)
	for each_point in number_of_points_to_disable:
		var disabling_point
		disabling_point = astar.get_closest_point(points_to_disable[each_point])
		print ("points to disable : ", disabling_point)
		disabling_point = astar.set_point_disabled(disabling_point, true)

func reenable_astar_points(points_to_enable):
	var number_of_points_to_enable = points_to_enable.size()
	print ("number of points to enable again : ", number_of_points_to_enable)
	for each_point in number_of_points_to_enable:
		var enabling_point
		enabling_point = astar.get_closest_point(points_to_enable[each_point], true)
		print ("points to enable again : ", enabling_point)
		enabling_point = astar.set_point_disabled(enabling_point, false)


func calc_chase_path(start, end):
#func get_path(start, end):
# renamed as calc_path, so not overriding parent get_path func
# as trying to override parent func causes some issues
	
	var gm_start = v3_to_index(gridmap.world_to_map(start)) #self pos
	var gm_end = v3_to_index(gridmap.world_to_map(end)) # target pos
	var start_id = 0
	var end_id = 0
	if gm_start in all_points:
		start_id = all_points[gm_start]
	else:
		start_id = astar.get_closest_point(start)
   
	if gm_end in all_points:
		if astar.is_point_disabled(all_points[gm_end]):
			gm_end = astar.get_closest_point(end)
			print ("closest point22222222 was : ", gm_end)
		else:
			end_id = all_points[gm_end]
			print ("closest point22222222 was : ", end_id)
		
	else:
		end_id = astar.get_closest_point(end)
		print ("closest point was : ", end_id)
   
	return astar.get_point_path(start_id, end_id)



func get_points_path(start, end):
	var start_p = astar.get_closest_point(start)
	var end_p = astar.get_closest_point(end)
	var points_path_was = astar.get_point_path(start_p, end_p)
	return points_path_was

#var temp_points_diable = []
#func disable_points(area_to_disable):
##	astar.get_points()
#	for points in area_to_disable:
#		temp_points_diable = astar.get_points()
#		astar.set_point_disabled(temp_points_diable)

func get_closest_placement_point(mouse_pos):
	return astar.get_closest_point(mouse_pos)

func check_neighbouring_astar_point(point_to_check):
	return astar.get_closest_point(point_to_check)


func clear_this_units_path(unit_pos):
	# how to clear a path already made??
	var point_unit_is_at_to_disable = unit_pos
	var unit_disabling_point
	unit_disabling_point = astar.get_closest_point(point_unit_is_at_to_disable)
	print ("points to disable because a unit is here : ", unit_disabling_point)
	unit_disabling_point = astar.set_point_disabled(unit_disabling_point, true)

func reenable_point_unit_was_at(unit_pos):
	print ("GOT HERE")
	var point_unit_is_at_to_enable = unit_pos
	var unit_enabling_point
	unit_enabling_point = astar.get_closest_point(point_unit_is_at_to_enable, true)
	print ("points to disable because a unit is here : ", unit_enabling_point)
	unit_enabling_point = astar.set_point_disabled(unit_enabling_point, false)

#func reweight_point_temp(point_pos_to_rewieght):
#	var point_to_reweight  = point_pos_to_rewieght
#	var weighting_point
#	weighting_point = astar.get_closest_point(point_to_reweight)
#	weighting_point = astar.set_point_weight_scale(weighting_point, 100)
#
#func reweight_to_one(point_toReweight_to_one):
#	var point_to_reweight_one  = point_toReweight_to_one
#	var weighting_point_one
#	weighting_point_one = astar.get_closest_point(point_to_reweight_one, true)
#	weighting_point_one = astar.set_point_weight_scale(weighting_point_one, 1)


