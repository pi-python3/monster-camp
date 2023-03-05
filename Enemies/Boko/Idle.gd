extends "../Motion.gd"

var input_direction: Vector2;
const IDLE_SHADER = "res://Shaders/Idle.tres";
const MOVE_SHADER = "res://Shaders/Move.tres";

export(Dictionary) var on_enter = {
		'reset_frame': true,
		'animation': '',
		'animate_shadow': false
	};

onready var sprite = owner.get_node("Sprite");
onready var sprite_handler = owner.get_node("Sprite_Handler");


func _ready():
	sprite.frame = 0;


func enter():
	sprite_handler.change_shader(IDLE_SHADER);
	owner.motion = Vector2.ZERO;
	
	if on_enter['reset_frame']: sprite.frame = 0;
	
	if on_enter['animation'] != '':
		sprite.animation = on_enter['animation'];
		sprite.frame = 0;
		sprite.playing = true;
	
	if on_enter['animate_shadow']:
		owner.get_node("Effects").shadow_grow_shrink();


func exit():
	sprite_handler.clear_shader();
	if on_enter['animation'] != '':
		sprite.playing = false;
	
	return;


func input_update():
	input_direction = get_input_direction();
	
	if input_direction != Vector2.ZERO:
		if owner.monster_type == "peapo":
			if owner.can_attack: emit_signal("finished", "aim");
			else: emit_signal("finished", "move");
		
		else:
			emit_signal("finished", "move");
	
	elif get_attack_input():
		emit_signal("finished", "attack");


func update(delta):
	input_update();
		
	#if has ai_move state and needs to run from hero, then do it
	var ai_move = get_parent().get_node_or_null("AI_Run");
	if ai_move != null:
		var move_condition := Vector2.ZERO;
		if ai_move.can_run: move_condition += ai_move.close_to_hero();
		elif owner.monster_type == "lich": move_condition = Vector2.ZERO;
		
		if move_condition != Vector2.ZERO:
			emit_signal("finished", "ai_run");
