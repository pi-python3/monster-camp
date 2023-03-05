extends Component

const WATER_EFFECT = preload("res://Enemies/Water_Effect.tscn");
const CARTED_STATE = preload("res://Enemies/States/Carted.tscn");
const DROWN_ANIM = preload("res://Enemies/Drown_Anim.tres");

onready var global_position: Vector2 = owner.global_position;
onready var hitbox = owner.get_node("Hitbox");


func setup():
	if !is_active: return;
	
	owner.add_to_group("Cartable");
	
	var carted_state = CARTED_STATE.instance();
	owner.get_node("States").call_deferred("add_child", carted_state);
	owner.states_map["carted"] = carted_state;


func _process(_delta):
	if !is_active: return;
	connect_state(owner, "Carted");


func update(delta):
	if !is_active: return;
	if owner.get_node("States").get_node_or_null("Carted") == null: return;
	
	pickup_detection();


func carted(target_cart):
	owner.cart = target_cart;
	owner.current_state.emit_signal("finished", "carted");


func pickup_detection():
	if !owner.can_hit_detect: return;
	
	for collider in hitbox.get_overlapping_areas():
		if collider.is_in_group("Pickup_Hitbox"):
			if collider.owner in owner.protected_from: continue;
			if collider.owner.pickup(owner):
				return;
