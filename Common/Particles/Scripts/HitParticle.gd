extends Node3D
class_name HitParticle

@export var cpu_particles : Array[CPUParticles3D]
@export var gpu_particles : Array[GPUParticles3D]
@export var particle_sound : AudioStreamPlayer3D

# Pretty simple code for executing particles that are spawned while hitting things
func particle_start(lifetime : float) -> void:
	# Checks if the particle arrays are filled and emits them
	if !cpu_particles.is_empty():
		for particle in cpu_particles:
			particle.emitting = true
			particle.lifetime = lifetime
	if !gpu_particles.is_empty():
		for particle in gpu_particles:
			particle.emitting = true
			particle.lifetime = lifetime
	# Deletes the particle after they are done
	get_tree().create_timer(lifetime + 0.05).timeout.connect(queue_free)
