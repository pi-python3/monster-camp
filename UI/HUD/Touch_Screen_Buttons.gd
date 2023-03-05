extends Node2D

func _ready():
	visible = Game_Data.mobile_buttons;
	
	if !visible:
		position = Vector2(10000,100000);

func _process(_delta):
	for i in get_children():
		i.set_process_input(Game_Data.mobile_buttons);
