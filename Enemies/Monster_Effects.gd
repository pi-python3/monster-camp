tool
extends Node2D

export(Dictionary) var move_particle = {
	'active': true,
	'particle_scene': preload("res://Enemies/Move_Particles.tscn"),
	'name': 'Move_Particles',
};

export(Dictionary) var attack_trail = {
	'active': false,
	'trail_scene': preload("res://Hero/Trail.tscn"),
	'name': 'Trail'
};

export(Dictionary) var shadow = {
	'active': true,
	'offset': Vector2(0, 4.5),
	'scale': Vector2(0.5, 1)
};

var has_move_particle = false;
var has_trail = false;


func _ready():
	if !Engine.editor_hint:
		$Shadow.position = shadow['offset'];


func _process(_delta):
	if Engine.editor_hint:
		if move_particle['active'] && !has_move_particle && get_node_or_null(move_particle['name']) == null:
			var h = move_particle['particle_scene'].instance();
			h.name = move_particle['name'];
			add_child(h);
			h.set_owner(self);
			has_move_particle = true;

		elif !move_particle['active'] && get_node_or_null(move_particle['name']) != null:
			get_node(move_particle['name']).queue_free();

		elif get_node_or_null(move_particle['name']) == null:
			has_move_particle = false;
		
		$Shadow.visible = shadow['active'];
		$Shadow.position = shadow['offset'];
		$Shadow.scale = shadow['scale'];



func emit_hit_particles(dir: int):
	$Hit_Particles.emit(dir);


func emit_move_particles(emitting: bool):
	if move_particle['active']:
		get_node(move_particle['name']).emitting = emitting;


func set_move_particles_dir(dir: Vector3):
	if move_particle['active']:
		get_node(move_particle['name']).process_material.direction = dir;


func shadow_grow_shrink():
	$Shadow.grow_shrink();

func stop_shadow_animation():
	$Shadow.stop_animation();
