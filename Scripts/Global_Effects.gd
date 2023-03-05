extends Node

const CIRCLE_HIT_EFFECT = preload("res://UI/Circle_Hit_Effect.tscn");

var game;
var paused := false;


func _ready():
	Level_Handler.connect("new_level", self, "_new_level");


func _new_level(_level):
	game = get_parent().get_node_or_null("Game");


func circle_hit(position):
	var c = CIRCLE_HIT_EFFECT.instance();
	game.add_child(c);
	c.start_effect(position);


func slow_motion(percent: float, shift_audio:=true):
	var flipped_percent = (100.0 - percent) / 100.0;
	Engine.time_scale = flipped_percent;
	
	if shift_audio:
		Sound_Manager.set_pitch_scale( min(flipped_percent*(1.75), 1.0) );


func set_paused(value=null):
	if value == null || !(value is bool):
		paused = !paused;
	else:
		paused = value;
	
	get_tree().paused = paused;
	VisualServer.set_shader_time_scale(int(!paused));
