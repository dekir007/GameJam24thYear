extends Area3D

class_name HitBoxComponent

signal hit(hit_context : HitContext)

@export var defense : Defense

func _ready() -> void:
	if defense == null:
		defense = Defense.new()
		defense.defense = 0
	#if core == null:
	#	core = owner.find_child("CoreComponent")

func _on_area_entered(area: Area3D) -> void:
	var attack_node = area.get_parent() as Node3D
	if !attack_node.is_in_group("attack"):
		return
	# TODO
	get_hit(attack_node.damage)
	attack_node.delete()
	#area.queue_free()

func get_hit(damage : Damage):
	set_deferred("monitoring", false)
	#var d = (area.skill as Skill).attack(area.attacker, core)
	
	var d = snappedf(damage.damage * clamp(1 - defense.defense + damage.penetration, 0, 1), 0.01) # мда, тавтология вышла
	hit.emit(HitContext.new(d))
	
	await get_tree().create_timer(0.1).timeout
	set_deferred("monitoring", true)

class HitContext extends RefCounted:
	#var attacker : CoreComponent
	var damage : float
	
	func _init(#_attacker: Node, 
				_damage : float):
		#attacker = _attacker
		damage = _damage
