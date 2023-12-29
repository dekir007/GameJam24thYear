extends Node
class_name HealthComponent

signal health_changed(upd : HealthUpdate)
signal died

@export var max_health : int = 100

@onready var hp : int = max_health :
	set(value):
		var prev = hp
		hp = clamp(value, 0, max_health)
		var upd = HealthUpdate.new(prev, hp, max_health, prev <= hp)
		health_changed.emit(upd)

var is_dead : bool :
	get:
		return hp <= 0


func apply_damage(damage : int, 
	#no_signal : bool = true
	):
	hp -= damage
	if is_dead:
		died.emit()

func heal(_heal : int):
	apply_damage(-_heal)
