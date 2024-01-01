extends CanvasLayer

@onready var label: Label = $Label
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var health_orb: Control = $HealthOrb
@onready var health_orb_bar: TextureProgressBar = $HealthOrb/HealthOrbBar
@onready var dash_progress_bar: TextureProgressBar = $DashProgressBar
@onready var get_hit: TextureRect = $GetHit

func _ready() -> void:
	health_orb.hide()
	get_hit.modulate.a = 0

func _process(_delta: float) -> void:
	label.text = "FPS: %s\nGifts: %s (%s stolen!)\nScore: %s" % [Engine.get_frames_per_second(), Globals.gift_count, Globals.stolen_gift_count,Globals.score]

func show_red():
	var tw = get_tree().create_tween()
	tw.tween_property(get_hit, "modulate:a", float(150)/256, .2).from(0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tw.tween_property(get_hit, "modulate:a", 0, .2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tw.play()
