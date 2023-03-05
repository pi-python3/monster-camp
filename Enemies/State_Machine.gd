extends KinematicBody2D;

signal state_changed(current_state);
signal hit(current_health);
signal die(object);
signal remove_target_points();

export(NodePath) var START_STATE;
const MAX_STACK_SIZE = 3;

export(bool) var controlled = false;
var motion = Vector2(0,0);
var speed = 0.0;
var hit_stats = [];
var invincible := false;
var can_attack = true;
var attack_direction := Vector2(0,0);
var can_push := true;
var protected_from = [];
var can_hit_detect := true;

export(String) var monster_type = 'boko';

onready var base_stats = {
	'health': get_monster_stat(monster_type, 'health'),
	'damage': get_monster_stat(monster_type, 'damage'),
	'move_speed': 0,
	'attack_recharge': get_monster_stat(monster_type, 'attack_recharge')
};

onready var health = base_stats['health'];
onready var damage = base_stats['damage'];


var has_foot_hitbox = get_node_or_null("Foot_Hitbox") != null;

var cart;
var stick_target;


func get_monster_stat(monster_name: String, stat_name: String):
	return Game_Balance.monster_data.get(monster_name)[stat_name];


#refers state to a string
onready var states_map = {
	"idle": $States/Idle,
	"move": $States/Move,
	"ai_run": $States/AI_Run,
	"attack": $States/Attack,
	"hit": $States/Hit,
	"die" : $States/Die
}

#list of most current states
var states_stack = [];
var current_state = null;

var active = false setget set_active;


func _ready():
	add_to_group(name);
	
	if get_node_or_null("States/Move") != null:
		base_stats['move_speed'] = $States/Move.MAX_MOVESPEED;
	if get_node_or_null("UI") != null:
		$UI.stamina_bar['recharge_time'] = base_stats['attack_recharge'];

	if monster_type == "peapo": states_map["aim"] = $States/Aim;
	
	elif monster_type == "bombo":
		states_map["stick"] = $States/Stick;
		states_map["explode"] = $States/Explode;
	
	elif monster_type == "drillgi":
		states_map["burrow"] = $States/Burrow;
	
	$Components.setup_components();
	
	for child in $States.get_children():
		child.connect("finished", self, "_change_state");
	
	initialize(START_STATE);


func initialize(start_state):
	set_active(true);
	states_stack.push_front(get_node(start_state)); #add to front of stack
	current_state = states_stack[0];
	current_state.enter();


func set_active(value):
	active = value;
	set_physics_process(value);
	set_process_input(value);
	if not active:
		states_stack = [];
		current_state = null;


#func _input(event):
#	pass;


func _physics_process(delta):
	if current_state is KinematicBody2D:
		current_state.update();
	else:
		current_state.update(delta);
	
	hit_detection();
	update_global_vars();
	
	$Components.update_components(delta);
	
	if health <= 0 && (not current_state.name in ["Hit", "Die"] && !current_state.is_in_group("No_Death_State")):
		print("death")
		current_state.emit_signal("finished", "die");


func _on_animation_finished(anim_name):
	if not active: return;
	current_state._on_animation_finished(anim_name);


func _change_state(state_name):
	if not active: return;
	
	current_state.exit();
	
	if state_name == "previous":
		states_stack.pop_front(); #delete first item in list to return to previous state
	else:
		if states_stack.size() == MAX_STACK_SIZE: states_stack.pop_back();
		states_stack.push_front(states_map[state_name]);
#		states_stack[0] = states_map[state_name];
	
	current_state = states_stack[0];
#	Player_Vars.current_state = current_state.name.to_lower();
	emit_signal("state_changed", current_state);
	
#	if state_name != "previous":
	current_state.enter();


func is_state_active(st: String) -> bool:
	return get_node_or_null("States/" + st) != null && current_state == get_node_or_null("States/" + st);


func update_global_vars():
	var stack = [];
	for s in states_stack:
		stack.append(s.name);
	Monster_Vars.states_stack = stack;


#func carted(target_cart):
#	cart = target_cart;
#	current_state.emit_signal("finished", "carted");


func hit_detection():
	if current_state.name in ["Hit","Die"] || invincible:
		can_hit_detect = false;
		return;
	can_hit_detect = true;
	
	for collider in $Hitbox.get_overlapping_areas():
		if collider.is_in_group("Hero_Hitbox"):
			hit(collider.owner);
			return;
		
		elif collider.is_in_group("Universal_Hitbox"):
			if collider.owner in protected_from: continue;
			else:
				hit(collider.owner);
				return;
		
#		elif collider.is_in_group("Pickup_Hitbox") && is_in_group("Cartable"):
#			if collider.owner in protected_from: continue;
#			if collider.owner.pickup(self):
#				return;


func hit(source):
	invincible = true;
	hit_stats = Hit_Manager.get_hit_data(self, source);
	
	if controlled:
		Global_Camera.shake("medium");
		Global_Camera.freeze_frame("medium");
	else:
		Global_Camera.shake("small");
		Global_Camera.freeze_frame("small");
	
	Global_Effects.circle_hit(position); # + hit_stats['hit_strength']*$States/Hit.hit_move/(8*scale.x));
	
	health -= hit_stats['damage'];
	emit_signal("hit", health);
	current_state.emit_signal("finished", "hit");
