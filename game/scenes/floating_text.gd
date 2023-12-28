extends Marker2D

@onready var label: Label = $Label

var amount : float

var velocity : Vector2

func _ready() -> void:
	label.text = str(amount)
	
	velocity = Vector2(randi()%51-20, 50)
	
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2.ONE, 0.2).from(Vector2(0.7,0.7)).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2(.1,.1), 0.7).set_ease(Tween.EASE_OUT)
	tween.play()
	tween.finished.connect(queue_free)

func _process(delta: float) -> void:
	position -= velocity*delta
