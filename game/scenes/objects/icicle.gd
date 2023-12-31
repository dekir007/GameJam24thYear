extends Node3D

@export var dir : Vector3
@export var speed : float

func _ready() -> void:
	#rotate_y(dir.angle_to(transform.basis.z))
	dir.y = 0
	dir = dir.normalized()
	print(dir.dot(Vector3.UP))
	look_at(global_transform.origin + dir, Vector3.UP)
	var tw = get_tree().create_tween()
	tw.tween_property(self, "speed", speed, 1).from(speed * 1.3)
	tw.play()

func _process(delta: float) -> void:
	position += dir * speed * delta


func _on_area_3d_area_entered(_area: Area3D) -> void:
	queue_free()
