extends Node

@export var player_node: NodePath
@onready var fps_label = get_node("Status/FPS")
@onready var debug_label = get_node("Status/Debug")

var player: Node
var car: VehicleController


func _ready():
	player = get_node(player_node)
	car = player.car
	randomize()

func _process(_delta):
	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit()
	var status_text: String
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var acceleration: float = car.acceleration_measurement
	var force: float = car.acceleration_force
	var velocity_sideways: float = car.vehicle_state.velocity_sideways
	var velocity_rear_axis: float = car.vehicle_state.velocity_rear_axis
	var gear: int = car.gearbox.gear
	var grip: bool = car.has_grip
	var grip_force: float = car.grip_force
	var omega_reference = car.omega_reference
	var omega_measurement = car.angular_velocity.y
	var drift_angle = car.vehicle_state.drift_angle_measurement
	var cornering = car.is_cornering
	var format = "FPS: %2.0f"
	fps_label.text = format % fps
	format = "Acceleration: %.1f\n"
	format += "Force: %.1f N\n"
	format += "Velocity Sideways: %.0f m/s\n"
	format += "Velocity Rear: %.0f m/s\n\n"
	format += "Gear: %s\n"
	format += "Grip: %s\n\n"
	format += "Grip Force: %.1f N\n\n"
	format += "Omega: %.1f (ref: %.1f)\n"
	format += "Drift-Angle: %3.0f\n\n"
	format += "Cornering: %s\n"
	status_text = format % [acceleration, force, velocity_sideways, velocity_rear_axis, gear, grip, grip_force, omega_measurement, omega_reference, rad_to_deg(drift_angle), cornering]
	debug_label.text = status_text
	
