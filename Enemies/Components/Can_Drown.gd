extends Component

const WATER_EFFECT = preload("res://Enemies/Water_Effect.tscn");
const DROWN_STATE = preload("res://Enemies/States/Drown.tscn");
const DROWN_ANIM = preload("res://Enemies/Drown_Anim.tres");

var check_in_water_deltatime = 0;
onready var global_position: Vector2 = owner.global_position;
export(Vector2) var detect_offset = Vector2(0,3);

onready var hitbox_collision = owner.get_node("Hitbox/Collision");


func setup():
	if !is_active: return;
	
	detect_offset *= 5;
	
	var water_effect = WATER_EFFECT.instance();
	water_effect.hide();
	owner.call_deferred("add_child", water_effect);
	
	owner.get_node("Sprite/Animation").add_animation("Drown_Anim", DROWN_ANIM);
	
	var drown_state = DROWN_STATE.instance();
	owner.get_node("States").call_deferred("add_child", drown_state);
	owner.states_map["drown"] = drown_state;


func _process(_delta):
	if !is_active: return;
	connect_state(owner, "Drown");


func update(delta):
	if !is_active: return;
	if owner.get_node("States").get_node_or_null("Drown") == null: return;
	
	update_self_vars();
	if drown_detection(false):
		check_in_water_deltatime += delta;
		if check_in_water_deltatime > 0.1: drown_detection();
	else:
		check_in_water_deltatime = 0;


func update_self_vars():
	global_position = owner.global_position;


func check_in_water():
	if owner.get_parent().owner == null: return false;
	var water_tiles = owner.get_parent().owner.get_node_or_null("Water");
	if water_tiles == null: return false;
	
	var tile_pos = water_tiles.world_to_map(global_position + detect_offset)/5;
	if water_tiles.get_cell(tile_pos.x, tile_pos.y) != -1: #if in water tile
		if owner.get_node_or_null("Water_Effect") != null: owner.get_node("Water_Effect").show();
		
		return true;
	
	return false;


func drown_detection(go_to_state:= true):
	if check_in_water() && !hitbox_collision.disabled && (not owner.current_state.name in ["Drown", "Die"]):
		if go_to_state: owner.current_state.emit_signal("finished", "drown");
		return true;

	return false;
