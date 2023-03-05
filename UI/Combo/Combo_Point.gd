extends Label

var move_dir = 0;
var hor_speed = 80;
var rise_height = 120;
var gravity = 15;
var gravity_max = -100;
var rotation_change_speed = 20;
var fade = 1.3;

func _ready():
	hide();
	set_process(false);


func appear(points=0, position=Vector2(0,0), dir=0):
	text = str(points);
	rect_position = position;
	rect_rotation = 20 * dir;
	move_dir = dir;
	show();
	set_process(true);


func _process(delta):
	rect_position.x += hor_speed * move_dir * delta;
	rect_position.y -= rise_height * delta;
	rise_height = clamp(rise_height-gravity, gravity_max, 1000);
	
	rect_rotation += rotation_change_speed * move_dir * delta;
	
	modulate.a -= fade * delta;
	if modulate.a <= 0:
		hide();
		queue_free();
		set_process(false);
