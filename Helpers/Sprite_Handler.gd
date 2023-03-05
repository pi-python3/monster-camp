extends Node

onready var sprites = get_all_sprites(owner);
var previous_materials = [];


func get_all_sprites(node: Node):
	var sprites = [];
	
	for n in node.get_children():
		if (n is Sprite or n is AnimatedSprite) and !n.is_in_group("No_Flash"):
			sprites.append(n);
		if n.get_child_count() > 0:
			for s in get_all_sprites(n):
				sprites.append(s);
	return sprites;


func flash_on():
	for sprite in sprites:
		previous_materials.append(sprite.material);
		sprite.material = Preloads.FLASH_SHADER;


func flash_off():
	clear_shader();


func change_alpha():
	for sprite in sprites:
		previous_materials.append(sprite.material);
		sprite.material = Preloads.ALPHA_SHADER;


func alpha_off():
	clear_shader();


func change_shader(path: String):
	var shader = load(path);
	
	for sprite in sprites:
#		if weakref(sprite).get_ref() == null: continue;
		
		if shader.resource_path == Preloads.IDLE_OUTLINE_SHADER.resource_path:
			if "Eyes" == sprite.name:
#				previous_materials.append(sprite.material);
				sprite.material = Preloads.IDLE_SHADER;
				print("eye idle")
		elif shader == Preloads.MOVE_OUTLINE_SHADER:
			if "Eyes" == sprite.name:
				previous_materials.append(sprite.material);
				sprite.material = Preloads.MOVE_SHADER;
		previous_materials.append(sprite.material);
		sprite.material = shader;


func clear_shader():
	var i = 0;
	for sprite in sprites:
#		if weakref(sprite).get_ref() == null: continue;
		
		if previous_materials.size() == 0 || i >= previous_materials.size():
			sprite.material = null;
		else:
			sprite.material = previous_materials[i];
		i += 1;


func no_shader():
	for sprite in sprites:
#		if weakref(sprite).get_ref() != null:
		sprite.material = null;
