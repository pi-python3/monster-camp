extends AnimatedSprite

var original_scale;
const pulse_time = 0.3;
var tween_done = false;


func _ready():
	hide();


func pulse():
	return;
	
	frame = get_parent().frame;
	animation = get_parent().animation;
	flip_h = get_parent().flip_h;
	show();
	
	if $Tween.is_active():
		$Tween.stop_all();
		scale = original_scale;
	
	tween_done = false;
	original_scale = scale;
	$Tween.interpolate_property(self, "scale", scale, scale * 1.3,
	pulse_time/2, Tween.TRANS_LINEAR,Tween.EASE_IN);
	$Tween.start();


func _on_Tween_tween_all_completed():
	if !tween_done:
		tween_done = true;
		$Tween.interpolate_property(self, "scale", scale, original_scale,
		pulse_time/2, Tween.TRANS_BACK,Tween.EASE_OUT);
		$Tween.start();
	
	else:
		hide();
