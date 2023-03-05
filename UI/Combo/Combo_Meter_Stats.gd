extends CanvasLayer

export var max_value := 50;

func set_max_value(val):
	max_value = val;
	$Meter.max_value = val;
