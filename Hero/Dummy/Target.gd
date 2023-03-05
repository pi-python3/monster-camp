extends AnimatedSprite

func _ready():
	hide();
	appear_in();


func _process(_delta):
	if get_global_input_direction() != Vector2.ZERO:
		modulate.a = 0;
		show();
		appear_in();
		set_process(false);
		return;


func appear_in(start_value: float = 20, time: float = 0.4):
	scale = Vector2(start_value, start_value);
	$Tween.interpolate_property(self,"scale",self.scale,Vector2(1,1),time,
	Tween.TRANS_QUAD, Tween.EASE_IN);
	
	$Tween2.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), time,
	Tween.TRANS_QUAD, Tween.EASE_IN);
	
	$Tween.start();
	$Tween2.start();


func get_global_input_direction() -> Vector2:
	var input_dir = Vector2();
	input_dir.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"));
	input_dir.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"));

	return input_dir;
