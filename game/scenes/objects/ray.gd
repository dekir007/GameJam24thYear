extends Node3D
class_name FrostRay

signal hitting_player

@export var damage : Damage

@onready var ray_cast: RayCast3D = $Ray/RayCast3D
@onready var gpu_particles : GPUParticles3D = $GPUParticles3D
@onready var target: Node3D = $Node3D
@onready var ray: Node3D = $Ray

var is_casting : bool = false
var can_damage : bool = true

func _process(delta: float) -> void:
	look_at(target.global_position + Vector3.UP*.5)

func _physics_process(delta: float) -> void:
	var dist
	if ray_cast.is_colliding():
		gpu_particles.emitting = true
		dist = global_position.distance_to(ray_cast.get_collision_point())
		if (ray_cast.get_collider() as Node).get_parent().is_in_group("player"):
			hitting_player.emit()
			if can_damage:
				ray_cast.get_collider().get_hit(damage)
				can_damage = false
				$CooldownTimer.start()
	else:
		gpu_particles.emitting = false
		dist = global_position.distance_to(target.global_position)
	if is_casting:
		show()
		ray.scale.z = dist * .55 # понятия не имею, почему тут надо половину брать, но надо
		#print("ray.scale.z : ", ray.scale.z)
	else:
		hide()


func _on_cooldown_timer_timeout() -> void:
	can_damage = true
