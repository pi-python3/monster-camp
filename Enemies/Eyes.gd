extends Sprite

export(bool) var enabled = true;


func _ready():
	visible = false;

func _process(_delta):
	visible = owner.controlled && enabled;
	flip_h = get_parent().flip_h;
	
	if hframes > 1: frame = get_parent().frame;
