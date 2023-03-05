extends Node

class_name Component, "res://Meta/Component_Icon.png"

export(bool) var is_active = true;

func setup():
	pass;


func update(delta):
	pass;


func connect_state(owner_object, state_name: String):
	if owner_object.get_node("States").get_node_or_null(state_name) != null:
		var state = owner_object.get_node("States/" + state_name);
		if !state.is_connected("finished", owner_object, "_change_state"):
			state.connect("finished", owner_object, "_change_state");
		set_process(false);
		return;
