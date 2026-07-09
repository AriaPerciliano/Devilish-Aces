extends Node

func Scale6(value: Vector3, pos_x : float, neg_x : float, pos_y : float, neg_y : float, pos_z : float, neg_z : float) -> Vector3:
	var result : Vector3 = value
	
	if result.x > 0:
		result.x *= pos_x
	elif result.x < 0:
		result.x *= neg_x
	
	if result.y > 0:
		result.y *= pos_y
	elif result.y < 0:
		result.y *= neg_y
		
	if result.z > 0:
		result.z *= neg_z
	elif result.z < 0:
		result.z *= pos_z
	
	return result
