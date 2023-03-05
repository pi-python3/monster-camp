extends Button

var paused = false;
onready var pause_popup = get_parent().get_node_or_null("CenterContainer/Pause_Popup");

func _ready():
	pause_popup.connect("popup_hide", self,"_on_popup_closed");


func _on_Level_Select_Button_pressed():
	Sound_Manager.play_sound_past_pause("Click2.wav");
	Global_Effects.set_paused();
	paused = Global_Effects.paused;
	if paused:
		pause_popup.popup();
		hide();

	else:
		pause_popup.hide();
		$Timer.start();


func _input(event):
	if event.is_action_pressed("pause"):
		_on_Level_Select_Button_pressed()


func _on_popup_closed():
	Global_Effects.set_paused(false);
	paused = Global_Effects.paused;
	$Timer.start();


func _on_Timer_timeout():
	show();
