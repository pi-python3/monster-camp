extends AnimatedSprite

var wait = 0;
var dead = false;

func _process(_delta):
	if wait < 5:
		wait += 1;
		return;
	
	visible = !dead;
	frame = Hero_Vars.health - 1;
	
	if Hero_Vars.health <= 0:
		dead = true;
	


func _on_Boko_hit(current_health):
	if current_health <= 0:
		dead = true;
#		visible = false;
	else:
		frame = current_health - 1;
