extends Node3D

func get_grabbed():
	Globals.stolen_gift_count += 1
	print("grabbed; stolen: ", Globals.stolen_gift_count, "; ", Globals.gift_count)
	queue_free()
