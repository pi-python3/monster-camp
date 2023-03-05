extends Sprite


func grow_shrink():
	if !$Animation.is_playing():
		$Animation.play("Grow_Shrink");

func stop_animation():
	$Animation.stop();
