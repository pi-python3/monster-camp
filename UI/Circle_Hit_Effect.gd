extends AnimatedSprite

export(float) var fade_amount = 0.05;

func _ready():
	playing = false;
	hide();
	set_process(false);


func start_effect(pos):
	position = pos;
	show();
	playing = true;
	set_process(true);


func _process(delta):
	modulate.a -= fade_amount * delta * 50;


func _on_Circle_Hit_Effect_animation_finished():
	hide();
	queue_free();
