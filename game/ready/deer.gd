extends CharacterBody3D

@onready var fog_volume: FogVolume = $FogVolume
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label: Label3D = $Label3D

var hud
var target : Vector3

var dir : Vector3 = Vector3.ZERO

var ready_to_reward : bool = false

func _ready() -> void:
	$Armature.visible = false
	label.visible = false
	hud.upgrade_chosen_signal.connect(disappear)

func appear():
	var tw = get_tree().create_tween()
	tw.tween_property(fog_volume, "material:density", 0, .7).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	await get_tree().create_timer(.2).timeout
	$Armature.visible = true
	dir = global_position.direction_to(target)
	look_at(dir.rotated(Vector3.UP, -PI/2))
	
	get_tree().current_scene.get_node("belka").gift_timer.paused = true

func disappear():
	var tw = get_tree().create_tween()
	tw.tween_property(fog_volume, "material:density", 8, .2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tw.finished.connect(queue_free)
	get_tree().current_scene.get_node("belka").gift_timer.paused = false

func _process(delta: float) -> void:
	if global_position.distance_squared_to(target) < 1:
		dir = Vector3.ZERO
		animation_player.stop()
		ready_to_reward = true
		label.visible = true
		label.modulate.a = 1
		label.outline_modulate.a = 1
	
	velocity = dir * 750 * delta
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		event = event as InputEventKey
		if event.keycode == KEY_E and ready_to_reward and label.visible:
			hud.show_upgrades()
