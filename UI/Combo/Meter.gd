extends TextureProgress

signal meter_hit;

const tween_time = 0.3;
var original_rect_scale;

func _ready():
	max_value = get_parent().max_value;
	value = Combo_Manager.points;


func _process(_delta):
	if value != Combo_Manager.points && !$Tween1.is_active():
		$Tween1.interpolate_property(self, "value", value, Combo_Manager.points,
		tween_time, Tween.TRANS_BACK,Tween.EASE_OUT);
		$Tween1.start();
		
		original_rect_scale = rect_scale;
		$Tween2.interpolate_property(self, "rect_scale", rect_scale, rect_scale * 1.05,
		tween_time/2, Tween.TRANS_LINEAR,Tween.EASE_IN);
		$Tween2.start();
		
		emit_signal("meter_hit");


func _on_Tween1_tween_all_completed():
	pass;


func _on_Tween2_tween_all_completed():
	if value != Combo_Manager.points:
		value = Combo_Manager.points;
		$Tween2.interpolate_property(self, "rect_scale", rect_scale, original_rect_scale,
		tween_time/2, Tween.TRANS_BACK,Tween.EASE_OUT);
		$Tween2.start();
