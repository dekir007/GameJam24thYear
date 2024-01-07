extends Node
class_name HealthComponent

signal health_changed(upd : HealthUpdate)
signal died

@export var max_health : float = 100

@onready var hp : float = max_health :
	set(value):
		var prev = hp
		hp = snappedf(clamp(value, 0, max_health), 0.01)
		var upd = HealthUpdate.new(prev, hp, max_health, prev <= hp)
		health_changed.emit(upd)

var is_dead : bool :
	get:
		return hp <= 0


func apply_damage(damage : float, 
	#no_signal : bool = true
	):
	if is_dead:
		print("already dead")
		return
	hp -= damage
	if is_dead:
		died.emit()

func heal(_heal : float):
	apply_damage(-_heal)
