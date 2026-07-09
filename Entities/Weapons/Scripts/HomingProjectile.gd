extends Area3D
class_name HomingProjectile

@export var proximity_fuse_collision : CollisionShape3D
const EXPLOSION_PARTICLE = preload("res://Common/Particles/Explosion/explosion_particle_a.tscn")

# Attributes
var velocity : Vector3
var damage : float
var turning_speed : float

# Prediction
var max_distance_predict : float
var min_distance_predict : float
var max_time_prediction : float
# Deviation
var deviation_amount : float
var deviation_speed : float

var target : Node3D
var is_locked : bool
var standard_prediction : Vector3
var deviated_prediction : Vector3

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	forward_accel(delta)
	if is_instance_valid(target) and is_locked:
		var distance = global_position.distance_to(target.global_position)
		var lead_time_percentage = inverse_lerp(min_distance_predict, max_distance_predict, distance)

		predict_movement(lead_time_percentage)
		add_deviation(lead_time_percentage)
		rotate_missile(delta)

func forward_accel(delta : float) -> void:
	global_position += -global_transform.basis.z * velocity.length() * delta

func predict_movement(lead_time_percentage : float) -> void:
	var prediction_time = lerp(0.0, max_time_prediction, lead_time_percentage)
	var target_vel = target.get("velocity") if target.get("velocity") else Vector3.ZERO
	standard_prediction = target.global_position + (target_vel * prediction_time)

func add_deviation(lead_time_percentage : float) -> void:
	var deviation = Vector3(cos((Time.get_ticks_msec() / 1000.0) * deviation_speed), 0.0, 0.0)
	
	var prediction_offset = (transform.basis * deviation) * deviation_amount * lead_time_percentage
	
	deviated_prediction = standard_prediction + prediction_offset

func rotate_missile(delta : float) -> void:
	var heading = deviated_prediction - global_position
	
	var direction = global_transform.looking_at(global_position + heading, Vector3.UP)
	global_transform = global_transform.interpolate_with(direction, turning_speed * delta)

func setup(vel : Vector3, dmg : float, turn_spd : float, tgt : Node3D, is_lock : bool) -> void:
	velocity = vel
	damage = dmg
	turning_speed = turn_spd
	is_locked = is_lock
	if is_instance_valid(tgt):
		target = tgt
	
func setup_homing(max_dist : float, min_dist : float, max_time : float, dev_amnt : float, dev_spd : float) -> void:
	max_distance_predict = max_dist
	min_distance_predict = min_dist
	max_time_prediction = max_time
	deviation_amount = dev_amnt
	deviation_speed = dev_spd

func explode() -> void:
	var explosion_particle = EXPLOSION_PARTICLE.instantiate() as HitParticle
	get_tree().current_scene.add_child(explosion_particle)
	explosion_particle.global_position = global_position
	if explosion_particle.has_method("particle_start"):
		explosion_particle.particle_start(3.0)

func _on_body_entered(body : Node3D) -> void:
	explode()
	queue_free()

func _on_area_entered(area : Area3D) -> void:
	if area is TargetHurtbox3D:
		var attack : AttackComponent = AttackComponent.new()
		attack.damage = damage
		area.damage(attack)
		attack.queue_free()
	explode()
	queue_free()
