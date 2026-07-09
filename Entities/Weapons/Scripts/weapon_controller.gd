extends Node
class_name WeaponController

@export_category("References")
@export var current_weapon : Weapon
@export var aircraft_controller : AircraftController
@export var gun_sound : AudioStreamPlayer
@export var gun_stop_sound : AudioStreamPlayer



var can_fire : bool = true
var muzzle_particles : Array[CPUParticles3D] = []
var current_muzzle_index : int = 0

@onready var camera : MainCamera = get_tree().get_first_node_in_group("MainCamera")
const muzzle_flash = preload("res://Common/Particles/MuzzleFlash/MuzzleFlashA.tscn")

func _ready() -> void:
	if aircraft_controller:
		aircraft_controller.aircraft_model_ready.connect(_on_aircraft_model_ready)

func shoot() -> void:
	if can_fire:
		can_fire = false
		shoot_projectile()
		
		# Shuffle between the zuzzles
		var muzzle_count = aircraft_controller.current_aircraft_model.muzzles.size()
		if muzzle_count > 0:
			current_muzzle_index = (current_muzzle_index + 1) % muzzle_count
		
		get_tree().create_timer(current_weapon.fire_rate).timeout.connect(_firerate_timeout)

func shoot_projectile() -> void:
	if !current_weapon.projectile_scene or aircraft_controller.current_aircraft_model.muzzles.is_empty():
		return
	
	# Pre-Setup
	var muzzle = aircraft_controller.current_aircraft_model.muzzles[current_muzzle_index]
	var particle = muzzle_particles[current_muzzle_index]
	var projectile = current_weapon.projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	
	# Projectile Setup
	projectile.global_position = muzzle.global_position
	var forward = -muzzle.global_transform.basis.z
	var final_velocity = (forward * current_weapon.projectile_speed) + aircraft_controller.velocity
	projectile.look_at(projectile.global_position + forward, muzzle.global_transform.basis.y)
	projectile.setup(final_velocity, current_weapon.damage)
	
	# Particle Setup
	particle.restart()
	particle.emitting = true
	
func _firerate_timeout() -> void:
	can_fire = true

func _on_aircraft_model_ready() -> void:
	update_muzzle_flash()

func update_muzzle_flash() -> void:
	if !aircraft_controller.current_aircraft_model:
		return
	
	for particle in muzzle_particles:
		particle.queue_free()
	muzzle_particles.clear()
	
	for muzzle in aircraft_controller.current_aircraft_model.muzzles:
		var particle = muzzle_flash.instantiate()
		muzzle.add_child(particle)
		
		particle.global_position = muzzle.global_position
		particle.lifetime = current_weapon.fire_rate * 1.5
		
		muzzle_particles.append(particle)
