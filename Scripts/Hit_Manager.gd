extends Node


func get_damage_type(source):
	if source.is_in_group("Projectile"):
		return "projectile";
	elif source.is_in_group("Hero"):
		return "hero";
	elif source.is_in_group("Monster"):
		return "monster";
	elif source.is_in_group("Interactable"):
		return "universal";
	elif source.get_node_or_null("Hitbox") != null:
		if source.get_node("Hitbox").is_in_group("Projectile_Hitbox"):
			return "projectile";
	else:
		return "universal";


func get_hit_data(target, source, is_hero := false, protect_source := false):
	var source_type = get_damage_type(source);
	var damage := 0;
	var stun := false;
	var hit_strength := Vector2(1,0);
	
	if source_type == "monster":
		if is_hero: Hero_Vars.revenge_target = source;
		if protect_source: source.protected_from.append(target);
		
		if source.is_in_group("Directional_Attacker"):
			hit_strength = source.attack_direction;
		elif source.is_in_group("Z_Axis_Attacker"):
			hit_strength = (target.global_position - source.global_position).normalized();
		else:
			hit_strength.x = -bool2int(source.get_node("Sprite").get_flip());
		
		damage = source.damage;
#		damage = Game_Balance.monster_data.get(source.monster_type)['damage'];

		if source.is_in_group("Stun_Attack"): 
			stun = true;
		elif source.get("stun") != null: stun = source.stun;
	
	elif source_type == "hero":
		damage = Hero_Vars.sword_damage;
		hit_strength.x = bool2int(Hero_Vars.facing == "right");
	
	elif source_type == "projectile":
		if weakref(source.shooter).get_ref() != null:
			if is_hero: Hero_Vars.revenge_target = source.shooter;
			if protect_source: source.shooter.protected_from.append(target);
			
			if source.get("attack_direction") != null:
				hit_strength = source.attack_direction;
			else:
				hit_strength = -target.global_position.direction_to(source.global_position);
				print("NO 'ATTACK DIRECTION' VARIABLE IN <" + source.name + "> OBJECT!!!!!!!!!!");
			
			if source.shooter.is_in_group("Monster"):
				damage = source.shooter.damage;
#				damage = Game_Balance.monster_data.get(source.shooter.monster_type)['damage'];
			elif source.shooter.is_in_group("Hero"):
				damage = Game_Balance.get_equipment(source.equipment_name, Level_Handler.level)['damage'];
		
		else:
			print("NO REFERENCE TO SHOOTER OF <" + source.name + ">!!!!!!!!!!!");
		
		source.destroy();
		
	else:
		hit_strength = -target.global_position.direction_to(source.global_position);
		damage = source.damage;
		if source.get("stun") != null: stun = source.stun;
	
	if hit_strength == Vector2.ZERO: hit_strength = Vector2(1,0);
	hit_strength = hit_strength.normalized();
	
	return {
		'damage': damage,
		'stun': stun,
		'hit_strength': hit_strength
		};


func bool2int(boolean: bool) -> int:
	return ( int(boolean) * 2 ) - 1
