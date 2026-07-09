extends CharacterBody3D
class_name AircraftController

# The aircraft controller is the...well...aircraft controller.
# It handles the movement logic of the plane, and it has a child that is the actual brain of it

signal aircraft_model_ready()

@export_category("Debug")
@export var debug_aoa_lines : bool = false

@export_category("References")
@export var current_aircraft : Aircraft # Resource for the Aircraft's settings
@export var weapon_state_machine : StateMachine
@export var player_controller : PlayerController # Leave empty unless this is the player
@onready var model_parent: Node3D = $ModelParent

var current_aircraft_model : AircraftModel

@export_category("Speed Factors")
@export var gravity_factor : float = 1.0 # How much the gravity affects the plane

# Speed
var throttle : float = 0.0
var throttle_amount : float = 1.0
var throttle_smooth : float = 2.0 # not interested in making a different one for each plane
var current_speed : float = 0.0
var forward_velocity : Vector3 = Vector3.ZERO

# Angle of Attack
var angle_of_attack : float = 0.0
var yaw_angle_of_attack : float = 0.0
var local_velocity : Vector3 = Vector3.ZERO

# Aircraft Rotation
var pitch_speed : float
var roll_speed : float
var yaw_speed : float

# Input
var pitch_input : float = 0.0
var roll_input : float = 0.0
var yaw_input : float = 0.0
var throttle_input : float = 0.0

func _ready() -> void:
	if current_aircraft:
		spawn_aircraft_model()
	current_speed = current_aircraft.idle_speed
	
func _physics_process(delta: float) -> void:
	calculate_aoa()
	update_thrust(delta)
	update_velocity(delta)
	update_throttle(delta)
	aircraft_rotation(delta)
	current_aircraft_model.update_aircraft_input(pitch_input, roll_input, yaw_input, throttle)
	
	move_and_slide()

# Will spawn the aircraft model from the Aircraft Resource
func spawn_aircraft_model() -> void:
	if current_aircraft_model:
		current_aircraft_model.queue_free()
	
	if current_aircraft.aircraft_model:
		current_aircraft_model = current_aircraft.aircraft_model.instantiate()
		model_parent.add_child(current_aircraft_model)
		current_aircraft_model.global_position = self.global_position
		aircraft_model_ready.emit()
		
#region Speed and Thrust
## Combine thrust, gravity and drag's into a single value and then add it to the current speed
## Also clamps the current speed to the min and max values
func update_thrust(delta : float) -> void:
	var speed_delta : float = 0.0
	speed_delta += calculate_thrust(delta)
	speed_delta += calculate_gravity(delta)
	speed_delta += calculate_induced_drag(delta)
	
	current_speed += speed_delta
	current_speed = clamp(current_speed, current_aircraft.min_speed, current_aircraft.top_speed)

## Eases the throttle's input
func calculate_thrust(delta : float) -> float:
	var speed_reciprocal : float = 1.0 / current_aircraft.max_speed
	
	if throttle > 0.3:
		var accel_ease : float = (current_aircraft.max_speed - current_speed) * speed_reciprocal
		return throttle * current_aircraft.accel * accel_ease * delta
	elif throttle < -0.3:
		var decel_ease : float = (current_speed - current_aircraft.min_speed) * speed_reciprocal
		return throttle * current_aircraft.decel * decel_ease * delta
	else:
		# returns to the idle speed if throttle input is zero
		var target_speed : float = move_toward(current_speed, current_aircraft.idle_speed, current_aircraft.idle_recovery * delta)
		return target_speed - current_speed

## Diving = gain speed, climbing = lose
func calculate_gravity(delta : float) -> float:
	return transform.basis.z.y * gravity_factor * delta

## High AoA causes speed loss
func calculate_induced_drag(delta : float) -> float:
	return -abs(angle_of_attack) * current_aircraft.induced_drag_coefficient * delta

func update_velocity(delta : float) -> void:
	var forward = -transform.basis.z
	var target_velocity = forward * current_speed
	velocity = velocity.lerp(target_velocity, current_aircraft.alignment_rate * delta)

# This will get the throttle input and lerp in based on the throttle amount
func update_throttle(delta : float) -> void:
	#var weight : float = 1.0 - exp(-throttle_amount * delta)
	throttle = lerp(throttle, throttle_input, throttle_smooth * delta)

#endregion

#region Rotation and AoA
# This lil guy will get the different between the player nose and player forward movement
func calculate_aoa() -> void:
	local_velocity = global_basis.inverse() * velocity
	
	if debug_aoa_lines:
		DebugDraw3D.draw_arrow(self.global_position, self.global_position + velocity, Color.BLUE, 2.0, true)
		DebugDraw3D.draw_arrow(self.global_position, self.global_position - global_basis.z * 20.0, Color.RED, 2.0, true)
	
	if local_velocity.length_squared() < 0.1:
		angle_of_attack = 0.0
		yaw_angle_of_attack = 0.0
		return
	
	angle_of_attack = rad_to_deg(atan2(-local_velocity.y, -local_velocity.z))
	yaw_angle_of_attack = rad_to_deg(atan2(local_velocity.x, -local_velocity.z))

# Will handle all of the aircraft's rotations, like pitch and stuff
func aircraft_rotation(delta : float) -> void:
	# This will add a speed based mult to the pitch. Higher speeds mean less control over your pitch
	var speed_factor : float = remap(current_speed, current_aircraft.idle_speed, current_aircraft.max_speed, 0.0, 1.0)
	speed_factor = clamp(speed_factor, 0.0, 1.0)
	var pitch_control : float = lerp(1.0, 0.6, speed_factor)
	
	# Apply a little bit of smoothness to the pitch
	pitch_speed = lerp(pitch_speed, pitch_input, current_aircraft.pitch_stability * delta)
	roll_speed = lerp(roll_speed, roll_input, current_aircraft.roll_stability * delta)
	yaw_speed = lerp(yaw_speed, yaw_input, current_aircraft.yaw_stability * delta)
	
	var final_pitch_speed = current_aircraft.pitch_speed * pitch_control
	
	rotate_object_local(Vector3.RIGHT, pitch_speed * final_pitch_speed * delta)
	rotate_object_local(Vector3.FORWARD, roll_speed * current_aircraft.roll_speed * delta)
	rotate_object_local(Vector3.UP, yaw_speed * current_aircraft.yaw_speed * delta)
#endregion
