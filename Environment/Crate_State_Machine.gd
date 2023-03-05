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

var cart;
var stick_target;

signal destroy(object);

const NAV_POLY = preload("res://Environment/Medium_Nav_Poly.tscn");

export(int) var MAX_HEALTH = 6;
var health = MAX_HEALTH;
onready var damage = Game_Balance.find_object(Game_Balance.object_data["objects"], "name", "crate")["damage"];

var destroyed = false;

var slide_motion = Vector2.ZERO;


#refers state to a string
onready var states_map = {
	"idle": $States/Idle,
	"slide": $States/Slide,
	"hit_slide": $States/Hit_Slide,
	"carted": $States/Carted,
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
	push_objects();
	check_cart_pickup();
	
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
	if !can_push || current_state.name == "Carted": return;
	
	for collider in $Hitbox.get_overlapping_areas():
		var object = collider.get_parent();
		if object.is_in_group("Pushable") && object != self:
			if (position.y >= object.global_position.y - 20) && (position.y < object.global_position.y + 20):
				collider.owner.push(Vector2(motion.x, 0));
			elif (position.x >= object.global_position.x - 20) && (position.x < object.global_position.x + 20):
				collider.owner.push(Vector2(0, motion.y));


func push(direction: Vector2):
	if direction == Vector2.ZERO || !can_push: return;
	
	motion = direction.normalized();
	$States/Slide.slide_motion = motion * $States/Slide.slide_speed;
	
	$Move_Particles.emitting = true;
	$Move_Particles.process_material.direction = Vector3(-motion.x, -motion.y, 0);

	$Move_Particles/Push_Wait.start();
	if !$Push_SFX.playing: $Push_SFX.play();
	if current_state.name != "Slide": 
		current_state.emit_signal("finished", "slide");


func _on_Push_Wait_timeout():
	$Move_Particles.emitting = false;


func check_cart_pickup():
	for collider in $Pickup_Hitbox.get_overlapping_areas():
		var object = collider.get_parent();
		
		if object == self || !object.is_in_group("Cart"): return;
		
		elif object.carted_object == null:
			carted(object);


func carted(target_cart):
	target_cart.carted_object = self;
	cart = target_cart;
	current_state.emit_signal("finished", "carted");


func hit_detection():
	if current_state.name in ["Hit", "Break"] || invincible: return;
	
	for collider in $Hitbox.get_overlapping_areas():
		if collider.is_in_group("Hero_Hitbox"):
			hit(collider.owner, "hero");
			return;
		
		elif collider.is_in_group("Monster_Hitbox"):
			hit(collider.owner, "monster");
			return;
		
		elif collider.is_in_group("Projectile_Hitbox"):
			hit(collider.owner, "projectile");
			collider.owner.destroy();
		
		elif collider.is_in_group("Universal_Hitbox") && collider.owner != self:
			hit(collider.owner, "universal");
			return;
		
#		elif collider.is_in_group("Pickup_Hitbox") && is_in_group("Cartable"):
##			if collider.owner in protected_from: continue;
#			if collider.owner.pickup(self):
#				return;


func hit(source, source_type: String):
	invincible = true;
	
	hit_stats = Hit_Manager.get_hit_data(self, source, false, true);
	damage = 1;#clamp(hit_stats['damage'], 1, 2);
	
	if "protected_from" in source:
		source.protected_from.append(self);
	
	Global_Camera.shake("small");
	Global_Camera.freeze_frame("small");
	
	Global_Effects.circle_hit(global_position);
	
	health -= hit_stats['damage'];
	emit_signal("hit", health);
	current_state.emit_signal("finished", "hit");
