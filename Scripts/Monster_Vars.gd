extends Node

signal change_monster

var monsters = [];
var m_index := 0;
var controlled_monster = null;
var switch_monster;
var states_stack = [];
var lose_game := false;
var wait_to_load := true;
var control_arrow;

var wait := 0;


func _ready():
	process_priority = 2;
	Level_Handler.connect("new_level", self, "_new_level");
	Level_Handler.connect("changing_level", self, "_changing_level");
	set_physics_process(false);
	
	if "Level_" in get_tree().current_scene.filename:
		level_reset();


func _physics_process(_delta):
	if wait < 2:
		wait += 1;
	elif "Level_" in get_tree().current_scene.filename:
		level_reset();
		set_physics_process(false);


func level_reset():
	if wait < 2:
		set_physics_process(true);
		return;
	wait = 0;
	
	monsters = [];
	m_index = 0;
	controlled_monster = null;
	lose_game = false;
	var monsters_node = get_node_or_null("/root/Game/Environment/Monsters");
	
	if monsters_node == null: return;
	
	for monster in monsters_node.get_children():
		monsters.append(monster);
		if !monster.is_connected("die", self, "_kill_monster"):
			monster.connect("die", self, "_kill_monster");

	control_monster(monsters[0]); #set first monster in list to be controlled

	control_arrow = weakref(get_node_or_null("/root/Game/Control_Arrow"));


func _process(_delta):
	if monsters.size() == 0 && !wait_to_load:
		lose_game = true;
#		Level_Handler.level_over("lose");
	
	if !lose_game:
		if Input.is_action_just_pressed("switch"):
			if control_arrow.get_ref() != null:
				if !control_arrow.get_ref().changing:
					switch_control();
			
			else:
				switch_control();


func switch_control():
	if monsters.size() <= 1 && m_index == 0: return;
	if m_index < monsters.size(): monsters[m_index].controlled = false;
	
	var input_dir = get_input_direction();
	
	if input_dir == Vector2.ZERO:
		if m_index + 1 >= monsters.size(): m_index = 0;
		else: m_index += 1;
	else:
		m_index = monsters.find(find_switch_monster(input_dir));
	
	control_monster(monsters[m_index]);


func find_switch_monster(input_direction: Vector2):
	var max_distance = 999;
	var input_dir = input_direction.normalized();
	var best_candidate;
	
	if m_index + 1 >= monsters.size(): m_index = 0;
	else: m_index += 1;
	best_candidate = monsters[m_index];
	
	for m in monsters:
		if m == controlled_monster: continue;
		
		var dir_to_m = (m.position - controlled_monster.position).normalized();
		var dis_to_m = max_distance - (m.position - controlled_monster.position).length(); #distance inversed
		
		var dir_to_best = (best_candidate.position - controlled_monster.position).normalized();
		var dis_to_best = max_distance - (best_candidate.position - controlled_monster.position).length(); #distance inversed

		if input_dir.dot(dir_to_m) * dis_to_m > input_dir.dot(dir_to_best) * dis_to_best:
			best_candidate = m;
	
	return best_candidate;


func control_monster(monster: Node):
	monster.controlled = true;
	controlled_monster = monster;
	emit_signal("change_monster");


func _kill_monster(monster):
	if monsters.size() <= 1:
		game_over();
	
	elif monster == controlled_monster:
		switch_control();
	
	monsters.erase(monster);
	m_index = monsters.find(controlled_monster); #reset the index after list change
	
	if monster == Hero_Vars.revenge_target:
		Hero_Vars.revenge_target = null;
	
	monster.disconnect("die", self, "_kill_monster");


func get_input_direction() -> Vector2:
	var input_dir = Vector2();
	input_dir.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"));
	input_dir.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"));
	return input_dir;


func _new_level(_level):
	wait_to_load = false;
	level_reset();


func _changing_level():
	wait_to_load = true;
	monsters = [];
	m_index = 0;
	controlled_monster = null;


func game_over():
	Level_Handler.level_over("lose");
