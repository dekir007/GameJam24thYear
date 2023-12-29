extends Node
class_name HealthUpdate

@export var prev_hp : int
@export var cur_hp : int
@export var max_hp : int
@export var is_heal : bool

func _init(_prev_hp, _cur_hp, _max_hp, _is_heal) -> void:
	prev_hp = _prev_hp
	cur_hp = _cur_hp
	max_hp = _max_hp
	is_heal = _is_heal
