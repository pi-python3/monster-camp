extends Node

signal new_level(level);
signal changing_level;
signal level_over(state);
signal menu_open;

var level = 0;
const MAX_LEVELS := 17;
enum LEVEL_STATE {NONE = 0, WIN = 1, LOSE = 2};
var level_state = LEVEL_STATE.NONE;


func _ready():
	set_process(false);


func load_level_select_menu():
	get_tree().change_scene("res://Main_Scenes/Select_Level.tscn");
	emit_signal("menu_open");


func load_home_menu():
	get_tree().change_scene("res://Main_Scenes/Home.tscn");
	emit_signal("menu_open");


func get_current_level():
	var file = get_tree().current_scene.filename;
	var level_num = file.trim_prefix("res://Main_Scenes/Level_").trim_suffix(".tscn");
	if level_num.is_valid_integer():
		return int(level_num);
	
	return 0;


func first_level():
	load_level(0);


func next_level(transition := true):
	load_level(get_current_level() + 1, transition);


func load_level(lvl: int, transition := true):
	level_state = LEVEL_STATE.NONE;
	emit_signal("changing_level");
	level = lvl;
	if transition: yield(Scene_Transition,"transition_close_end");
	get_tree().change_scene("res://Main_Scenes/Level_" + str(lvl) + ".tscn");
	set_process(true);


func _process(_delta):
	if level == get_current_level():
		_level_loaded();
		set_process(false);


func _level_loaded():
	level = get_current_level();
	emit_signal("new_level", get_current_level());


func level_over(state):
	if state == "win":
		level_state = LEVEL_STATE.WIN;
		Game_Data.unlock_level();
	
	elif state == "lose": level_state = LEVEL_STATE.LOSE;
	
	emit_signal("level_over", state);


func restart_level():
	if "Level_" in get_tree().current_scene.filename:
		load_level(get_current_level());
	else:
		get_tree().change_scene(get_tree().current_scene.filename)


func _input(event):
	if !OS.is_debug_build(): return;
	
	if event.is_action_pressed("skip_level"):
		if level == MAX_LEVELS - 1:
			load_home_menu();
		else:
			next_level(false);
	
	elif event.is_action_pressed("previous_level"):
		if level == 0:
			load_home_menu()
#			get_tree().change_scene("res://Main_Scenes/Home.tscn");
#			emit_signal("changing_level");
		
		else:
			load_level(get_current_level() - 1, false);
