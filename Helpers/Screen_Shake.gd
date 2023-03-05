extends Node

const TRANS = Tween.TRANS_SINE;
const EASE = Tween.EASE_IN_OUT;
const MAX_ANGLE = 5.0;
const MAX_OFFSET = 15.0;

export(float) var TRAUMA_DECREASE = 0.9;

onready var camera = get_parent();

var amplitude = 0;
var angle_amplitude = 0;
var priority = 0;
var trauma:float = 0.0;
var shake:float = 0.0;

onready var noise = OpenSimplexNoise.new();

#func _ready():
#	noise.seed = randi();


#func start(trauma:float):
#	self.trauma = clamp(self.trauma + trauma, 0, 1);


#func _process(delta):
#	trauma = clamp(trauma - (TRAUMA_DECREASE * delta), 0, 1); #decrease trauma by linear amount
#	shake = pow(trauma, 3);
#
#	if shake > 0:
#		var current_time = OS.get_unix_time();
#
#		camera.rotation_degrees = MAX_ANGLE * shake * noise.get_noise_2d(current_time, current_time) * 10;
#		camera.offset.x = MAX_OFFSET * shake * noise.get_noise_2d(current_time, current_time) * 10;
#		camera.offset.y = MAX_OFFSET * shake * noise.get_noise_2d(current_time, current_time) * 10;
#
#	else:
#		camera.rotation_degrees = 0;
#		camera.offset = Vector2.ZERO;


func start(duration=0.2, frequency=15, amplitude=16, angle_amp=10, priority=0):
	if priority >= self.priority:
		self.priority = priority;
		self.amplitude = amplitude;
		self.angle_amplitude = angle_amp;

		$Duration.wait_time = duration;
		$Frequency.wait_time = 1 / float(frequency);

		$Duration.start();
		$Frequency.start();

		new_shake();


func new_shake():
	var rand = Vector2();
	rand.x = rand_range(-amplitude, amplitude);
	rand.y = rand_range(-amplitude, amplitude);
	var rand_angle = rand_range(-angle_amplitude, angle_amplitude);

	$Tween.interpolate_property(camera, "offset", camera.offset, rand, $Frequency.wait_time, TRANS, EASE);
	$Angle_Tween.interpolate_property(camera, "rotation_degrees", camera.rotation_degrees, rand_angle, $Frequency.wait_time, TRANS, EASE);

	$Tween.start();
	$Angle_Tween.start();


func reset():
	$Tween.interpolate_property(camera, "offset", camera.offset, Vector2(), $Frequency.wait_time, TRANS, EASE);
	$Angle_Tween.interpolate_property(camera, "rotation_degrees", camera.rotation_degrees, 0, $Frequency.wait_time, TRANS, EASE);

	$Tween.start();
	$Angle_Tween.start();

	self.priority = 0;


func _on_Frequency_timeout():
	new_shake();


func _on_Duration_timeout():
	reset();
	$Frequency.stop();
