extends Position2D

var wait = 0;
var weak_preview_monster;
var input_direction := Vector2(0,0);
onready var sprite = $CanvasLayer/Sprite;

func _ready():
	wait = 0;
	weak_preview_monster = weakref(Monster_Vars.controlled_monster);
	sprite.visible = false;


func _physics_process(_delta):
	wait += 1;
	if wait < 5 || Monster_Vars.monsters.size() <= 1:
		sprite.visible = false;
		return;
	
	input_direction = get_input_direction();
	if input_direction == Vector2.ZERO:
		var m_index = Monster_Vars.m_index;
		if m_index + 1 >= Monster_Vars.monsters.size(): m_index = 0;
		else: m_index += 1;
		
		weak_preview_monster = weakref(Monster_Vars.monsters[m_index]);
		_change_monster();
	else:
		change_input_direction(input_direction);
	
	$CanvasLayer/Sprite.global_position = global_position;
	
	if weak_preview_monster.get_ref() != null && Monster_Vars.monsters.size() > 0:
		position = weak_preview_monster.get_ref().position;
		sprite.visible = true;
	else:
		sprite.visible = false;
	
	if Monster_Vars.lose_game: 
#		return;
		sprite.visible = false;


func _change_monster():
	if Monster_Vars.lose_game: return;
	position = weak_preview_monster.get_ref().global_position;


func change_input_direction(input_dir: Vector2):
	weak_preview_monster = weakref(find_switch_monster(input_dir));
	_change_monster();


func get_input_direction() -> Vector2:
	var input_dir = Vector2();
	input_dir.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"));
	input_dir.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"));

	return input_dir;


func find_switch_monster(input_direc: Vector2):
	var max_distance = 999;
	var input_dir = input_direc.normalized();
	var best_candidate;
	var m_index = Monster_Vars.m_index;
	var controlled_monster = Monster_Vars.controlled_monster;
	
	if m_index + 1 >= Monster_Vars.monsters.size(): m_index = 0;
	else: m_index += 1;
	best_candidate = Monster_Vars.monsters[m_index];
	
	for m in Monster_Vars.monsters:
		if m == controlled_monster: continue;
		
		var dir_to_m = (m.position - controlled_monster.position).normalized();
		var dis_to_m = max_distance - (m.position - controlled_monster.position).length(); #distance inversed
		
		var dir_to_best = (best_candidate.position - controlled_monster.position).normalized();
		var dis_to_best = max_distance - (best_candidate.position - controlled_monster.position).length(); #distance inversed

		if input_dir.dot(dir_to_m) * dis_to_m > input_dir.dot(dir_to_best) * dis_to_best:
			best_candidate = m;
	
	return best_candidate;
