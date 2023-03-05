extends KinematicBody2D;

signal state_changed(current_state);

export(NodePath) var START_STATE;
const MAX_STACK_SIZE = 3;

#onready var audio_player = $Audio_Player;

#export(int) var controller = 1;
var invincible = false;
var hit_dir;
var hit_stats = {};

#refers state to a string
onready var states_map = {
	"idle": $States/Idle,
	"hit" : $States/Hit
}

#list of most current states
var states_stack = [];
var current_state = null;

var active = false setget set_active;

func _ready():
#	get_viewport().audio_listener_enable_2d = true
#	Player_Vars.player = self;
	
	for child in $States.get_children():
		child.connect("finished", self, "_change_state");
	initialize(START_STATE);
	
#	$Animation.connect("animation_finished", self, "_on_animation_finished");


func initialize(start_state):
	set_active(true);
	states_stack.push_front(get_node(start_state)); #add to front of stack
	current_state = states_stack[0];
#	Player_Vars.current_state = current_state.name.to_lower();
	current_state.enter();


func set_active(value):
	active = value
	set_physics_process(value)
	set_process_input(value)
	if not active:
		states_stack = []
		current_state = null


func _input(event):
	pass;
#	current_state.handle_input(event);

func _physics_process(delta):
	current_state.update();
	hit_detection();


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


func hit_detection():
	if current_state.name == "Hit" || invincible: return;
	
	for collider in $Hitbox.get_overlapping_areas():
		if collider.is_in_group("Monster_Hitbox"):
			hit(collider.owner);
			return;


func hit(source):
	hit_stats = Hit_Manager.get_hit_data(self, source, true);
	Combo_Manager.add_hit(self, source, hit_stats['damage'], hit_stats['hit_strength'].x);
	
	invincible = true;
	Global_Camera.shake("small");
	current_state.emit_signal("finished", "hit");
	Global_Effects.circle_hit(position - Vector2(20,0));
