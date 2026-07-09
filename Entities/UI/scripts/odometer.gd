extends Control
class_name Odometer

@export var digits : Array[OdometerDigit] = []
@export var use_rolling_anim : bool = true
@export var roll_duration : float = 0.1

var current_value : int = 0

func set_value(value : int) -> void:
	value = clampi(value, 0, max_displayable_value())
	if value == current_value:
		return
	
	current_value = value
	var digit_values : Array[int] = split_digits(value, digits.size())
	
	for i in digits.size():
		if use_rolling_anim:
			digits[i].roll_to_digit(digit_values[i], roll_duration)
		else:
			digits[i].set_digit(digit_values[i])

func split_digits(value : int, digit_slots : int) -> Array[int]:
	var result : Array[int] = []
	for i in digit_slots:
		result.push_front(value % 10)
		value /= 10
	return result

func max_displayable_value() -> int:
	return int(pow(10, digits.size())) - 1
