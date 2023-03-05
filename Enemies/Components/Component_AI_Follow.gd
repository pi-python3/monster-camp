extends "../Components/Component.gd"

export(float) var SEEK_RADIUS = 75;
export(bool) var CAN_ATTACK_WHILE_FOLLOWING = true;
export(String) var FOLLOW_SOUND_NAME = "Keesee_Screech.wav";


func setup():
	if !is_active: return;
	
	var follow_state = Preloads.AI_FOLLOW.instance();
	
	follow_state.SEEK_RADIUS = SEEK_RADIUS;
	follow_state.CAN_ATTACK_WHILE_FOLLOWING = CAN_ATTACK_WHILE_FOLLOWING;
	follow_state.FOLLOW_SOUND_NAME = FOLLOW_SOUND_NAME;
	
	owner.get_node("States").call_deferred("add_child", follow_state);
	owner.states_map["ai_follow"] = follow_state;
	
	owner.call_deferred("add_child", Preloads.FOLLOW_SIGNAL.instance());


func _process(_delta):
	if !is_active: return;
	connect_state(owner, "AI_Follow");


func update(_delta):
#if has ai_follow state and can follow, then do it
	if !owner.controlled && owner.current_state.name == "Idle":
		var ai_follow = owner.get_node_or_null("States/AI_Follow");
		if ai_follow != null:
			if ai_follow.close_to_monster():
				owner.current_state.emit_signal("finished", "ai_follow");
