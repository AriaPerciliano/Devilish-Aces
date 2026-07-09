extends Node3D
class_name AircraftModel

@export var muzzles : Array[Marker3D]


@export_category("Aircraft Parts")
@export var left_aileron : Node3D
@export var right_aileron : Node3D
@export var left_elevator : Node3D
@export var right_elevator : Node3D
@export var rudder : Node3D

@export var pitch_max_angles : float = 25.0
@export var roll_max_angles : float = 15.0
@export var yaw_max_angles : float = 15.0
@export var lerp_speed : float = 10.0

@export_category("Aircraft Sound")
@export var engine_sound_low : AudioStreamPlayer
@export var engine_sound_full : AudioStreamPlayer
@export var gun_sound : AudioStreamPlayer
@export var engine_smooth : float = 0.4
@export var low_pitch_range : Vector2 = Vector2(1.0, 1.2)
@export var full_pitch_range : Vector2 = Vector2(0.80, 1.0)
@export var max_vol_db : float = -5.0
@export var min_vol_db : float = -15.0

var pitch_input : float
var roll_input : float
var yaw_input : float
var throttle_input : float

var engine_throttle : float

func _ready() -> void:
	if engine_sound_low:
		engine_sound_low.play()
	if engine_sound_full:
		engine_sound_full.play()

func _process(delta: float) -> void:
	animate_aircraft(delta)
	aircraft_sound(delta)

func update_aircraft_input(pitch : float, roll : float, yaw : float, throttle : float) -> void:
	pitch_input = pitch
	roll_input = roll
	yaw_input = yaw
	throttle_input = throttle

func aircraft_sound(delta : float) -> void:
	if !engine_sound_low or !engine_sound_full:
		return
	
	var throttle_amount : float = clampf(throttle_input, 0.0, 1.0)	
	engine_throttle = move_toward(engine_throttle, throttle_amount, engine_smooth * delta)
	
	var low_volume : float = lerp(max_vol_db, min_vol_db, engine_throttle)
	var full_volume : float = lerp(min_vol_db, max_vol_db, engine_throttle)
	
	engine_sound_low.volume_db = low_volume
	engine_sound_full.volume_db = full_volume
	engine_sound_low.pitch_scale = lerp(low_pitch_range.x, low_pitch_range.y, engine_throttle)
	engine_sound_full.pitch_scale = lerp(full_pitch_range.x, full_pitch_range.y, engine_throttle)
	
func animate_aircraft(delta : float) -> void:
	var pitch_max_deg = deg_to_rad(pitch_max_angles)
	var roll_max_deg = deg_to_rad(roll_max_angles)
	var yaw_max_deg = deg_to_rad(yaw_max_angles)
	
	# Pitch Animation
	if left_elevator:
		left_elevator.rotation.x = lerp(left_elevator.rotation.x, -pitch_input * pitch_max_deg, lerp_speed * delta)
	if right_elevator:
		right_elevator.rotation.x = lerp(right_elevator.rotation.x, -pitch_input * pitch_max_deg, lerp_speed * delta)
	
	# Roll Animation
	if left_aileron:
		left_aileron.rotation.x = lerp(left_aileron.rotation.x, roll_input * roll_max_deg, lerp_speed * delta)
	if right_aileron:
		right_aileron.rotation.x = lerp(right_aileron.rotation.x, -roll_input * roll_max_deg, lerp_speed * delta)
	
	# Yaw Animation
	if rudder:
		rudder.rotation.z = lerp(rudder.rotation.z, -yaw_input * yaw_max_deg, lerp_speed * delta)

func start_gun_sound() -> void:
	if !gun_sound:
		return
	if !gun_sound.playing:
		gun_sound.play()

func stop_gun_sound() -> void:
	if !gun_sound:
		return
	gun_sound.stop()
