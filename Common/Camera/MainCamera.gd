extends Camera3D
class_name MainCamera

var camera_holder : Node3D
var player : AircraftController

# Speed Based Screen Shake
@export var enable_screen_shake : bool = true
const MAX_SCREEN_SHAKE : float = 0.05
var noise : FastNoiseLite = FastNoiseLite.new()
var noise_i : float = 0.0

func _ready() -> void:
	top_level = true
	player = get_tree().get_first_node_in_group("Player")
	camera_holder = player.player_controller.current_camera_holder
	
	noise.seed = randi()
	noise.frequency = 0.1
	
	if camera_holder:
		global_transform = camera_holder.global_transform

func _process(delta: float) -> void:
	var speed_shake_intensity = remap(player.current_speed, (player.current_aircraft.top_speed - 2.0), player.current_aircraft.top_speed, 0.0, 0.25)
	speed_shake_intensity = clamp(speed_shake_intensity, 0.0, 0.25)
	add_screen_shake(speed_shake_intensity, delta)
	update_camera_holder()

func _physics_process(delta: float) -> void:
	if !camera_holder:
		return
	var current_quaternion = global_transform.basis.get_rotation_quaternion()
	var target_quaternion = camera_holder.global_transform.basis.get_rotation_quaternion()
	var interpolated_quaternion = current_quaternion.slerp(target_quaternion, 8.0 * delta)

	if !player.player_controller.camera_axis_changed and !player.player_controller.camera_locked:
		player.player_controller.camera_holder.position.z = 3.5 # Sweetspot is 3.5
		global_position = lerp(global_position, camera_holder.global_position, 20.0 * delta)
		#global_position.x = lerp(global_position.x, camera_holder.global_position.x, 20.0 * delta)
		#global_position.y = lerp(global_position.y, camera_holder.global_position.y, 20.0 * delta)
		#global_position.z = lerp(global_position.z, camera_holder.global_position.z, 20.0 * delta)
		global_basis = Basis(interpolated_quaternion)
	else:
		player.player_controller.camera_holder.position.z = 5.5
		global_position = camera_holder.global_position
		global_basis = Basis(camera_holder.global_transform.basis.get_rotation_quaternion())
	if player.player_controller.camera_axis_changed and player.player_controller.camera_locked:
		player.player_controller.camera_holder.position.z = 3.5

func update_camera_holder() -> void:
	if camera_holder != player.player_controller.current_camera_holder:
		camera_holder = player.player_controller.current_camera_holder

func add_screen_shake(intensity : float, delta : float) -> void:
	if intensity > 0.01:
		noise_i += delta * 100.0
		var shake_amount = intensity * MAX_SCREEN_SHAKE
		h_offset = noise.get_noise_2d(noise_i, 0) * shake_amount
		v_offset = noise.get_noise_2d(0, noise_i) * shake_amount
	else:
		h_offset = lerp(h_offset, 0.0, 10.0 * delta)
		v_offset = lerp(v_offset, 0.0, 10.0 * delta)
