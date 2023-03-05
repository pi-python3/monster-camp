extends Particles2D

var direction = 1;

func _ready():
	emitting = false;


func emit(dir: int, scale_size = 1.0):
	direction = sign(dir);
	
#	if direction < 0: scale.x = -scale_size;
	scale.x = scale_size;
	
	emitting = true;
	$Cooldown.start()


func _on_Cooldown_timeout():
	emitting = false;
