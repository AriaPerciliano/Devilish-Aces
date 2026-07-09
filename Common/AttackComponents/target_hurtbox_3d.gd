extends Area3D
class_name TargetHurtbox3D

@export var health_component : TargetHealthComponent

func damage(attack : AttackComponent) -> void:
	if health_component:
		health_component.damage(attack)
