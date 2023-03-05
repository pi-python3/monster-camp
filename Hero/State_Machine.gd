extends KinematicBody2D;

signal state_changed(current_state);
signal hit(current_health);

export(NodePath) var START_STATE;
const MAX_STACK_SIZE = 3;

#onready var audio_player = $Audio_Player;

#export(int) var controller = 1;
var motion = Vector2(0,0);
export(float) var MAX_MOVE_SPEED = 100;
var move_speed = 10;#MAX_MOVE_SPEED;
var speed = 0.0;
var invincible = false;
var hit_sources = [];
var protected_from = [];
var hit_stats = {};
var health;
var cart = null;

#refers state to a string
onready var states_map = {
	"idle": $States/Idle,
	"move": $States/Move,
	"retreat": $States/Retreat,
	"sword_attack": $States/Sword_Attack,
	"hit" : $States/Hit,
	"die" : $States/Die,
	"stunned": $States/Stunned,
	"throw_boomerang": $States/Throw_Boomerang,
	"carted": $States/Carted,
	"swim": $States/Swim
}

#list of most current states
var states_stack = [];
var current_state = null;

var active = false setget set_active;

func _ready():
	Hero_Vars.revenge_target = null;
	health = Hero_Vars.health;
#	get_viewport().audio_listener_enable_2d = true
#	Player_Vars.player = self;
	
	for child in $States.get_children():
		if not child is Timer && not child is Line2D:
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

func _physics_process(_delta):
	current_state.update();
	hit_detection();
	swim_detection();
	update_global_vars();
	push_objects();
	
	if Input.is_action_just_pressed("kill_hero") && OS.is_debug_build():
		hit_stats["stun"] = false;
		hit_stats["hit_strength"] = Vector2.RIGHT;
		hit_stats["damage"] = 100;
		health -= hit_stats["damage"];
		Hero_Vars.health = health;
		Combo_Manager.add_hit(self, self, hit_stats['damage'], hit_stats['hit_strength'].x);
		emit_signal("hit", health);
		current_state.emit_signal("finished", "hit");


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


func update_global_vars():
	Hero_Vars.position = position;
	health = Hero_Vars.health;


func push_objects():
	for collider in $Hitbox.get_overlapping_areas():
		var object = collider.get_parent();
		if object.is_in_group("Pushable"):
			if (position.y >= object.global_position.y - 20) && (position.y < object.global_position.y + 20):
				if (object.global_position.x <= position.x) && (sign(motion.x) == -1):
					collider.owner.push(Vector2(motion.x, 0));
				elif (object.global_position.x >= position.x) && (sign(motion.x) == 1):
					collider.owner.push(Vector2(motion.x, 0));
			
			elif (position.x >= object.global_position.x - 20) && (position.x < object.global_position.x + 20):
				if (object.global_position.y <= position.y) && (sign(motion.y) == -1):
					collider.owner.push(Vector2(0, motion.y));
				elif (object.global_position.y >= position.y) && (sign(motion.y) == 1):
					collider.owner.push(Vector2(0, motion.y));


func carted(target_cart):
	cart = target_cart;
	current_state.emit_signal("finished", "carted");


func check_in_water():
	if get_parent().owner == null: return false;
	var water_tiles = get_parent().owner.get_node_or_null("Water");
	if water_tiles == null: return false;
	
	var tile_pos = water_tiles.world_to_map(global_position)/5;
	if water_tiles.get_cell(tile_pos.x, tile_pos.y) != -1: #if in water tile
		return true;
	return false;


func swim_detection():
	if check_in_water() && !$Hitbox/CollisionShape2D.disabled && (not current_state.name in ["Swim", "Die"]):
		current_state.emit_signal("finished", "swim");


func hit_detection():
	if current_state.name in ["Die", "Hit"]: return;
	
	for collider in $Hitbox.get_overlapping_areas():
		if collider.is_in_group("Monster_Hitbox"):
			hit(collider.owner, "monster");
			return;
		
		elif collider.is_in_group("Projectile_Hitbox") && !collider.is_in_group("Hero_Hitbox"):
			hit(collider.owner, "projectile");
			collider.owner.destroy();
			return;
		
		elif collider.is_in_group("Universal_Hitbox"):
			if collider.owner in protected_from: continue;
			else:
				hit(collider.owner, "universal");
				return;
		
		elif collider.is_in_group("Pickup_Hitbox") && is_in_group("Cartable"):
			if (collider.owner in protected_from): continue;
			if collider.owner.pickup(self):
				return;


func hit(source, source_type="monster"):
	if Hit_Manager.get_damage_type(source) == "projectile":
		if source.shooter in hit_sources: return;
		elif !source.shooter.is_in_group("Lich"): hit_sources.append(source.shooter);
	else:
		if source in hit_sources: return;
		else: 
			hit_sources.append(source);
#			print("hit by: " + source.name);
	
	invincible = true;
#	var damage = 0;
#	var stun = false;
#	var hit_strength = 1;
	
#	if source_type == "monster":
#		Hero_Vars.revenge_target = source;
#		hit_strength = sign(position.x - source.position.x);
#
#		damage = Game_Balance.get(source.monster_type + "_data")['damage'];
#
#		if source.is_in_group("Stun_Attack"):
#			stun = true;
#
#
#	elif source_type == "projectile":
#		if weakref(source.shooter).get_ref() != null:
#			Hero_Vars.revenge_target = source.shooter;
#		hit_strength = sign(position.x - source.position.x);
#
#		if source.is_in_group("Seed"):
#			damage = Game_Balance.peapo_data['damage'];
#
#	else:
#		hit_strength = sign(position.x - source.position.x);
#		damage = source.damage;
#		if source.get("stun") != null: stun = source.stun;
#
#	if hit_strength == 0: hit_strength = 1;
	hit_stats = Hit_Manager.get_hit_data(self, source, true);
	Combo_Manager.add_hit(self, source, hit_stats['damage'], hit_stats['hit_strength'].x);
#	hit_stats = [damage, stun, hit_strength];
	
	if hit_stats['stun']:
		Global_Camera.freeze_frame("large");
	if hit_stats['damage'] <= 2:
		Global_Camera.shake("small");
		Global_Camera.freeze_frame("small");
	elif hit_stats['damage'] <= 3:
		Global_Camera.shake("medium");
		Global_Camera.freeze_frame("medium");
	
	Global_Effects.circle_hit(position - Vector2(20,0));
	
	health -= hit_stats['damage'];
	Hero_Vars.health = health;
#	print("HP: " + str(Hero_Vars.health));
	
	emit_signal("hit", health);
	current_state.emit_signal("finished", "hit");
