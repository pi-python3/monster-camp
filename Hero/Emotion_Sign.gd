extends Sprite

var emotions = {
	"angry": 0,
	"scared": 1
};
var current_emotion: String;


func _ready():
	disappear();


func show_emotion(emotion: String):
	current_emotion = emotion;
	frame = emotions[emotion];
	$Emotion_Animation.play("Wiggle");
	pop_up();


func pop_up():
	$Tween.interpolate_property(self, "scale", Vector2(0,0), Vector2(1,1), 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT);
	$Tween.start();


func pop_away():
	$Tween.interpolate_property(self, "scale", Vector2(1,1), Vector2(0,0), 0.5, Tween.TRANS_BOUNCE, Tween.EASE_IN);
	$Tween.start();


func disappear():
	hide();
	scale = Vector2.ZERO;


func _on_Tween_tween_completed(object, key):
	if object == self && self.scale == Vector2(1,1):
		$Timer.start();
	
	elif object == self && self.scale == Vector2(0,0):
		disappear();


func _on_Timer_timeout():
	pop_away();
