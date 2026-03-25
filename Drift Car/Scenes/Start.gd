extends Node

@export var player_node: NodePath
@onready var fps_label: Label = get_node("Status/FPS")
@onready var debug_label: Label = get_node("Status/Debug")
@onready var camera: Camera3D = get_node("Camera")

var player: Node
var car: VehicleController


func _ready() -> void:
	var view: Viewport = get_viewport()
	view.grab_focus()
	player = get_node(player_node)
	car = player.car

func _process(_delta: float) -> void:
	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("controller_camera"):
		if camera.first_person:
			camera.switch_third_person()
		else: if camera.third_person:
			camera.switch_third_person_fixed()
		else:
			camera.switch_first_person()
	if Input.is_action_just_pressed("controller_camera_rotate"):
		if camera.auto_rotate_mode:
			camera.auto_rotate_mode = false
		else:
			camera.auto_rotate_mode = true
	var status_text: String
	var fps: float = Performance.get_monitor(Performance.TIME_FPS)
	var velocity_sideways: float = car.vehicle_state.velocity_sideways
	var grip: bool = car.has_grip
	var grip_force: float = car.grip_force
	var omega_reference: float = car.omega_reference
	var omega_measurement: float = car.angular_velocity.y
	var drift_angle: float = car.vehicle_state.drift_angle_measurement
	var cornering: bool = car.is_cornering
	var format: String = "FPS: %2.0f"
	fps_label.text = format % fps
	format = "Turn Radius: %.0f\n"
	format += "Force: %.1f\n"
	format += "Grip Force: %.1f N\n\n"
	format += "Grip: %s\n"
	format += "Cornering: %s\n"
	format += "Boost: %s\n"
	format += "Omega: %.1f (ref: %.3f)\n\n"
	format += "Drift-Angle: %3.0f\n"
	format += "Velocity Sideways: %.0f m/s\n\n"
	status_text = format % [car.turn_radius, car.current_force, grip_force, grip, cornering, car.apply_boost, omega_measurement, omega_reference, rad_to_deg(drift_angle), velocity_sideways]
	debug_label.text = status_text
	
