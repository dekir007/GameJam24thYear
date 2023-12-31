extends CanvasLayer

@onready var label: Label = $Label
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var health_orb: Control = $HealthOrb
@onready var health_orb_bar: TextureProgressBar = $HealthOrb/HealthOrbBar

func _ready() -> void:
	health_orb.hide()

func _process(_delta: float) -> void:
	label.text = "FPS: %s\nGifts: %s (%s stolen!)\nScore: %s" % [Engine.get_frames_per_second(), Globals.gift_count, Globals.stolen_gift_count,Globals.score]

