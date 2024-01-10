extends Node3D
class_name SimpleBullet

@export var direction:Vector3
@export var speed:float = 2000
@export var damage : Damage

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	direction = -get_parent().get_global_transform().basis.z.normalized()

func _process(delta: float) -> void:
	global_position += direction*speed*delta

func get_data(_damage : Damage):
	damage = _damage

func _on_timer_timeout() -> void:
	queue_free()

func delete():
	gpu_particles_3d.emitting=true
	speed = 0
	mesh.hide()
	$Area3D/CollisionShape3D.call_deferred("set_disabled", true)
	get_tree().create_timer(gpu_particles_3d.lifetime).timeout.connect(queue_free)

func _on_area_3d_body_entered(_body: Node3D) -> void:
	print("world")
	if speed != 0:
		delete()
