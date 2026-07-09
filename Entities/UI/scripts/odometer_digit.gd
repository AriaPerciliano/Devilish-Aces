extends Sprite2D
class_name OdometerDigit

@export var digit_height : float = 8.0
@export var digit_count : int = 10

var current_digit : int = 0

func _ready() -> void:
	region_enabled = true
	set_digit(0)

func set_digit(digit : int) -> void:
	digit = clampi(digit, 0, digit_count - 1)
	current_digit = digit
	
	var rect := region_rect
	rect.position.y = digit * digit_height
	region_rect = rect

func roll_to_digit(target_digit : int, duration : float = 0.25) -> void:
	target_digit = clampi(target_digit, 0, digit_count - 1)
	
	var start_y : float = current_digit * digit_height
	var end_y : float = target_digit * digit_height
	
	if end_y < start_y:
		end_y += digit_count * digit_height
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(set_region_y, start_y, end_y, duration)
	tween.finished.connect(func(): set_digit(target_digit))

func set_region_y(y : float) -> void:
	var rect = region_rect
	rect.position.y = fmod(y, digit_count * digit_height)
	region_rect = rect
