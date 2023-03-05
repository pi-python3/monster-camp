extends Particles2D

export(Vector2) var slam_position = Vector2(3,4);
var direction = 1;

func _ready():
	emitting = false;
	position = slam_position;


func emit(dir: int):
	
	emitting = true;
	$Cooldown.start();
	
	Sound_Manager.play_sound("Slam.wav");


func _on_Cooldown_timeout():
	emitting = false;
