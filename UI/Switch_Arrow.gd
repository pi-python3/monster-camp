extends Position2D


var weak_switch_monster;

func _process(delta):
	weak_switch_monster = weakref(Monster_Vars.switch_monster);
	
	if weak_switch_monster.get_ref() == null: return;
	
	position = weak_switch_monster.get_ref().position;
