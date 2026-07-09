extends Control
class_name AttitudeMeter

@onready var player : PlayerController = get_tree().get_first_node_in_group("PlayerController")
@export var attitude_meter : TextureRect
@export var artificial_horizon : TextureRect
@export var pitch_zero_offset : float = -64.0

func _process(delta: float) -> void:
	update_artificial_horizon()

func update_artificial_horizon() -> void:
	if !player or !artificial_horizon or !attitude_meter:
		return
	
	var forward = -player.aircraft_controller.global_transform.basis.z
	var horizontal_lenght : float = Vector2(forward.x, forward.z).length()
	var pitch_angle : float = rad_to_deg(atan2(-forward.y, horizontal_lenght))
	
	var meter_center : float = attitude_meter.size.y / 2.0
	var pixels_per_deg : float = attitude_meter.texture.get_height() / 180.0
	var attitude_offset : float = -pitch_angle * pixels_per_deg + meter_center + pitch_zero_offset
	
	artificial_horizon.position.y = attitude_offset
	
	var basis : Basis = player.aircraft_controller.global_transform.basis
	var roll_angle : float = rad_to_deg(atan2(basis.x.y, basis.y.y))
	artificial_horizon.pivot_offset = artificial_horizon.size / 2.0
	artificial_horizon.rotation = deg_to_rad(roll_angle)

	var mask_center_local : Vector2 = attitude_meter.size / 2.0
	var mask_center_screen : Vector2 = attitude_meter.get_global_transform().origin + mask_center_local
	var mat : ShaderMaterial = artificial_horizon.material
	mat.set_shader_parameter("mask_screen_center", mask_center_screen)
