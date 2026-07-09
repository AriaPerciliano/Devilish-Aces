extends CanvasLayer

@onready var speed_label: Label = $"SpeedLabel"
@onready var altitude_label: Label = $AltitudeLabel
@onready var throttle_bar: ProgressBar = $ThrottleBar
@onready var state_1_label: Label = $State1Label
@onready var state_2_label: Label = $State2Label
@onready var camera_state: Label = $CameraState
@onready var aoa_label: Label = $AoALabel
@onready var yaw_aoa_label: Label = $YawAoALabel
@onready var player : AircraftController = get_tree().get_first_node_in_group("Player")
var targeting_component : TargetingComponent
var player_state_machine : StateMachine
var weapon_state_machine : StateMachine

func _ready() -> void:
	if !player:
		return
	targeting_component = player.targeting_component
	player_state_machine = player.player_state_machine
	weapon_state_machine = player.weapon_state_machine

func _physics_process(delta: float) -> void:
	if !player:
		return
	
	if player_state_machine:
		state_1_label.text = str(player_state_machine.current_state.name)
	if weapon_state_machine:
		state_2_label.text = str(weapon_state_machine.current_state.name)
	
	camera_state.text = "Lock: " + str(player.camera_locked)
	aoa_label.text = "AoA: " + str(int(player.angle_of_attack))
	yaw_aoa_label.text = "Pitch Control: " + str(player.test_pitch_control)
	
	speed_label.text = str(int(player.current_speed * GlobalValues.speed_mult))
	altitude_label.text = str(int(player.global_position.y * GlobalValues.world_distance))
	throttle_bar.value = remap(player.throttle, -1.0, 1.0, 0, 100)
