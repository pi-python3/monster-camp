extends "Hero_State.gd"

var rng = RandomNumberGenerator.new();

const points = {
	"+": 2,
	"++": 3,
	"+++": 4
};

const var_points = {
	"can_sword_attack": points["++"],
	"can_navigate_to_monster": points["++"],
	"can_navigate_to_revenge_target": points["+++"],
	"stamina_percent_inverse": points["++"],
	"stamina_percent": points["++"],
	"no_stamina": points["+++"],
	"can_boomerang_throw": points["+"],
	"monster_too_close": points["+"],
	"health_percent_inverse": points["+"],
	"monster_in_sword_range": points["+++"],
	"distance_to_monster_percent": points["+++"],
	"can_see_monster": points["+"]
};

export(bool) var print_states = false;
export(float) var MONSTER_TOO_CLOSE_RANGE = 50;

var vars = {
	"can_sword_attack": false,
	"can_navigate_to_monster": false,
	"can_navigate_monsters": [],
	"can_navigate_to_revenge_target": false,
	"stamina_percent_inverse": 0,
	"stamina_percent": 0,
	"no_stamina": false,
	"can_boomerang_throw": false,
	"monster_too_close": false,
	"health_percent_inverse": 0,
	"monster_in_sword_range": false,
	"distance_to_monster_percent": 0,
	"can_see_monster": false
};
var vars_num = {};

var state_percents = {
	"idle": 0.01,
	"move": 0,
	"retreat": 0,
	"sword_attack": 0,
	"throw_boomerang": 0
};

func _ready():
	rng.randomize();


func update_vars():
	var closest_target = find_closest_target();
	
	vars["can_sword_attack"] = Hero_Vars.stamina > 0;
	
	vars["can_navigate_to_monster"] = false;
	vars["can_navigate_monsters"].clear();
	
	vars["can_navigate_to_revenge_target"] = false;
	if Hero_Vars.revenge_target != null:
		var target = get_closest_target_in_anchor(Hero_Vars.revenge_target);
		if weakref(target).get_ref() != null:
			$Move.path = $Move.create_path(owner.global_position, target.global_position);
			if $Move.path.size() > 0:
				if $Move.path[$Move.path.size()-1].distance_to(target.global_position) < 30:
					vars["can_navigate_to_revenge_target"] = true;
					vars["can_navigate_to_monster"] = true;
	
	if vars["can_navigate_to_monster"] == false:
		for t in Game_Vars.target_points:
			$Move.path = $Move.create_path(owner.global_position, t.global_position);
			if $Move.path.size() > 0:
#				if $Move.path[$Move.path.size()-1].distance_to(t.global_position) < 30:
				vars["can_navigate_to_monster"] = true;
				vars["can_navigate_monsters"].append(t);
	
	vars["stamina_percent_inverse"] = 1.0 - (Hero_Vars.stamina / Hero_Vars.max_stamina);
	
	vars["stamina_percent"] = Hero_Vars.stamina / Hero_Vars.max_stamina;
	
	vars["no_stamina"] = Hero_Vars.stamina <= 0;
	
	vars["can_boomerang_throw"] = Hero_Vars.boomerang_in_hand and (Hero_Vars.stamina > 0);
	
	vars["monster_too_close"] = false;
	if closest_target != null:
		vars["monster_too_close"] = owner.global_position.distance_to(closest_target.global_position) <= MONSTER_TOO_CLOSE_RANGE;

	vars["health_percent_inverse"] = 1.0 - (Hero_Vars.health / Hero_Vars.max_health);
	
	vars["monster_in_sword_range"] = false;
	if closest_target != null:
		vars["monster_in_sword_range"] = get_sword_in_range(closest_target);
	
	vars["distance_to_monster_percent"] = 0;
	if closest_target != null:
		vars["distance_to_monster_percent"] = clamp(owner.global_position.distance_to(closest_target.global_position), $Throw_Boomerang.min_throw_range, $Throw_Boomerang.max_throw_range) / $Throw_Boomerang.max_throw_range;
	
	vars["can_see_monster"] = false;
	get_sight_and_target();


func get_sword_in_range(closest_target):
	var hero_dir = Vector2(0,0);
	if Hero_Vars.facing == 'left': hero_dir = Vector2.LEFT;
	else: hero_dir = Vector2.RIGHT;
	var monster_dir = (closest_target.global_position - owner.global_position).normalized();
	var sword_in_range = false;
	
	if hero_dir.dot(monster_dir) > 0.5: #if monster in 60 degree radius of hero
		sword_in_range = owner.global_position.distance_to(closest_target.global_position) <= $Sword_Attack.attack_range;
	else: sword_in_range = owner.global_position.distance_to(closest_target.global_position) <= $Sword_Attack.attack_range * 0.8;
	
	return sword_in_range;


func get_sight_and_target():
	vars["can_see_monster"] = false;
	$Throw_Boomerang.target = null;
	
	var space_state = $Throw_Boomerang.get_world_2d().direct_space_state;
	$Line2D.clear_points();
	var visible_monsters = [];
	for m in Monster_Vars.monsters:
		var hit = $Throw_Boomerang.create_ray(owner.global_position, m.global_position, space_state, $Throw_Boomerang.collision_mask);
		if !hit: #if ray did hit anything
			vars["can_see_monster"] = true;
			visible_monsters.append(m);
	
	#check if boomerang has space to move
	var ray_dis := 120.0;
	var check_hit = $Throw_Boomerang.create_ray(owner.global_position, owner.global_position + (Vector2(-1, 1)*ray_dis), space_state, $Throw_Boomerang.collision_mask);
	if check_hit: #if ray hit anything
		vars["can_throw_boomerange"] = false;
		$Line2D.add_point(owner.global_position);
		$Line2D.add_point(owner.global_position + (Vector2(-1, 1)*ray_dis));
	check_hit = $Throw_Boomerang.create_ray(owner.global_position, owner.global_position + (Vector2(1, 1)*ray_dis), space_state, $Throw_Boomerang.collision_mask);
	if check_hit: #if ray hit anything
		vars["can_throw_boomerange"] = false;
		$Line2D.add_point(owner.global_position);
		$Line2D.add_point(owner.global_position + (Vector2(1, 1)*ray_dis));
	
	for m in visible_monsters:
		if $Throw_Boomerang.target == null:
			$Throw_Boomerang.target = weakref(m);
		elif owner.global_position.distance_to(m.global_position) < owner.global_position.distance_to($Throw_Boomerang.target.get_ref().global_position):
			$Throw_Boomerang.target = weakref(m);
			
		$Line2D.add_point(owner.global_position);
		$Line2D.add_point(m.global_position);
	
	if $Throw_Boomerang.target == null:
		$Throw_Boomerang.target = weakref(find_closest_target());


func _on_Wait_Time_timeout():
	if not owner.current_state.name in ["Idle", "Move", "Retreat"]: return;
	
	update_vars();
	vars_num = vars_to_num();
	
	calc_state_percents();

	if print_states:
		print("MOVE: " + str(round(state_percents["move"] * 100)) + "%");
		print("RETREAT: " + str(round(state_percents["retreat"] * 100)) + "%");
		print("SWORD ATTACK: " + str(round(state_percents["sword_attack"] * 100)) + "%");
		print("THROW BOOMERANG: " + str(round(state_percents["throw_boomerang"] * 100)) + "%");

	var highest_percent_state = "idle";
	for s in state_percents:
		if state_percents[s] > state_percents[highest_percent_state]:
			highest_percent_state = s;

	if highest_percent_state != owner.current_state.name.to_lower():
		owner.current_state.emit_signal("finished", highest_percent_state);


func calc_state_percents():
	state_percents["move"] = calc_event(
		"none",
		[
			"can_sword_attack",
			"can_navigate_to_revenge_target",
			"can_navigate_to_monster",
		]
	);
	
	state_percents["retreat"] = calc_event(
		"can_see_monster",
		[
#			"stamina_percent_inverse",
			"no_stamina",
			"can_boomerang_throw",
#			"monster_too_close",
#			"health_percent_inverse"
		]
	);
	
	state_percents["sword_attack"] = calc_event(
		"can_sword_attack",
		[
			"monster_in_sword_range"
		]
	);
	
	state_percents["throw_boomerang"] = calc_event(
		["can_boomerang_throw", "can_see_monster"],
		[
			"distance_to_monster_percent",
			"stamina_percent"
		]
	);


func vars_to_num():
	var vars_temp = vars.duplicate();
	for v in vars_temp:
		if vars_temp[v] is bool:
			vars_temp[v] = int(vars_temp[v]);
	
	return vars_temp;

func calc_points(var_name: String):
	return vars_num[var_name] * var_points[var_name];

func sum(values: Array):
	var sum:float = 0.0;
	for v in values:
		sum += calc_points(v);
	return sum;

func total_possible(values: Array):
	var total:float = 0.0;
	for v in values:
		total += var_points[v];
	return total;

func calc_event(necessary, values: Array, random_amount = 0.0):
	if necessary is Array:
		for n in necessary:
			if !vars[n]: return 0;
	
	elif necessary != "none":
		if !vars[necessary]: return 0;
	
	var sum:float = sum(values);
	var total_possible:float = total_possible(values);
	
	if random_amount == 0:
		return sum / total_possible;
	
	else:
		return (sum / total_possible) - (rng.randf() * random_amount);
