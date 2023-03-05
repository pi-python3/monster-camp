extends Node

const SFX_Player = preload("res://Audio/SFX_Player.tscn");
const Music_Player = preload("res://Audio/Music_Player.tscn");

export(String) var SFX_Folder_Path = "res://Audio/SFX/";
export(String) var Music_Folder_Path = "res://Audio/Music/";
export(int) var AUDIO_STREAMS_AMOUNT = 3;
var audio_streams = [];
var protected_audio_streams = [];
var pause_audio_streams = [];

var muted := false;
var music_muted := true;
var music_pause_pos;


func _ready():
	Level_Handler.connect("new_level", self, "_on_new_level");
	Level_Handler.connect("menu_open", self, "_on_menu_open");

	yield(get_tree().create_timer(0.1),"timeout");
	_on_menu_open();
	
	audio_streams.clear();
	protected_audio_streams.clear();
	
	for _i in range(AUDIO_STREAMS_AMOUNT):
		var a = SFX_Player.instance();
		a.pause_mode = Node.PAUSE_MODE_STOP;
		add_child(a);
		audio_streams.append(a);
	
	var a = SFX_Player.instance();
	a.pause_mode = Node.PAUSE_MODE_STOP;
	add_child(a);
	protected_audio_streams.append(a);
	
	a = SFX_Player.instance();
	a.pause_mode = Node.PAUSE_MODE_PROCESS;
	add_child(a);
	pause_audio_streams.append(a);


func _on_menu_open():
	if $Music_Player.stream == null:
		play_music("Pixel Lounge.wav");
	
	elif not ("Pixel Lounge" in $Music_Player.stream.resource_path) || !$Music_Player.playing:
		play_music("Pixel Lounge.wav");


func _on_new_level(_level):
	if _level == 0: return;
	
	var music_choice = "Muffin Shuffle";
	
	if $Music_Player.stream == null:
		play_music(music_choice + ".wav");
	
	elif not (music_choice in $Music_Player.stream.resource_path) || !$Music_Player.playing:
		play_music(music_choice + ".wav");


func set_music_muted(value: bool):
	music_muted = value;
	AudioServer.set_bus_mute(3, value);
	
	if value:
		if $Music_Player.playing:
			music_pause_pos = $Music_Player.get_playback_position();
			$Music_Player.stop();
	else:
		if !$Music_Player.playing:
			if music_pause_pos != null:
				$Music_Player.play(music_pause_pos);
			
			else:
				$Music_Player.play();


func find_open_stream(no_pitch_scale:=false, past_pause:=false):
#	if audio_streams.size() >= 20: return audio_streams[0];
	
	if past_pause:
		for a in pause_audio_streams:
			if !a.playing: return a;
	
	elif no_pitch_scale:
		for a in protected_audio_streams:
			if !a.playing: return a;
	else:
		for a in audio_streams:
			if !a.playing: return a;
	
	var a = SFX_Player.instance();
	add_child(a);
	
	if past_pause:
		a.pause_mode = Node.PAUSE_MODE_PROCESS;
		pause_audio_streams.append(a);
		return a;
	
	a.pause_mode = Node.PAUSE_MODE_STOP;
	if no_pitch_scale: protected_audio_streams.append(a);
	else: audio_streams.append(a);
	return a;


func play_sound(sfx_name: String, no_pitch_scale:=false, bus = "SFX"):
	if muted: return;
	
	var audio_stream = find_open_stream(no_pitch_scale);
	audio_stream.bus = bus;
	audio_stream.play_sound(sfx_name);


func play_sound_past_pause(sfx_name: String, bus = "SFX"):
	if muted: return;
	
	var audio_stream = find_open_stream(true, true);
	audio_stream.bus = bus;
	audio_stream.play_sound(sfx_name);


func play_sound_pitch_range(sfx_name: String, pitch_min: float, pitch_max: float, bus = "SFX"):
	if muted: return;
	
	var audio_stream = find_open_stream();
	audio_stream.bus = bus;
	
	var rand = RandomNumberGenerator.new();
	rand.randomize();
	
	audio_stream.pitch_scale = rand.randf_range(pitch_min, pitch_max);
	audio_stream.play_sound(sfx_name);


func set_pitch_scale(pitch_scale: float):
	for a in audio_streams:
		a.pitch_scale = pitch_scale;


func play_music(music_name: String, bus = "Music"):
	if music_muted: return;
	
	$Music_Player.play_sound(music_name);


func play_music_loop(music_name: String, is_preroll:= true, bus = "Music"):
	if music_muted: return;
	
	var extension = music_name.get_extension();
	if is_preroll:
		$Music_Player.play_sound(music_name.split(".",true,1)[0] + " Preroll." + extension);
	else:
		$Music_Player.play_sound(music_name.split(".",true,1)[0] + " Loop." + extension, "");


func _on_Music_Player_finished():
	var is_preroll = "Preroll" in $Music_Player.stream.resource_path;
	var extension = $Music_Player.stream.resource_path.get_extension();
	if is_preroll:
		var path = $Music_Player.stream.resource_path;
		path = path.split(".", true, 1)[0];
		var file_name = path.split(" Preroll", true, 1)[0] + "." + extension;
		play_music_loop(file_name, false);
