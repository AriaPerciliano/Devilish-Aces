extends Node
class_name PlayerController

@export_category("References")
@export var aircraft_controller : AircraftController
@export var camera_parent : Node3D
@export var camera_holder : Node3D
@export var player_state_machine : StateMachine
@export var crosshair_marker : Node3D
@export var boresight_marker : Node3D
@export var crosshair_raycast: RayCast3D
@onready var main_camera : MainCamera = get_tree().get_first_node_in_group("MainCamera")

@export_category("Camera Settings")
@export var debug_stop : bool = false
@export var main_camera_holder : Node3D
@export var cockpit_camera_holder : Node3D
@export var dogfight_camera_holder : Node3D
@export var enable_dogfight_cam : bool = true

# Aircraft Rotation
var pitch_input : float = 0.0
var roll_input : float = 0.0
var yaw_input : float = 0.0
var throttle_input : float = 0.0

# Camera
var camera_3d : Camera3D
var current_camera_holder : Node3D
var dogfight_cam_timer : float = 0.0
var camera_axis_changed = false
var camera_input : Vector3 = Vector3.ZERO
# Camera Lock
var lock_on_time : float = 0.0
var lock_on_threshold : float = 0.2
var camera_locked : bool = false

func _ready() -> void:
	current_camera_holder = main_camera_holder

func _process(delta: float) -> void:
	camera_look(delta)
	dogfight_camera(delta)

func _physics_process(delta: float) -> void:
	handle_throttle()
	handle_rotation()
	
	if debug_stop:
		aircraft_controller.global_position.x = 0.0
		aircraft_controller.global_position.y = 10.0
		aircraft_controller.global_position.z = 0.0
		aircraft_controller.global_rotation.y = 0.0
		aircraft_controller.global_rotation.z = 0.0
		camera_holder.position = Vector3.ZERO
		camera_holder.global_rotation.x = 0.0
		camera_holder.global_rotation.z = 0.0

func handle_throttle() -> void:
	var accel_input = Input.get_action_strength("throttle_up")
	var brake_input = Input.get_action_strength("throttle_down")
	throttle_input = accel_input - brake_input
	aircraft_controller.throttle_input = self.throttle_input

func handle_rotation() -> void:
	pitch_input = Input.get_axis("pitch_down", "pitch_up")
	roll_input = Input.get_axis("roll_left", "roll_right")
	yaw_input = Input.get_axis("yaw_right", "yaw_left")
	
	aircraft_controller.pitch_input = self.pitch_input
	aircraft_controller.roll_input = self.roll_input
	aircraft_controller.yaw_input = self.yaw_input

#region Camera
func camera_look(delta : float) -> void:
	if current_camera_holder != main_camera_holder:
		return
	
	camera_input= Vector3(
		Input.get_axis("camera_left", "camera_right"),
		Input.get_axis("camera_up", "camera_down"), 0.0)
	var look_back = Input.is_action_pressed("camera_back")

	var target_yaw = -camera_input.x * deg_to_rad(90.0)
	var target_pitch = -camera_input.y * deg_to_rad(90.0)
	camera_parent.rotation.y = lerp_angle(camera_parent.rotation.y, target_yaw, 10.0 * delta)
	camera_parent.rotation.x = lerp_angle(camera_parent.rotation.x, target_pitch, 10.0 * delta)
	
	if camera_input != Vector3.ZERO:
		camera_axis_changed = true
	elif camera_input == Vector3.ZERO and look_back:
		camera_axis_changed = true
		camera_parent.rotation.y = deg_to_rad(180.0)
	else:
		camera_axis_changed = false

func dogfight_camera(delta : float) -> void:
	if !enable_dogfight_cam or !dogfight_camera_holder:
		return
	
	if Input.is_action_pressed("fire_gun") and crosshair_raycast.is_colliding():
		dogfight_cam_timer = 0.5
		
		camera_parent.rotation.y = 0.0
		camera_parent.rotation.x = 0.0
		main_camera.add_screen_shake(0.8, delta)
		current_camera_holder = dogfight_camera_holder
	elif Input.is_action_pressed("fire_gun") and !crosshair_raycast.is_colliding():
		if dogfight_cam_timer > 0:
			dogfight_cam_timer -= delta
			main_camera.add_screen_shake(0.8, delta)
		if dogfight_cam_timer <= 0:
			current_camera_holder = main_camera_holder
	else:
		current_camera_holder = main_camera_holder
#endregion
