extends CanvasLayer

class_name UI

@onready var acceleration: TextureProgressBar = $Acceleration #TODO tie to the car scene
@onready var lap_counter_label: Label = $HBoxContainer/LapCounterLabel
@onready var label_time_label: Label = $HBoxContainer/LabelTimeLabel #TODO convert the timer to a stopwatch format
 
var lap_counter: int = 0
var current_lap_timer: float
var start_time: float ## start time synced with engine
var lap_times: Array[String] = []
var is_timer_running: bool = false

#player crosses finish line
#timer starts
#crossing again will save the time, reset the timer and increase the lap counter


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print_debug(Engine.get_frames_per_second())
	if is_timer_running:
		current_lap_timer = (Time.get_ticks_msec() - start_time) / 1000.0 #convert ms to s
		label_time_label.set_text(format_time_to_stopwatch(current_lap_timer))

func _on_lap_area_2d_body_entered(body: Node2D) -> void: #TODO clean up with functions
	if body is Car:
		if lap_counter == 0: #if its the first lap
			start_stopwatch()
			lap_counter += 1
			lap_counter_label.set_text("1/3") #TODO get number of laps from the course
		elif lap_counter == 1: #first lap is done
			lap_times.append(format_time_to_stopwatch(current_lap_timer))
			start_stopwatch()
			lap_counter += 1
			lap_counter_label.set_text("2/3") #TODO get number of laps from the course
		elif lap_counter == 2: #first lap is done
			lap_times.append(format_time_to_stopwatch(current_lap_timer) )
			start_stopwatch()
			lap_counter += 1
			lap_counter_label.set_text("3/3") #TODO get number of laps from the course
		elif lap_counter == 3: #first lap is done
			stop_stopwatch()
			lap_times.append(format_time_to_stopwatch(current_lap_timer)) 
			print_debug("RACE FINISHED" + str(lap_times))

func start_stopwatch() -> void:
	start_time = Time.get_ticks_msec()
	is_timer_running = true
	
func stop_stopwatch() -> void:
	is_timer_running = false

func format_time_to_stopwatch(time_elapsed: float) -> String:
	var m: float = time_elapsed / 60
	var s: float = time_elapsed
	var ms: float = int( (time_elapsed - int(time_elapsed)) * 1000)
	var output_time: String = "%02d:%02d:%03d" % [m,s,ms]
	return output_time
