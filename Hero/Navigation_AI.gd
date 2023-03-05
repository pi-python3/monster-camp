extends KinematicBody2D

class_name AI, "res://Meta/AI_Icon.png"

var directions = {
	"left" : Vector2.LEFT,
	"right" : Vector2.RIGHT,
	"down" : Vector2.DOWN,
	"up" : Vector2.UP,
	"up_left" : Vector2.LEFT + Vector2.UP,
	"up_right" : Vector2.RIGHT + Vector2.UP,
	"down_left" : Vector2.LEFT + Vector2.DOWN,
	"down_right" : Vector2.RIGHT + Vector2.DOWN,
	"22.5": deg2vec(22.5),
	"67.5": deg2vec(67.5),
	"112.5": deg2vec(112.5),
	"157.5": deg2vec(157.5),
	"202.5": deg2vec(202.5),
	"247.5": deg2vec(247.5),
	"292.5": deg2vec(292.5),
	"337.5": deg2vec(337.5)
};

onready var navigation = get_node_or_null("/root/Game/Navigation2D");


func deg2vec(deg: float) -> Vector2:
	return Vector2( cos(deg2rad(deg)), sin(deg2rad(deg)) ).normalized();


#func check_sight(target, emitter, pos):
#	var space_state = get_world_2d().direct_space_state #creates a paused physics world
#	var targetCenter = Vector2(target.position.x , target.position.y)
#	var centerPos = Vector2(pos.x, pos.y)
#	var result = space_state.intersect_ray(centerPos, targetCenter, [emitter], collision_mask)
#
#	if result: 
#		if result.collider.name == "Player":
#			return [true, targetCenter];
#
#	return [false, targetCenter];


func create_path(hero_pos: Vector2, end_pos: Vector2) -> PoolVector2Array:
	#get path from hero to destination
	return navigation.get_simple_path(hero_pos, end_pos, false);


func move_toward_point(hero_position: Vector2, target_position: Vector2, move_speed: float, motion: Vector2):
	var path = create_path(hero_position, target_position);

#	if path.size() == 1: return seek(hero_position, target_position, move_speed)/2;
	if path.size() < 1:
#		away_dir = away_dir.rotated(PI/2);
		return seek(hero_position, target_position, move_speed);
#		return (seek(hero_position, target_position, move_speed) + away_dir).normalized()*move_speed;
	
	var to_point = Vector2(path[1].x, path[1].y);
#	var desired = steer(to_point - hero_position, motion, 1) * move_speed;
	var desired = seek(hero_position, to_point, move_speed);
	
	var away_dir: Vector2 = avoid_all_objects(hero_position, hero_position + (to_point - hero_position).normalized()*120, 120) * 5000;
#	away_dir *= -1;
	
#	if away_dir.rotated(PI/3).dot(desired) > away_dir.rotated(-PI/3).dot(desired):
	away_dir = away_dir.rotated(PI/2);
#	else:
#		away_dir = away_dir.rotated(-PI/3);
#	print(away_dir)
	desired = (desired + away_dir).normalized() * move_speed;
	desired = steer(desired, motion, 5).normalized() * move_speed;
	return desired;

#	motion.x = move_speed * sign(to_point.x - pos.x);
#	motion.y = move_speed * sign(to_point.y - pos.y);
	
#	if pos.x < to_point.x: #has to move to the right
#		motion.x = clamp(move_speed, move_speed, to_point.x - pos.x);
#
#	elif pos.x > to_point.x: #has to move to the left
#		motion.x = clamp(motion.x, to_point.x - pos.x, -move_speed);
#
#	if pos.y < to_point.y: 
#		motion.y = clamp(motion.y, move_speed, to_point.y - pos.y);
#
#	elif pos.y > to_point.y:
#		motion.y = clamp(motion.y, to_point.y - pos.y, -move_speed);
#
#	if motion.x != 0 && motion.y != 0: #if moving diagonally
#		motion /= sqrt(2); #decrease speed to move speed
#
#	var new_path = path;
#	if pos + motion == to_point: new_path.remove(0);
#
#	return [pos, motion, new_path];
func avoid_all_objects(hero_position: Vector2, target_position: Vector2, avoid_radius):
	var objects = get_tree().root.get_node("Game/Environment/Objects");
	
	var sum := Vector2.ZERO;
	var count = 0;
	for obj in objects.get_children():
		var motion = avoid(hero_position, obj.global_position, avoid_radius);
		if motion != Vector2.ZERO:
			if close_in_direction(hero_position, target_position, obj.global_position, 0.8):
#			if circle_cast(hero_position, target_position, obj.global_position, 40, 10):
				sum += motion;
				count += 1;
	
	if count > 0:
		sum /= count;
		
	return sum;


func close_in_direction(from_pos: Vector2, to_pos: Vector2, hit_pos: Vector2, dot_min: float) -> bool:
	var vecA = (to_pos - from_pos).normalized();
	var vecB = (hit_pos - from_pos).normalized();
	var dot_result = vecA.dot(vecB);
	return dot_result >= dot_min;


func circle_cast(from_pos: Vector2, to_pos: Vector2, hit_pos: Vector2, radius: float, checks: int):
	for i in range(checks + 1):
		var check_pos = lerp(from_pos,to_pos, (1.0/float(checks)) * i);
		var distance = check_pos.distance_to(hit_pos)
		if distance <= radius:
			print("hit!")
			
			return true;
	
	return false;


func combine_steering_behaviours(avoid_params = false, avoid_weight = 1, seek_params = false, seek_weight = 1) -> Vector2:
	#avoid params = [hero_position, target_position, ray_length, move_speed, avoid_radius, space_state, _collision_mask line_visual]
	#seek_params = [hero_position, target_position, move_speed, arrive_radius];
	var count = 0;
	var sum = Vector2.ZERO;
	
	if avoid_params: 
		count += 1;
		sum += avoid_in_all_directions(avoid_params[0], avoid_params[2], avoid_params[3], avoid_params[4], avoid_params[5], avoid_params[6], avoid_params[7]) * avoid_weight;
	if seek_params: 
		count += 1;
		sum += seek(seek_params[0], seek_params[1], seek_params[2], seek_params[3]) * seek_weight;
	
	if count > 0: sum /= count;
	
	var desired = sum;
	return desired;


func steer(desired_motion: Vector2, current_motion: Vector2, steer_strength: float) -> Vector2:
	var steer = desired_motion - current_motion;
	steer = steer.limit_length(steer_strength);
	return current_motion + steer;


func seek(hero_position: Vector2, target_position: Vector2, move_speed: float, arrive_radius: float = 0) -> Vector2:
	var desired = target_position - hero_position;

	if arrive_radius != 0:
		var distance = desired.length();
		if distance < arrive_radius:
			desired = set_length(desired, (distance/arrive_radius) * move_speed);
			return desired;

	desired = set_length(desired, move_speed);
	return desired;


func set_length(vector: Vector2, length: float) -> Vector2:
	return vector.normalized() * length;


func avoid_in_all_directions(hero_position: Vector2, ray_length: float, move_speed: float, avoid_radius:float, space_state, _collision_mask, line_visual: Line2D = null):
	var sum = Vector2.ZERO;
	var count = 0;

	for direction in directions.keys():
		var result = create_ray_dir(hero_position, direction, ray_length, space_state, _collision_mask, line_visual);
		if result:
			sum += avoid(hero_position, result.position, avoid_radius);
			count += 1;
	#average
	if count > 0:
		sum /= count;
		sum = set_length(sum, move_speed);

		return sum;
	return Vector2.ZERO;


func avoid(hero_position: Vector2, target_position: Vector2, avoid_radius: float):
	var desired = hero_position - target_position; #directly away from target

	var distance = desired.length();
	if distance < avoid_radius:
		desired = desired.normalized() / distance;
		return desired;
	return Vector2.ZERO;


func avoid_targets(hero_position: Vector2, target_positions: Array, avoid_radius: float, move_speed: float):
	var sum = Vector2.ZERO;
	var count = 0;
	for target_position in target_positions:
		var avoid;
		if count == 0: avoid = avoid(hero_position, target_position, avoid_radius);
		else: avoid = avoid(hero_position, target_position, avoid_radius/2);
		if avoid != Vector2.ZERO:
			count += 1;
		sum += avoid;
	
	count = clamp(count, 1, 100);
	sum /= count;
	sum = set_length(sum, move_speed);
	return sum;


func create_ray(hero_position: Vector2, target_position: Vector2, space_state, _collision_mask, line_visual: Line2D = null):
	#exclude self and all hitboxes from raycast
	var exclusions = [self];
	for child in owner.get_children():
		if child.is_in_group("Hitboxes"): exclusions.append(child);
	
	var result = space_state.intersect_ray(hero_position, target_position, exclusions, collision_mask, true,true);
	if result:
		if line_visual:
			line_visual.add_point(hero_position);
			line_visual.add_point(result.position);
		return result;
	return null;


func create_ray_dir(hero_position: Vector2, direction: String, ray_lenth: float, space_state, _collision_mask, line_visual: Line2D = null):
	var target_position = (directions[direction] * ray_lenth) + hero_position;
	return create_ray(hero_position, target_position, space_state, _collision_mask, line_visual);


func get_attack_input() -> bool:
	if !owner.can_attack: return false;
	var attack = Input.is_action_just_pressed("attack");
	return attack;


var nav_tiles;
var astar_tiles;

func _ready():
	if navigation != null:
		nav_tiles = navigation.get_node_or_null("Navigation_Tiles");
	astar_tiles = get_tree().root.get_node_or_null("Game/AStar_Tiles");


func find_path(start_pos: Vector2, target_pos: Vector2):
	if start_pos.distance_to(target_pos) <= 150:
		return [start_pos + (target_pos - start_pos)];
	
	if start_pos == Vector2(NAN, NAN) || target_pos == Vector2(NAN, NAN): return null
	
	if nav_tiles == null:
		print("NO REFERENCE TO NAV TILES!");
		return;
		
#	print("looking for path...");
	
	var open_set = [];
	var closed_set = [];
	
	var start_map_pos = world_to_grid(start_pos);
	var end_map_pos = world_to_grid(target_pos);

	var start_node = nav_tiles.path_nodes[start_map_pos];
	var end_node = nav_tiles.path_nodes[end_map_pos];
	
	if !end_node.traversable:
		for y in range(3):
			if end_node.traversable: break;
			for x in range(3):
				var offset = Vector2(x - 1, y - 1);
				if offset == Vector2.ZERO: continue;
				
				end_node = nav_tiles.path_nodes[end_map_pos + offset];
				if end_node.traversable: break;
	
	if !end_node.traversable: return null;
	
	
	open_set.append(start_node);
	
	while open_set.size() > 0:
		draw_astar(open_set, closed_set);
		
		var current = open_set[0];
		for node in open_set:
			if node == open_set[0]: continue;
			
			if node.get_f_cost() < current.get_f_cost() || (node.get_f_cost() == current.get_f_cost() && node.h_cost < current.h_cost):
				current = node;
		
		open_set.erase(current);
		closed_set.append(current);
		
		if current == end_node:
#			print("PATH FOUND!");
			return retrace_path(start_node, end_node);
		
		for n in nav_tiles.get_neighbours(current):
			if !n.traversable || n in closed_set: continue;
			
			var new_move_cost = int(current.g_cost + get_distance(current, n));
			
			if new_move_cost < n.g_cost || not (n in open_set):
				n.g_cost = new_move_cost;
				n.h_cost = get_distance(n, end_node);
				n.parent = current;
				
				if not n in open_set:
					open_set.append(n);
	return null;
#	print("NO path found :(");


func world_to_grid(pos: Vector2) -> Vector2:
	var grid_pos = (pos - Vector2(20,20)) / 20;
	grid_pos = Vector2(round(grid_pos.x), round(grid_pos.y));
	return grid_pos;

func grid_to_world(grid_pos: Vector2) -> Vector2:
	return (grid_pos * 20) + Vector2(20,20);


func get_distance(nodeA, nodeB) -> int:
	var disX = abs(nodeB.pos.x - nodeA.pos.x)
	var disY = abs(nodeB.pos.y - nodeA.pos.y);
	
	if disX > disY:
		return (14 * disY) + 10*(disX - disY);
	
	return (14 * disX) + 10*(disY - disX);


func retrace_path(start_node, end_node):
	var path := [];
	var current = end_node;
	
	while current != start_node:
		path.append(grid_to_world(current.pos));
		current = current.parent;
	
	path.invert();
	return path;


func draw_astar(open_set, closed_set):
	if astar_tiles == null: return;
	
	astar_tiles.clear();
	
	for node in open_set:
		astar_tiles.set_cell(node.pos.x, node.pos.y, 4, false, false, false, Vector2(0,0));
	
	for node in closed_set:
		astar_tiles.set_cell(node.pos.x, node.pos.y, 4, false, false, false, Vector2(1,0));
	
