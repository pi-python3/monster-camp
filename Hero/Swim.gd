extends "Hero_State.gd"

signal lose_stamina(amount);

const MOVE_SHADER = "res://Shaders/Move.tres";

onready var SWIM_SPEED = owner.MAX_MOVE_SPEED * 0.5;
var previous_motion = Vector2.ZERO;
var target_pos: Vector2;
var delta = 0;


func enter():
	owner.get_node("Sprite/Animation").play("Move");
	owner.get_node("Sprite_Handler").change_shader(MOVE_SHADER);
	owner.get_node("Sprite").frame = 0;
	owner.get_node("Water_Effect").show();
	target_pos = get_ground_pos();


func exit():
	owner.get_node("Sprite/Animation").stop();
	owner.get_node("Sprite").rotation_degrees = 0;
	owner.get_node("Sprite_Handler").clear_shader();
	owner.get_node("Water_Effect").hide();
	
	emit_signal("lose_stamina", 3);


func update():
	move();
	animate();
	check_in_water();


func move():
	owner.motion = (target_pos - owner.global_position).normalized() * SWIM_SPEED;

	if $Switch_Direction_Timer.is_stopped():
		if sign(previous_motion.x) != sign(owner.motion.x):
			$Switch_Direction_Timer.start();
			previous_motion = owner.motion;
		else:
			owner.position += owner.motion * delta;
#			owner.move_and_slide(owner.motion);
			previous_motion = owner.motion;
	else:
		owner.position += previous_motion * delta;
#		owner.move_and_slide(previous_motion);


func animate():
	owner.get_node("Sprite").set_flip(owner.motion.x < 0);
	$Line2D.clear_points();
	$Line2D.add_point(owner.global_position);
	$Line2D.add_point(target_pos);
#	owner.get_node("Move_Particles").process_material.direction = Vector3(-owner.motion.x, -owner.motion.y, 0);


func check_in_water():
#	if owner.global_position.distance_to(target_pos) < 30:
	if !owner.check_in_water():
		emit_signal("finished", "move");


func get_ground_pos():
	var max_distance = 999999;
	var tile_pos = nav_tiles.world_to_map(owner.global_position)/5;
	var to_pos := Vector2.ZERO;
	
	var close_tile;
	for tile in nav_tiles.get_used_cells_by_id(0):
		if nav_tiles.get_cell_autotile_coord(tile.x, tile.y) == nav_tiles.tile_types["green"]: #if tile is a navigable tile
			var tile_center_pos = nav_tiles.map_to_world(tile)*5 + Vector2(20,20); #get the center of the ground tile
			var distance = tile_pos.distance_to(tile);
			
			if distance < max_distance:
				max_distance = distance;
				to_pos = tile_center_pos;
				close_tile = tile;
	
	return to_pos;


func _process(_delta):
	delta = _delta;
