extends State
class_name WeaponFiringState

@onready var weapon_controller : WeaponController = get_parent().get_parent()

func Enter():
	if !weapon_controller:
		return
	weapon_controller.shoot()
	if weapon_controller.gun_sound:
		weapon_controller.gun_sound.play()
	
func Physics_Update(_delta : float):
	if Input.is_action_pressed("fire_gun"):
		weapon_controller.shoot()
	else:
		if weapon_controller.gun_sound:
			weapon_controller.gun_sound.stop()
		if weapon_controller.gun_stop_sound:
			weapon_controller.gun_stop_sound.play()
		Transitioned.emit(self, "WeaponIdleState")
