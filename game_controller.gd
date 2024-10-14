extends Node

class_name GameController
## This script will allow easy switching between scenes

@export var world_2d: Node2D
@export var gui: Control


var current_2d_scene
var current_gui_scene
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	Global.game_controller = self #sets the global reference to the game controller so everything can access it
	Global.game_controller.change_gui_scene("res://ui_scripts/main_menu.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func change_gui_scene(new_scene: String, delete:bool = true, keep_running: bool = false) -> void: #new_scene is the filepath
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free() # remove nod eentirely
		elif keep_running:
			current_gui_scene.set_visible(false) #keeps in memory and running
		else:
			gui.remove_child(current_gui_scene) #keep in memory, does not run
	
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new

func change_2d_scene(new_scene: String, delete:bool = true, keep_running: bool = false) -> void: #new_scene is the filepath
	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free() # remove nod eentirely
		elif keep_running:
			current_2d_scene.set_visible(false) #keeps in memory and running
		else:
			world_2d.remove_child(current_2d_scene) #keep in memory, does not run
	
	var new = load(new_scene).instantiate()
	world_2d.add_child(new)
	current_2d_scene = new


#call by using
#Global.game_controller.change_gui_scene("scenepath")


func _on_gui_child_entered_tree(node: Node) -> void: # connect the car to the UI
	if node is UI:
		print_debug("true")
		var player_car_reference = get_tree().get_nodes_in_group("player_car")[0]
		var finish_line_reference = get_tree().get_nodes_in_group("finish_line")[0]
		finish_line_reference.connect("body_entered",Callable(node,"_on_lap_area_2d_body_entered"))
