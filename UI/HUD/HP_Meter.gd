extends TextureProgress

export(Vector2) var original_scale = Vector2(5,5);
onready var val = Hero_Vars.health;
var tween_done = false;

func _ready():
	max_value = Hero_Vars.max_health;
	value = max_value;
	
	tint_progress = Color(1,1,1);


func _process(_delta):
	max_value = Hero_Vars.max_health;
	
	if val != Hero_Vars.health && !$Tween2.is_active():
		_on_hit(val, Hero_Vars.health);
		val = Hero_Vars.health;


func _on_hit(old_value, new_value):
	tween_done = false;
	
	$Tween1.interpolate_property(self, "rect_scale",rect_scale, rect_scale * 1.05,
	0.15,Tween.TRANS_LINEAR, Tween.EASE_OUT);
	
	$Tween2.interpolate_property(self, "value", old_value, new_value,
		0.15, Tween.TRANS_BACK,Tween.EASE_OUT);
	
	$Tween1.start();
	$Tween2.start();
	$Animation.play("Hit");


func _on_Tween1_tween_all_completed():
	value = Hero_Vars.health;
	
	$Tween1.interpolate_property(self, "rect_scale",rect_scale, original_scale,
	0.15,Tween.TRANS_BACK, Tween.EASE_OUT);
	
	$Tween1.start();
	
	tween_done = true;
