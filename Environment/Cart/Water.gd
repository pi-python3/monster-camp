extends Sprite

var in_water := false;

func ready():
	hide();


func _physics_process(_delta):
	in_water = false;
	for body in $Wheel_Hitbox.get_overlapping_bodies():
		if body is TileMap && body.name == "Water":
			in_water = true;
	
	visible = in_water;


func _on_Wheel_Hitbox_body_entered(body):
	pass;
#	if body is TileMap:
#		show();
