extends Control

@onready var _retry_btn: Button = $VBoxContainer/RetryBtn

func _ready():
	visible = false


func _input(event):
	if event.is_echo():
		return
	if event.is_action_pressed("game_over"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		visible = true
		get_tree().paused = true
		_retry_btn.grab_focus()


func _on_retry_btn_button_down() -> void:
	Globals.reset()
