extends Node

func _process(_delta):
	if Hero_Vars.stamina <= 0: 
		owner.move_speed = owner.MAX_MOVE_SPEED / 2;
	else: 
		owner.move_speed = owner.MAX_MOVE_SPEED


func _on_Sword_Attack_lose_stamina(amount):
	Hero_Vars.stamina -= amount;
	
	$Recharge_Time.start();


func _on_Recharge_Time_timeout():
	Hero_Vars.stamina += 1;
	
	if Hero_Vars.stamina < Hero_Vars.max_stamina:
		$Recharge_Time.start();


func _on_Throw_Boomerang_lose_stamina(amount):
	_on_Sword_Attack_lose_stamina(amount);


func _on_Swim_lose_stamina(amount):
	_on_Sword_Attack_lose_stamina(amount);
