extends TextureProgressBar
class_name ThrottleMeter

func update_throttle(val : float, max_val, min_val) -> void:
	min_value = min_val
	max_value = max_val
	value = val
