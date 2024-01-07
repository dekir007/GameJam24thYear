extends VBoxContainer
class_name UpgradeOption

signal upgrade

@export var data : UpgradeOptionData

@onready var icon_image: TextureRect = $IconImage
@onready var title: Label = $Title
@onready var description: Label = $Description
@onready var button: Button = $Button

func _ready() -> void:
	icon_image.texture = data.icon
	title.text = data.title + (" " + str(data.level) + "/" + str(data.max_level) if data.max_level > 0 else "")
	description.text = data.description + "\nPrice: " + str(data.price)


func _on_button_button_up() -> void:
	if data.level == data.max_level or Globals.money < data.price:
		return
	data.level += 1
	Globals.money -= data.price
	title.text = data.title + (" " + str(data.level) + "/" + str(data.max_level) if data.max_level > 0 else "")
	upgrade.emit()
