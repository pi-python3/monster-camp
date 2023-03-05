extends Component


func setup():
	if !is_active: return;
	
	owner.add_to_group("Grounded");
	owner.set_collision_mask_bit(4, true); #set water collision to true
