extends Resource
class_name Defense

@export_range(0, .9, 0.01) var defense : float :
	set(val):
		defense = clamp(val, 0, .9)

#func _init(_defense : float) -> void:
	#defense = _defense
