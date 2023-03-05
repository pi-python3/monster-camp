extends Node


func setup_components():
	for i in get_children():
		i.setup();


func update_components(delta):
	for i in get_children():
		i.update(delta);
