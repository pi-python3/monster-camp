extends TextureButton

func _ready():
	$AnimationPlayer.play("Hover");


func _on_Back_Button_pressed():
	get_parent().get_parent().get_parent().hide();


func _on_Back_Button_mouse_entered():
	Sound_Manager.play_sound_past_pause("Click2.wav");
