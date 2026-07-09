extends Node
class_name TargetingComponent

signal target_changed(new_target : Node3D)

var targets_in_range : Array[Node3D] = []
var locked_target : Node3D = null
var next_target : Node3D = null
var lock_range = 700

@export var player : AircraftController

func _process(delta: float) -> void:
	if !player:
		return
	
	if !is_instance_valid(locked_target):
		if next_target == null:
			locked_target = null
			target_changed.emit(null)
		# This will make the next target be automatically locked. May not be a good idea tho. Tests needed
		#else:
		#	select_next_target()
	
	if !is_instance_valid(next_target):
		next_target = null
	
	scan_targets()
	update_next_target()

func scan_targets() -> void:
	targets_in_range.clear()
	
	# Just an extra check to be sure the target will unlock once it gets out of range
	if is_instance_valid(locked_target):
		var distance = player.global_position.distance_to(locked_target.global_position)
		if distance > lock_range:
			locked_target = null
			target_changed.emit(null)
	
	# All enemies and Target Structures should be put in the Target Group
	for target in get_tree().get_nodes_in_group("Target"):
		# More checks to keep the game safe
		if !is_instance_valid(target):
			continue
		
		var distance = player.global_position.distance_to(target.global_position)
		if distance < lock_range:
			targets_in_range.append(target)

func select_next_target() -> void:
	var camera : Camera3D = get_viewport().get_camera_3d()
	var screen_center = get_viewport().get_visible_rect().size / 2
	
	if !camera or targets_in_range.is_empty():
		locked_target = null
		target_changed.emit(null)
		return
	
	var valid_targets = targets_in_range.filter(func(target):
		return is_instance_valid(target)
		)
	
	#var next_targets = targets_in_range.filter(func(target):
	var next_targets = valid_targets.filter(func(target):
		return target != locked_target and !camera.is_position_behind(target.global_position) 
		)
	
	if next_targets.is_empty():
		if locked_target:
			return
		#next_targets = targets_in_range
		next_targets = valid_targets
	
	next_targets.sort_custom(func(a, b):
		var pos_a = screen_center.distance_to(camera.unproject_position(a.global_position))
		var pos_b = screen_center.distance_to(camera.unproject_position(b.global_position))
		return pos_a < pos_b
	)
	
	locked_target = next_targets[0]
	target_changed.emit(locked_target)

func update_next_target() -> void:
	var camera : Camera3D = get_viewport().get_camera_3d()
	var screen_center = get_viewport().get_visible_rect().size / 2

	var next_targets = targets_in_range.filter(func(target):
		return target != locked_target and !camera.is_position_behind(target.global_position)
	)
	
	if next_targets.is_empty():
		next_target = null
		return
	
	next_targets.sort_custom(func(a, b):
		var pos_a = screen_center.distance_to(camera.unproject_position(a.global_position))
		var pos_b = screen_center.distance_to(camera.unproject_position(b.global_position))
		return pos_a < pos_b
	)
	
	next_target = next_targets[0]
