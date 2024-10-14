extends CharacterBody2D

class_name Car

signal velocity_changed(velocity_magnitude: float)

#@onready var speed_label: Label = $"../UI/SpeedLabel"
#@onready var drift_duration_label: Label = $"../UI/DriftDurationLabel"

@onready var speed_boost_timer: Timer = $SpeedBoostTimer
@onready var drift_gpu_particles_2d: GPUParticles2D = $DriftGPUParticles2D

#TODO explain each variable
@export var wheel_base: float = 70 ## distance from front to rear wheel, smaller = tighter turns
@export var steering_angle: float = 15 ## the amount that the front wheel turns, in degrees. higher = tighter turns
@export var engine_power:float = 900 ## forward acceleration force. higher = faster acceleration
@export var friction: float = -55  #TODO tie this to the race track
@export var drag: float = -0.02 ##  a lower drag means the car can reach a higher top speed
@export var braking: float = -450 ## how fast the car comes to a stop
@export var max_speed_reverse: float = 250 ## limit the speed a car can go backwards #TODO add a meme car that is faster backwards?
@export var slip_speed: float = 400  ## Speed when the car can start drifting
@export var traction_fast: float = 2.5 ## High-speed traction. Applies if the car is above the slip_speed and the car is drifting
@export var traction_slow: float = 10  ## Low-speed traction. Applies on all turns if there is no drifting


var acceleration: Vector2 = Vector2.ZERO
var steer_direction
var is_on_road: bool = true

## Drifting variables
var is_drifting: bool = false: set = set_drifting ## tracks if the car is currently drifting. setter will activate sparks
var drift_timer: float = 0.0 ## tracks how long the car is drifting
var turbo_power: float = 1.0 ## multiplier used to increase speed. all boosts should increase this variable for a set time

@export var mini_drift_threshold: float = 1.0 ## Drift duration to get the mini boost
@export var mini_turbo_power: float = 1.5 ## how powerful the speed boost is
@export var mini_turbo_duration: float = 1.0 ## how long the speed boost lasts

@export var med_drift_threshold: float = 2.2 ## Drift duration to get the mini boost
@export var med_turbo_power: float = 1.85 ## how powerful the speed boost is
@export var med_turbo_duration: float = 1.1 ## how long the speed boost lasts

@export var large_drift_threshold: float = 4.5 ## Drift duration to get the mini boost
@export var large_turbo_power: float = 2.3 ## how powerful the speed boost is
@export var large_turbo_duration: float = 1.35 ## how long the speed boost lasts

#MECHANICS TO EXPLORE
#TODO car collison with other cars and boundaries
#TODO drifting speedboosts
#TODO slipstream and overtaking
#TODO make a base car class. swap out a resource file to change the stats
#TODO car shake/ engine sputtering/ pressing on the accelerator
#TODO particle fx from drifting
#TODO tire tracks?

func _ready() -> void:
	pass
	

func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	calculate_steering(delta)
	
	if is_drifting: #increases drift timer while drifting
		drift_timer += delta
		#drift_duration_label.set_text(str(drift_timer))
	
	
	
	velocity += acceleration * delta
	#print_debug(velocity.length())
	move_and_slide()
	#speed_label.set_text(str(int(velocity.length())))
	
func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force
	
func get_input():
	var turn = Input.get_axis("turn_left", "turn_right")
	steer_direction = turn * deg_to_rad(steering_angle)
	#velocity = Vector2.ZERO
	if Input.is_action_pressed("accelerate"):
		#velocity = transform.x * 500
		acceleration = transform.x * engine_power * turbo_power
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking #TODO make a car that is faster backwards
	
	if Input.is_action_pressed("drift") and turn != 0: #only drifts if the player is turning
		if !is_drifting and is_on_road:
			set_drifting(true)
	#elif Input.is_action_pressed("drift") and turn == 0: #if the player stops sterring
		#set_drifting(false)
		#
	if Input.is_action_just_released("drift"):
		if is_drifting:
			trigger_turbo()
			set_drifting(false)
	
func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading:Vector2 = rear_wheel.direction_to(front_wheel)
	
	#Save the car's current speed for drifting
	
	
	
	# choose which traction value to use depending on speed
	var traction: float = traction_slow #default traction value

	if is_drifting:
		traction = traction_fast


	var d: float = new_heading.dot(velocity.normalized()) # see if the car is moving backwards or forwards
	#The dot product will be 0 for a right angle (90 degrees), greater than 0 for angles narrower than 90 degrees and lower than 0 for angles wider than 90 degrees.
	if d > 0: #if the dot product > 0 the vectors are aligned (going forward)
		velocity = lerp(velocity,new_heading * velocity.length(),traction * delta) 
	if d < 0: #if its less than 0, the car must be moving backwards
		
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)

	
	rotation = new_heading.angle()

func trigger_turbo() -> void:
	if drift_timer >= large_drift_threshold:
		speed_boost_timer.set_wait_time(large_turbo_duration)
		speed_boost_timer.start()
		turbo_power = large_turbo_power
	elif drift_timer >= med_drift_threshold:
		speed_boost_timer.set_wait_time(med_turbo_duration)
		speed_boost_timer.start()
		turbo_power = med_turbo_power
	elif drift_timer >= mini_drift_threshold:
		speed_boost_timer.set_wait_time(mini_turbo_duration)
		speed_boost_timer.start()
		turbo_power = mini_turbo_power

	else:
		turbo_power = 1.0 # no boost

func _on_speed_boost_timer_timeout() -> void:
	turbo_power = 1.0

## SETTERS GETTERS
func set_drifting(drifting_bool: bool) -> void:
	drift_timer = 0.0
	if !drifting_bool:
		is_drifting = false
		for particle_child in get_children():
			if particle_child is GPUParticles2D:
				particle_child.set_emitting(drifting_bool)
		return
	if velocity.length() > slip_speed:
		is_drifting = drifting_bool
		for particle_child in get_children():
			if particle_child is GPUParticles2D:
				particle_child.set_emitting(drifting_bool)



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is DirtLayer:
		is_on_road = false
		set_drifting(false)  #stops all drifting
		var speed_reduction = body.speed_reduction
		engine_power -= speed_reduction
		
		
		


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is DirtLayer:
		is_on_road = true
		var speed_reduction = body.speed_reduction
		engine_power += speed_reduction
		
