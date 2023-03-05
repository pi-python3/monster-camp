extends Component

enum DANCE_ANIM_TYPE {HOP=0, CIRCLE=1};
export(DANCE_ANIM_TYPE) var dance_anim_type;

enum DANCE_TYPE {MOVE=0};
export(DANCE_TYPE) var dance_type;

func setup():
	if !is_active: return;
	
	var dance_res = {
		0: Preloads.HOP_DANCE,
		1: Preloads.CIRCLE_DANCE
	};
	
	owner.get_node("Sprite/Animation").add_animation("Dance", dance_res[dance_anim_type]);
	
	var dance_state;
	match dance_type:
		DANCE_TYPE.MOVE:
			dance_state = Preloads.DANCE_MOVE.instance();
	
	owner.get_node("States").call_deferred("add_child", dance_state);
	owner.states_map["dance"] = dance_state;
	
	Level_Handler.connect("level_over", self, "_on_level_over");


func _process(_delta):
	if !is_active: return;
	connect_state(owner, "Dance");


func update(delta):
	if !is_active: return;


func _on_level_over(_state):
	if Level_Handler.level_state == Level_Handler.LEVEL_STATE.WIN && not owner.current_state.name in ["Drown", "Die"]:
		if Monster_Vars.monsters.size() > 1:
			yield(get_tree().create_timer(randf()*0.6),"timeout");
		owner.current_state.emit_signal("finished", "dance");
