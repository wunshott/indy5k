extends Control

class_name MainMenu
# Called when the node enters the scene tree for the first time.


#const DEMO_TRACK = preload("res://race_tracks/demo_track.tscn")
#const UI = preload("res://ui_scripts/ui.tscn")

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_sand_box_button_pressed() -> void:
	Global.game_controller.change_2d_scene("res://race_tracks/demo_track.tscn")
	Global.game_controller.change_gui_scene("res://ui_scripts/ui.tscn")
	
	
