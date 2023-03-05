extends AnimatedSprite

func _ready():
	visible = false;


func _process(_delta):
	visible = owner.controlled;
	frame = get_parent().frame;
