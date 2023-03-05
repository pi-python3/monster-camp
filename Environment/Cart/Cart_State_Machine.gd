extends KinematicBody2D;

signal state_changed(current_state);
signal hit(current_health);
signal die(object);

export(NodePath) var START_STATE;
const MAX_STACK_SIZE = 3;

var motion := Vector2(0,0);
var hit_stats = [];
var invincible := false;
var can_push := true;
var hit_sources = [];

var carted_object = null;

signal destroy(object);

const NAV_POLY = preload("res://Environment/Medium_Nav_Poly.tscn");

export(int) var max_health = 8;
var health = max_health;
onready var damage = Game_Balance.find_object(Game_Balance.object_data["objects"], "name", "crate")["damage"];

var destroyed = false;

var slide_motion = Vector2.ZERO;


#func get_monster_health(monster_name: String):
#	var var_name = monster_name + "_data";
#	return Game_Balance.get(var_name)['health'];
#
#func get_monster_damage(monster_name: String):
#	var var_name = monster_name + "_data";
#	return Game_Balance.get(var_name)['damage'];


#refers state to a string
onready var states_map = {
	"idle": $States/Idle,
	"slide": $States/Slide,
	"hit_slide": $States/Hit_Slide,
	"hit": $States/Hit,
	"break": $States/Break
}

#list of most current states
var states_stack = [];
var current_state = null;

var active = false setget set_active;

func _ready():
	$Sprite.frame = 0;
	$Sprite.show();
	$Sprite/Shadow.show();
	modulate.a = 1;
	$Move_Particles.emitting = false;
	$Slide_Hitbox/CollisionShape2D.disabled = true;
	
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
	if current_state is KinematicBody2D:
		current_state.update();
	else:
		current_state.update(delta);
	
	hit_detection();
	pickup_objects();
	push_objects();
	
	if weakref(carted_object).get_ref() != null:
		if weakref(carted_object.cart).get_ref() == null:
			empty_cart();
	
	if slide_motion.x < 0: $Sprite.animation = "Roll Left";
	else: $Sprite.animation = "Roll Right";
	$Sprite.speed_scale = slide_motion.length() / 50;
	
#	if health <= 0 && not current_state.name in ["Hit", "Break"]:
#		current_state.emit_signal("finished", "break");


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
	emit_signal("state_changed", current_state);
	
#	if state_name != "previous":
	current_state.enter();


func push_objects():
#	var slide_motion = $States/Slide.slide_motion;
	for collider in $Hitbox.get_overlapping_areas():
		var object = collider.get_parent();
		if object == self: return;
		
		elif object.is_in_group("Pushable") && collider.name == "Projectile_Hitbox":
			if (global_position.y >= object.global_position.y - 20) && (global_position.y < object.global_position.y + 20):
				collider.owner.push(Vector2(slide_motion.x, 0));
			elif (global_position.x >= object.global_position.x - 20) && (global_position.x < object.global_position.x + 20):
				collider.owner.push(Vector2(0, slide_motion.y));


func _on_Push_Wait_timeout():
	$Move_Particles.emitting = false;


func push(direction: Vector2):
	if direction == Vector2.ZERO || !can_push: return;
	
	motion = direction.normalized();
	slide_motion = motion * $States/Slide.slide_speed;
	
	$Move_Particles.emitting = true;
	$Move_Particles.process_material.direction = Vector3(-motion.x, -motion.y, 0);

	$Move_Particles/Push_Wait.start();
	if !$Push_SFX.playing: $Push_SFX.play();
	if current_state.name != "Slide": current_state.emit_signal("finished", "slide");


func pickup_objects():
	if carted_object != null || $Pickup_Hitbox/Collision.disabled: return;
	
	for collider in $Pickup_Hitbox.get_overlapping_areas():
		var object = collider.get_parent();
		if object == self || object in hit_sources: return;
		
		if object.is_in_group("Cartable"):
			carted_object = object;
			object.carted(self);
			return;


func pickup(object):
	if carted_object != null || $Pickup_Hitbox/Collision.disabled: return false;
	if object in hit_sources: return false;
	
	if object.is_in_group("Cartable"):
		carted_object = object;
		if object.get_node_or_null("Components/Cartable") != null:
			object.get_node("Components/Cartable").carted(self);
		else:
			object.carted(self);
		return true;


func empty_cart():
	carted_object = null;


func clear_protected():
	for source in hit_sources:
		if weakref(source).get_ref() != null:
			if "protected_from" in source:
				for i in range(source.protected_from.size()):
					source.protected_from.erase(self);


func hit_detection():
	if current_state.name in ["Hit", "Break"] || invincible: return;
	
	for collider in $Hitbox.get_overlapping_areas():
		if collider.is_in_group("Hero_Hitbox"):
			hit(collider.owner, "hero");
			return;
		
		elif collider.is_in_group("Monster_Hitbox"):
			hit(collider.owner, "monster");
			return;
		
		elif collider.is_in_group("Universal_Hitbox") && collider.owner != self:
			hit(collider.owner, "universal");
			return;
		
		elif collider.is_in_group("Projectile_Hitbox"):
			hit(collider.owner, "projectile");
			collider.owner.destroy();


func hit(source, source_type: String):
	clear_protected();
	hit_sources.clear();
	
	if Hit_Manager.get_damage_type(source) == "projectile":
		if source.shooter in hit_sources: return;
		else: 
			hit_sources.append(source.shooter);
			if "protected_from" in source.shooter:
				source.shooter.protected_from.append(self);
	else:
		if source in hit_sources: return;
		else: 
			hit_sources.append(source);
			if "protected_from" in source:
				source.protected_from.append(self);

	invincible = true;
	hit_stats = Hit_Manager.get_hit_data(self, source, false, true);

	Global_Camera.shake("small");
	Global_Camera.freeze_frame("small");
	
	Global_Effects.circle_hit(global_position);
	
#	health -= hit_stats['damage'];
	emit_signal("hit", health);
	current_state.emit_signal("finished", "hit");
