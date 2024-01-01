extends Node3D

@onready var ray_cast: RayCast3D = $Ray/RayCast3D
@onready var gpu_particles : GPUParticles3D = $GPUParticles3D
@onready var target: Node3D = $Node3D
@onready var ray: Node3D = $Ray

func _process(delta: float) -> void:
	look_at(target.global_position)

func _physics_process(delta: float) -> void:
	var dist
	if ray_cast.is_colliding():
		gpu_particles.emitting = true
		dist = global_position.distance_to(ray_cast.get_collision_point())
	else:
		gpu_particles.emitting = false
		dist = global_position.distance_to(target.global_position)
	if dist > 7.5:
		hide()
	else:
		show()
		ray.scale.z = dist
