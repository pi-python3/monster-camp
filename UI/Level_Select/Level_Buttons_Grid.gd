extends GridContainer

const LEVEL_SELECT_BUTTON = preload("res://UI/Level_Select/Level_Select_Section.tscn");
export(int) var levels_amount;


func _ready():
#	levels_amount = Level_Handler.MAX_LEVELS;
	
	for i in range(levels_amount):
		var l = LEVEL_SELECT_BUTTON.instance();
		l.level = i + 1;
		call_deferred("add_child",l);
