extends Resource
class_name Aircraft

@export_category("Aircraft Settings")
@export var aircraft_name : String = "A-29 Super Tucano"
@export var aircraft_model : PackedScene

@export_category("Speed Stats")
@export var max_speed_kmh : float = 630.0
@export var top_speed_kmh : float = 590.0
@export var idle_speed_kmh : float = 400.0
@export var stall_warning_kmh : float = 184.0
@export var stall_speed_kmh : float = 148.0
@export var min_speed_kmh : float = 100.0
@export var accel_kmh : float = 60.0
@export var decel_kmh : float = 60.0
@export var idle_recovery_kmh : float = 20.0

@export_category("Pitch & Roll Settings")
@export var pitch_speed : float = 1.0
@export var roll_speed : float = 3.0
@export var yaw_speed : float = 0.15

# Those control how fast the rotations will recover
@export var pitch_stability : float = 3.0
@export var roll_stability : float = 3.0
@export var yaw_stability : float = 4.0

# G-Limit
@export var positive_g_limit : float = 7.0
@export var negative_g_limit : float = -3.5

# How long does it take for velocity to catch up to the airplane's nose direction
@export var alignment_rate : float = 3.5
@export var induced_drag_coefficient : float = 0.03

## Speed KM/h to Engine Speed Conversion
var max_speed : float:
	get: return max_speed_kmh / GlobalValues.speed_mult
var top_speed : float:
	get: return top_speed_kmh / GlobalValues.speed_mult
var idle_speed : float:
	get: return idle_speed_kmh / GlobalValues.speed_mult
var stall_warning : float:
	get: return stall_warning_kmh / GlobalValues.speed_mult
var stall_speed : float:
	get: return stall_speed_kmh / GlobalValues.speed_mult
var min_speed : float:
	get: return min_speed_kmh / GlobalValues.speed_mult
var accel : float:
	get: return accel_kmh / GlobalValues.speed_mult
var decel : float:
	get: return decel_kmh / GlobalValues.speed_mult
var idle_recovery : float:
	get: return idle_recovery_kmh / GlobalValues.speed_mult
