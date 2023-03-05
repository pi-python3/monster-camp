extends ColorRect

func _ready():
	$Particles.emitting = false;
	$Particles.amount = 8;


func _process(_delta):
	if owner.name != "Combo_Meter": return;
	
	var percent = 1.0 - float(Combo_Manager.points)/float(owner.max_value)
	var y_value = lerp(0, 55, clamp(percent, 0, 1.0));
	y_value = clamp(y_value, 2, 52);
	rect_position = Vector2(rect_position.x, y_value);
	$Label.text = str(Combo_Manager.points);
	
	$Particles.emitting = percent < 1 && get_parent().get_node("Combo_Num").visible;


func _on_Meter_meter_hit():
	if get_parent().get_node("Combo_Num").combo_num + 1 <= 1:
		$Particles.amount = 8;
	else:
		$Particles.amount += 4;
