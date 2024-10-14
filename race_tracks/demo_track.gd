extends Node2D


@onready var car: Car = $Car

@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var ai_car: CharacterBody2D = $Path2D/PathFollow2D/AiCar


var lap_timer: float
var is_racing: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	path_follow_2d.progress += ai_car.SPEED * delta
