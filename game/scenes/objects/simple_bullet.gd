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

func _on_area_3d_area_entered(area: Area3D) -> void:
	gpu_particles_3d.emitting=true
	speed = 0
	mesh.hide()
	$Area3D/CollisionShape3D.call_deferred("set_disabled", true)
	get_tree().create_timer(gpu_particles_3d.lifetime).timeout.connect(queue_free)
