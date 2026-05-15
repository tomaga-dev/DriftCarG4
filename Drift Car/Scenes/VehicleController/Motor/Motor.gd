extends Node

class_name Motor

@export var drift_angle_max: float = 30

var on: float = 0
var off: float = 0
var time_start: int = Time.get_ticks_msec()
var time_now: int
var time_diff: int = 52 # milliseconds
var speed_now: float = 0
var speed_delta: float = 0.5
var rev_normalized_max: float = 1

func update_state(car: VehicleController) -> float:
	var cut_off: bool
	var vmax: float = car.gearbox.get_vmax()
	var v_cut_off: float = vmax * 0.97
	var rev_normalized: float
	time_now = Time.get_ticks_msec()
	if time_now >= time_start + 2 * time_diff:
		time_start = time_now
	if time_now >= time_start + time_diff:
		cut_off = true
	else:
		cut_off = false
	if car.driver.did_declutch:
		rev_normalized = get_rev_from_accelerator(car, v_cut_off, cut_off)
	else:
		rev_normalized = get_rev_from_speed(car, v_cut_off, cut_off)
	return rev_normalized * rev_normalized_max

func set_speed_now(car: VehicleController, v_cut_off: float, cut_off: bool, has_grip: bool) -> void:
	var speed: float = car.linear_velocity.length()
	if car.driver.did_accelerate:
		var drift_angle: float = rad_to_deg(car.vehicle_state.drift_angle_measurement)
		var is_drifting: bool = drift_angle < -drift_angle_max || drift_angle > drift_angle_max
		if is_drifting || !has_grip:
			speed_now += speed_delta * rev_normalized_max
		else:
			speed_now = speed
		if speed_now > v_cut_off && cut_off:
			speed_now = v_cut_off
	else:
		speed_now -= 0.4 * speed_delta * rev_normalized_max
		if speed_now < speed:
			speed_now = speed

func get_rev_from_accelerator(car: VehicleController, v_cut_off: float, cut_off: bool) -> float:
	var vmax: float = car.gearbox.get_vmax()
	set_speed_now(car, v_cut_off, cut_off, false)
	var rev_normalized: float = speed_now / vmax
	set_volume(car, speed_now, v_cut_off)
	return rev_normalized

func get_rev_from_speed(car: VehicleController, v_cut_off: float, cut_off: bool) -> float:
	var vmax: float = car.gearbox.get_vmax()
	set_speed_now(car, v_cut_off, cut_off, true)
	var rev_normalized: float = speed_now / vmax
	set_volume(car, speed_now, v_cut_off)
	return rev_normalized

func set_volume(car: VehicleController, speed: float, v_cut_off: float) -> void:
	on = -40
	off = -20
	if car.gearbox.gear_changing:
		on = -40
	else: if !car.on_ground:
		on = -40
	else: if car.driver.did_accelerate:
		if speed > v_cut_off:
			on = -40
		else:
			on = -3
