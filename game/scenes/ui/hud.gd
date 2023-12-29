extends CanvasLayer

@onready var label: Label = $Label

func _process(delta: float) -> void:
	label.text = "FPS: %s\nGifts: %s (%s stolen!)\nScore: %s" % [Engine.get_frames_per_second(), Globals.gift_count, Globals.stolen_gift_count,Globals.score]
