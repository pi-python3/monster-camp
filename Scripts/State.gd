extends Node

class_name State, "res://Meta/State_Machine_Icon.png"

signal finished(next_state_name);

# Initialize the state. E.g. change the animation
func enter():
	return;

# Clean up the state. Reinitialize values like a timer
func exit():
	return;

func handle_input(event):
	return;

#get input in update function
func input_update():
	return;

func update(delta):
	input_update();
	return;

func _on_animation_finished(anim_name):
	return;
