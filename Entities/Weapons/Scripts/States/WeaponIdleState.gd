extends State
class_name WeaponIdleState

@onready var weapon_controller : WeaponController = get_parent().get_parent()

func Enter():
	if !weapon_controller:
		return
	if weapon_controller.gun_sound:
		weapon_controller.gun_sound.stop()

func Update(_delta : float):
	if !weapon_controller:
		return
		
	if Input.is_action_just_pressed("fire_gun"):
		Transitioned.emit(self, "WeaponFiringState")
