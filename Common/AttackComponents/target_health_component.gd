extends Node
class_name TargetHealthComponent

@export var max_health : float = 20.0
var current_health : float

func _ready() -> void:
	current_health = max_health

func damage(attack : AttackComponent) -> void:
	current_health -= attack.damage
	
	if current_health <= 0:
		get_parent().queue_free()
