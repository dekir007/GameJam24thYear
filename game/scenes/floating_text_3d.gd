extends Marker3D

@onready var label: Label3D = $Label3D

var amount : float

var velocity : Vector3

func _ready() -> void:
	label.text = str(amount)
	
	velocity = Vector3(randi()%6-2, 1.5, randi()%6-2)
	
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector3.ONE, 0.2).from(Vector3(0.7,0.7,0.7)).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector3(.1,.1,.1), 0.7).set_ease(Tween.EASE_OUT)
	tween.play()
	tween.finished.connect(queue_free)

func _process(delta: float) -> void:
	position -= velocity*delta

func get_data(data : Dictionary):
	amount = data["amount"]
