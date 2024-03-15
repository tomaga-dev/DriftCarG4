extends RigidBody3D

class_name VehicleController

signal query_driver(car_of_driver: VehicleController, rev_normalized: float)

@export var max_force: float = 20000
@export var rev_min: float = 1
@export var rev_multiplier: float = 5 # Higher values result in higher revs.
@export var shift_time: int = 20 # in physics steps (20/60 = 1/3 seconds)
@export var vmax_wheel_spin: float = 6
@export var force_curve: Curve
@export var omega_curve: Curve
@export var omega_max: float = 0.5
@export var omega_max_drift: float = 0.9
@export var spring_distance_max_in: float = 0.07
@export var spring_distance_max_out: float = 0.14
# Hard spring.
@export var spring_constant: float = 42214
@export var spring_damping: float = 7904

@onready var steering_controller: Node = get_node("SteeringController")
@onready var drift_controller = get_node("DriftController")
@onready var grip_controller = get_node("GripController")
@onready var omega_controller: Node = get_node("OmegaController")
@onready var gearbox: Node = get_node("GearBox")
@onready var motor: Node = get_node("Motor")
@onready var driver: Node = get_node("Driver")
@onready var fl: WheelController = get_node("FL")
@onready var fr: WheelController = get_node("FR")
@onready var rl: WheelController = get_node("RL")
@onready var rr: WheelController = get_node("RR")
@onready var sound_emitter: SoundEmitter = get_node("SoundEmitter")

var vehicle_state = VehicleState.new()
var wheel_state = WheelState.new()
var max_grip_angle_degree: float = 1
var brake_value: float = 20000
var on_ground: bool = false
var has_grip: bool = false
var grip_force: float
var driving_force_position: Vector3 # The force to move the car is applied at this position (local to the car).
var offset_drive: Vector3
var omega_reference: float
var wheelbase: float
var turn_radius: float
var velocity_measurement: float
var acceleration_measurement: float
var acceleration_force: float
var is_cornering_left: bool
var is_cornering_right: bool
var rev_normalized: float
var rev: float


func _ready():
	var weight: float = mass * ProjectSettings.get_setting("physics/3d/default_gravity")
	wheelbase = rl.transform.origin.z - fl.transform.origin.z
	driving_force_position = Vector3(0, -rl.wheel_radius, wheelbase * 0.5) # At the rear axis and at the contact point of the wheel.
	fl.init_suspension(weight / 4, spring_distance_max_in, spring_distance_max_out, spring_constant, spring_damping)
	fr.init_suspension(weight / 4, spring_distance_max_in, spring_distance_max_out, spring_constant, spring_damping)
	rl.init_suspension(weight / 4, spring_distance_max_in, spring_distance_max_out, spring_constant, spring_damping)
	rr.init_suspension(weight / 4, spring_distance_max_in, spring_distance_max_out, spring_constant, spring_damping)
	gearbox.gear_shift_time = shift_time
	gearbox.set_force_limits(max_force)
	motor.rev_normalized_max = 0.7

func _physics_process(delta: float):
	var torque: float
	var torque_vector: Vector3
	var vehicle_velocity_magnitude: float = linear_velocity.length()
	var vehicle_rotation = Quaternion(transform.basis)
	on_ground = update_suspension(delta, vehicle_rotation)
	rev_normalized = motor.update_state(self)
	rev = rev_normalized * rev_multiplier
	sound_emitter.update_motor_sound(self)
	emit_signal("query_driver", self, rev_normalized)
	if !on_ground:
		grip_force = steering_controller.reset()
		drift_controller.reset()
		grip_controller.reset()
		omega_controller.reset()
		return
	offset_drive = vehicle_rotation * driving_force_position
	vehicle_state.update(vehicle_rotation, linear_velocity)
	acceleration_measurement = (vehicle_velocity_magnitude - velocity_measurement) / delta
	velocity_measurement = vehicle_velocity_magnitude
	gearbox.select_gear(vehicle_velocity_magnitude, driver.did_accelerate)
	var steering: float = vehicle_state.drift_angle_measurement
	turn_radius = get_turn_radius(vehicle_velocity_magnitude)
	if driver.did_accelerate:
		if driver.did_steer_left:
			if is_cornering_left:
				has_grip = false
		else: if driver.did_steer_right:
			if is_cornering_right:
				has_grip = false
		else:
			if vehicle_state.drift_angle_measurement > deg_to_rad(-max_grip_angle_degree) && vehicle_state.drift_angle_measurement < deg_to_rad(max_grip_angle_degree):
				has_grip = true
	else:
		if driver.did_steer_left:
			is_cornering_left = true
		else: if driver.did_steer_right:
			is_cornering_right = true
		else:
			is_cornering_left = false
			is_cornering_right = false
	if has_grip:
		drift_controller.reset()
		grip_controller.reset()
		steering = asin(wheelbase / turn_radius)
		control_omega(delta, vehicle_velocity_magnitude)
		apply_steering_force(vehicle_rotation)
	else:
		steering_controller.reset()
		if driver.did_accelerate:
			adjust_cornering(delta, vehicle_rotation)
		else:
			drift_controller.reset()
			grip_force = grip_controller.reset()
			control_omega(delta, vehicle_velocity_magnitude)
	if driver.did_accelerate:
		accelerate()
		if vehicle_state.velocity_rear_axis < vmax_wheel_spin:
			vehicle_state.velocity_rear_axis = vmax_wheel_spin
	else: if driver.did_reverse:
		reverse()
	else:
		acceleration_force = 0
	if driver.did_brake:
		brake(vehicle_velocity_magnitude)
	torque = omega_controller.adjust(omega_reference, angular_velocity.y)
	torque_vector = vehicle_rotation * Vector3.UP * torque
	apply_torque(torque_vector)
	wheel_state.update(delta, vehicle_state.velocity_front_axis, vehicle_state.velocity_rear_axis)
	update_wheel_rotation(delta, steering)

func control_omega(delta: float, velocity: float):
	var value: float = omega_curve.sample(velocity)
	if driver.did_steer_left:
		omega_reference = lerp(omega_reference, omega_max * value, 2 * delta)
	else: if driver.did_steer_right:
		omega_reference = lerp(omega_reference, -omega_max * value, 2 * delta)
	else:
		omega_reference = lerp(omega_reference, 0.0, 2 * delta)

func apply_steering_force(vehicle_rotation: Quaternion):
	if !vehicle_state.vehicle_moving_forward:
		grip_force = steering_controller.reset()
		return
	grip_force = steering_controller.adjust(0, vehicle_state.velocity_sideways)
	var direction = vehicle_rotation * Vector3.LEFT
	var grip_force_vector: Vector3 = direction * grip_force
	apply_force(grip_force_vector, offset_drive)

func adjust_cornering(delta: float, vehicle_rotation: Quaternion):
	if omega_reference > -omega_max && omega_reference < omega_max:
		is_cornering_left = false
		is_cornering_right = false
	if driver.did_steer_left:
		if is_cornering_right:
			omega_reference = lerp(omega_reference, omega_max_drift, 0.5 * delta)
		else:
			omega_reference = lerp(omega_reference, omega_max_drift, 5 * delta)
	else: if driver.did_steer_right:
		if is_cornering_left:
			omega_reference = lerp(omega_reference, -omega_max_drift, 0.5 * delta)
		else:
			omega_reference = lerp(omega_reference, -omega_max_drift, 5 * delta)
	else:
		if !is_cornering_left && !is_cornering_right:
			omega_reference = lerp(omega_reference, 0.0, 5 * delta)
	apply_drift_force(vehicle_rotation)

func apply_drift_force(vehicle_rotation: Quaternion):
	if !driver.did_accelerate:
		drift_controller.reset()
		grip_force = grip_controller.reset()
		return
	if !vehicle_state.vehicle_moving_forward:
		drift_controller.reset()
		grip_force = grip_controller.reset()
		return
	if is_zero_approx(omega_reference):
		grip_force = grip_controller.adjust(0, vehicle_state.velocity_sideways)
		drift_controller.reset()
	else:
		grip_force = drift_controller.adjust(0, vehicle_state.velocity_sideways)
		grip_controller.reset()
	var direction: Vector3 = vehicle_rotation * Vector3.LEFT
	var grip_force_vector: Vector3 = direction * grip_force
	apply_force(grip_force_vector, offset_drive)

func update_wheel_rotation(delta: float, steering: float):
	fl.rotate_wheel(delta, wheel_state.total_movement_front, steering)
	fr.rotate_wheel(delta, wheel_state.total_movement_front, steering)
	rl.rotate_wheel(delta, wheel_state.total_movement_rear, 0)
	rr.rotate_wheel(delta, wheel_state.total_movement_rear, 0)

func accelerate():
	if gearbox.gear_changing:
		return
	var vmax: float = gearbox.get_vmax()
	acceleration_force = gearbox.force_max_value[gearbox.gear - 1] * force_curve.sample(velocity_measurement / vmax)
	var force_vector: Vector3 = vehicle_state.vehicle_direction * acceleration_force
	apply_force(force_vector, offset_drive)

func reverse():
	var velocity_max_reverse: float = 7
	if velocity_measurement < velocity_max_reverse:
		acceleration_force = gearbox.force_max_value[1]
		var force_vector: Vector3 = vehicle_state.vehicle_direction * acceleration_force
		apply_force(-force_vector, offset_drive)

func brake(vehicle_velocity_magnitude: float):
	var brake_force: Vector3
	vehicle_state.brake()
	omega_reference = 0
	if vehicle_velocity_magnitude > 0.5:
		brake_force = brake_value * vehicle_state.velocity_direction
	else:
		brake_force = brake_value * linear_velocity
	apply_force(-brake_force, offset_drive)

func get_turn_radius(vehicle_velocity_magnitude: float) -> float:
	var radius: float
	var radius_min: float = 1.1 * wheelbase
	if angular_velocity.y > 0:
		radius = min(999, vehicle_velocity_magnitude / angular_velocity.y)
		if radius < radius_min:
			radius = radius_min
	else: if angular_velocity.y < 0:
		radius = max(-999, vehicle_velocity_magnitude / angular_velocity.y)
		if radius > -radius_min:
			radius = -radius_min
	else:
		radius = 999
	if radius > -radius_min && radius < radius_min:
		print_debug("turn radius?")
	return radius

func update_suspension(delta: float, vehicle_rotation: Quaternion) -> bool:
	var contact_front: bool
	var contact_rear: bool
	contact_front = fl.add_spring_force(delta, self, vehicle_rotation)
	contact_front = fr.add_spring_force(delta, self, vehicle_rotation) && contact_front
	contact_rear = rl.add_spring_force(delta, self, vehicle_rotation)
	contact_rear = rr.add_spring_force(delta, self, vehicle_rotation) && contact_rear
	return contact_front && contact_rear

class VehicleState:
	var velocity_front_axis: float
	var velocity_rear_axis: float
	var velocity_sideways: float
	var vehicle_direction: Vector3
	var velocity_direction: Vector3
	var vehicle_moving_forward: bool
	var drift_angle_measurement: float

	func update(vehicle_rotation: Quaternion, vehicle_velocity: Vector3):
		var vehicle_direction_sideways: Vector3 = vehicle_rotation * Vector3.LEFT
		vehicle_direction = vehicle_rotation * Vector3.FORWARD
		velocity_front_axis = vehicle_velocity.length()
		velocity_rear_axis = vehicle_velocity.dot(vehicle_direction)
		velocity_sideways = vehicle_velocity.dot(vehicle_direction_sideways)
		if velocity_front_axis > 0.1:
			velocity_direction = vehicle_velocity.normalized()
		else:
			velocity_direction = vehicle_direction
		vehicle_moving_forward = vehicle_direction.dot(velocity_direction) > 0
		var cross_product: Vector3
		if vehicle_moving_forward:
			cross_product = vehicle_direction.cross(velocity_direction)
		else:
			cross_product = velocity_direction.cross(vehicle_direction)
		if velocity_front_axis > 0.1:
			drift_angle_measurement = asin(cross_product.y)
		if !vehicle_moving_forward:
			velocity_front_axis = -velocity_front_axis
	
	func brake():
		velocity_front_axis = 0
		velocity_rear_axis = 0

class WheelState:
	var total_movement_front: float
	var total_movement_rear: float

	func update(delta: float, velocity_front_axis: float, velocity_rear_axis: float):
		total_movement_front += delta * velocity_front_axis
		total_movement_rear += delta * velocity_rear_axis
