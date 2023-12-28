extends Node3D
class_name SimpleBullet

@export var direction:Vector3
@export var speed:float = 1000
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	direction = -get_parent().get_global_transform().basis.z

func _process(delta: float) -> void:
	global_position += direction*speed*delta


func _on_timer_timeout() -> void:
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	gpu_particles_3d.emitting=true
	speed = true
	mesh.hide()
	if body.has_method("get_hit"):
		body.get_hit()

func _on_gpu_particles_3d_finished() -> void:
	queue_free()
