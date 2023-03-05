extends "../Components/Component.gd"


func setup():
	if !is_active: return;
	
	owner.add_to_group("Flying");
	owner.set_collision_mask_bit(4, false); #set water collision to false
#	owner.z_index -= 5;
