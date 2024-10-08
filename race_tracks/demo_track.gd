extends Node2D

@onready var lap_label: Label = $UI/LapLabel

var lap_timer: float
var is_racing: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_racing:
		lap_timer += delta
	lap_label.set_text(str(lap_timer))


func _on_lap_area_2d_body_entered(body: Node2D) -> void:
	if is_racing: #if the timer is running, stop the timer
		is_racing = false
		lap_timer = 0
		
	else:
		is_racing = true
	
