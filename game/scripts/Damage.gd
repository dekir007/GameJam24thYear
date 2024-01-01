extends Resource
class_name Damage

@export var damage : int
@export_range(0, 1, 0.01) var penetration : float

#func _init(_damage : int, _penetration : float) -> void:
	#damage = _damage
	#penetration = _penetration
