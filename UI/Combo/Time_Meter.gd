extends TextureProgress

var previous_value = 100;

func _process(_delta):
	value = max_value * (1.0 - float(Combo_Manager.deltatime) / float(Combo_Manager.max_combo_time));


func _on_Time_Meter_value_changed(value):
	if value <= 0 && Combo_Manager.combo_num > 1 && Hero_Vars.health > 0:
		Sound_Manager.play_sound("Drop_Combo.wav", true);
