extends CanvasLayer

signal transition_close_end;
signal transition_open_end;

func _ready():
	$Control.hide();
	Level_Handler.connect("changing_level", self, "_on_changing_level");
	Level_Handler.connect("new_level", self, "_on_new_level");


func _on_changing_level():
#	print(Level_Handler.get_current_level());
	$Control.show();
	$Control/Animation.play("Close");
	yield($Control/Animation, "animation_finished");
	yield(get_tree().create_timer(0.1),"timeout");
	emit_signal("transition_close_end");


func _on_new_level(level):
#	get_tree().paused = true;
#	yield(get_tree().create_timer(0.5), "timeout");
	$Control/Animation.play("Open");
	yield($Control/Animation, "animation_finished");
	emit_signal("transition_open_end");
#	get_tree().paused = false;

func _process(_delta):
	if get_tree().current_scene.filename == "res://Main_Scenes/Home.tscn":
		$Control.hide();
