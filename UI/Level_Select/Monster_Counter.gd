extends Control

export(int) var monster_num = 0;
export(int) var amount = 1;

func _ready():
	var monster_x_pos = monster_num * 5;
	var monster_head = $HBoxContainer/CenterContainer/Monster_Head.texture;
	monster_head.set_region(Rect2(monster_x_pos,0, monster_head.get_region().w, monster_head.get_region().h))
	
	$HBoxContainer/Label.text = "x" + str(amount);
