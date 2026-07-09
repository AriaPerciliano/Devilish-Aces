extends Area3D
class_name Projectile

var velocity : Vector3
var damage : float

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(1.0).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var start_pos = global_position
	var end_pos = global_position + velocity * delta
	
	var query = PhysicsRayQueryParameters3D.create(start_pos, end_pos)
	query.collision_mask = 1
	var result = space_state.intersect_ray(query)
	
	if result:
		global_position = result.position
		_on_body_entered(result.collider)
		return
	
	global_position = end_pos

func setup(vel : Vector3, dmg : float) -> void:
	velocity = vel
	damage = dmg

func _on_area_entered(area : Area3D) -> void:
	# This is meant for when the projectile hit an enemy/target scenario
	if area is TargetHurtbox3D:
		var attack : AttackComponent = AttackComponent.new()
		attack.damage = damage
		area.damage(attack)
		attack.queue_free()
	queue_free()

func _on_body_entered(body : Node3D) -> void:
	# This is for impact non_target scenario
	queue_free()
