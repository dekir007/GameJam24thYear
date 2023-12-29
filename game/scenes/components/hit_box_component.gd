extends Area3D

class_name HitBoxComponent

signal hit(hit_context : HitContext)


func _ready() -> void:
	pass
	#if core == null:
	#	core = owner.find_child("CoreComponent")

func _on_area_entered(area: Area3D) -> void:
	if !area.is_in_group("attack") and !area.get_parent().is_in_group("attack"):
		return
	# TODO
	#area = area as AttackSphere
	
	#var d = (area.skill as Skill).attack(area.attacker, core)
	var d = 2
	
	hit.emit(HitContext.new(d))
	
	# TODO
	#area.queue_free()


class HitContext extends RefCounted:
	#var attacker : CoreComponent
	var damage : int
	
	func _init(#_attacker: Node, 
				_damage : int):
		#attacker = _attacker
		damage = _damage
