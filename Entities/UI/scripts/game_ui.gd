extends CanvasLayer
class_name GameUI

@onready var player : PlayerController = get_tree().get_first_node_in_group("PlayerController")
@onready var camera : MainCamera = get_tree().get_first_node_in_group("MainCamera")
var targeting_component : TargetingComponent
var player_state_machine : StateMachine
var weapon_state_machine : StateMachine




@export_category("Crosshair & Boresight")
@export var crosshair : Control
@export var crosshair_texture : TextureRect
@export var boresight : Control
@export var boresight_texture : TextureRect
@export var hit_indicator : TextureRect

@export_category("UI Settings")
@export var enable_compass : bool = true
@export var enable_altimeter : bool = true
@export var enable_speedometer : bool = true
@export var enable_attitude_meter : bool = true

@export_category("Compass")
@export var compass : Control
@export var compass_strip : TextureRect
@export var compass_north_offset : float = -180.0

@export_category("Speed & Altitude")
@export var speedometer : Meter
@export var altimeter : Meter
@export var throttle_meter : ThrottleMeter
@export var attitude_meter : Control
@export var speed_lines : ColorRect

@export_category("Debug")
@export var debug : bool = false
@export var debug_ui : Control
@export var aoa_label : Label

func _process(delta: float) -> void:
	#if speed_label and alt_label:
	#	speed_label.text = str(int(player.aircraft_controller.current_speed * GlobalValues.speed_mult))
	#	alt_label.text = str(int(player.aircraft_controller.global_position.y * GlobalValues.world_distance))
	
	if speedometer:
		speedometer.update_meter(player.aircraft_controller.current_speed * GlobalValues.speed_mult, 1000.0, 0.0)
	if altimeter:
		altimeter.update_meter(player.aircraft_controller.global_position.y * GlobalValues.world_distance, 1000.0, 0.0)
		altimeter.update_secondary_needle(player.aircraft_controller.global_position.y * GlobalValues.world_distance, 10000.0, 0.0)
	if throttle_meter:
		throttle_meter.update_throttle(player.aircraft_controller.throttle * 100, 100.0, -100.0)
	
	update_speed_lines()
	update_crosshair()
	update_ui_elements()
	update_compass()
	update_debug()

# This will add the crosshair to the screen, based on a crosshair marker inside the player node
func update_crosshair() -> void:
	if !camera:
		return
	
	var screen_pos : Vector2 = camera.unproject_position(player.crosshair_marker.global_position)
	var boresight_pos : Vector2 = camera.unproject_position(player.boresight_marker.global_position)
	var is_behind = camera.is_position_behind(player.crosshair_marker.global_position)
	
	crosshair.visible = !is_behind
	#boresight.visible = !is_behind
	crosshair.position = screen_pos
	#boresight.position = boresight_pos
	
	var hit_tween : Tween = create_tween()
	if player.crosshair_raycast.is_colliding():
		hit_tween.tween_property(hit_indicator, "scale", Vector2(1.0, 1.0), 0.1)
		hit_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		hit_tween.tween_property(hit_indicator, "scale", Vector2(0.0, 0.0), 0.1)
		hit_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		
#region Toggleable UI Elements
func update_ui_elements() -> void:
	compass.visible = enable_compass
	altimeter.visible = enable_altimeter
	speedometer.visible = enable_speedometer
	attitude_meter.visible = enable_attitude_meter
	
func update_compass() -> void:
	if !camera or !compass_strip or !compass:
		return
	
	var forward = -camera.global_transform.basis.z
	var heading_angle : float = rad_to_deg(atan2(forward.x, -forward.z))
	var heading = fposmod(heading_angle, 360.0)
	
	var window_center : float = compass.size.x / 2.0
	var compass_offset : float = -heading + window_center + compass_north_offset
	
	compass_strip.position.x = compass_offset

#endregion
	
func update_speed_lines() -> void:
	var speed_lines_intensity = remap(player.aircraft_controller.current_speed, (player.aircraft_controller.current_aircraft.idle_speed), player.aircraft_controller.current_aircraft.top_speed, 0.0, 0.6)
	speed_lines_intensity = clamp(speed_lines_intensity, 0.0, 0.6)
	speed_lines.material.set_shader_parameter("line_density", speed_lines_intensity)
	
func update_debug() -> void:
	debug_ui.visible = debug
	if !debug:
		return
	aoa_label.text = "AoA: " + str(int(player.aircraft_controller.angle_of_attack))
