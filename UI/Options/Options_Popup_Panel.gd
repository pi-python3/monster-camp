extends PopupPanel

onready var canvas_modulate = owner.get_node_or_null("CanvasModulate");


func _on_Options_Popup_popup_hide():
#	canvas_modulate = owner.get_node("CanvasModulate");
	$Tween.interpolate_property(canvas_modulate, "color", canvas_modulate.color, Color(1,1,1), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN);
	$Tween.start();
#	canvas_modulate.color = Color(1, 1, 1);
