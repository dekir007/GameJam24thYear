extends Node3D

@export var dir : Vector3
@export var speed : float
@export var damage : Damage

func _ready() -> void:
	#rotate_y(dir.angle_to(transform.basis.z))
	dir.y = 0
	dir = dir.normalized()
	look_at(global_transform.origin + dir, Vector3.UP)
	var tw = get_tree().create_tween()
	tw.tween_property(self, "speed", speed, 1).from(speed * 1.4)
	tw.play()

func _process(delta: float) -> void:
	position += dir * speed * delta

func delete():
	queue_free()

func _on_area_3d_area_entered(_area: Area3D) -> void:
	queue_free()


func _on_timer_timeout() -> void:
	queue_free()
