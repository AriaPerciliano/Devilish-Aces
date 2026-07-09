extends Resource
class_name Weapon

@export_category("Weapon Settings")
@export var weapon_name : String = "Weapon"
@export var shooting_sfx : AudioStream

@export_category("Weapon Attributes")
@export var fire_rate : float = 0.08
@export var damage : float = 2.0
@export var overheat_limit : float = 10.0
@export var heat_amount : float = 0.2

@export_category("Projectile Settings")
@export var projectile_scene : PackedScene
@export var projectile_speed : float = 200.0
