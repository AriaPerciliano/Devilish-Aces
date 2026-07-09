extends Control
class_name Meter

@export_category("Meter Settings")
@export var needle : TextureRect
@export var odometer : Odometer
@export var value_label : Label
@export var min_angle : float = 0.0
@export var max_angle : float = 360.0
@export var label_max_characters : int = 4
@export_group("Secondary Needle")
@export var secondary_needle : TextureRect
@export var secondary_min_angle : float = 0.0
@export var secondary_max_angle : float = 360.0

func update_meter(value : float, max_value : float, min_value : float) -> void:
	if value_label:
		value_label.text = str(int(value))
	
	if odometer:
		odometer.set_value(int(value))
	
	if needle:
		var rotation_range = max_angle - min_angle
		var value_ratio = value / max_value
		var target_angle = min_angle + (rotation_range * value_ratio)
		
		needle.rotation_degrees = lerp(needle.rotation_degrees, target_angle, 0.1)

func update_secondary_needle(value : float, max_value : float, min_value : float) -> void:
	if secondary_needle:
		var rotation_range = secondary_max_angle - secondary_min_angle
		var value_ratio = value / max_value
		var target_angle = secondary_min_angle + (rotation_range * value_ratio)
		
		secondary_needle.rotation_degrees = lerp(secondary_needle.rotation_degrees, target_angle, 0.1)
