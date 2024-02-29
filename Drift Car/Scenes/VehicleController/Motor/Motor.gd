extends Node

class_name Motor

var on: float = 0
var off: float = 0
var time_start: int = Time.get_ticks_msec()
var time_now: int
var time_diff: int = 52 # milliseconds
var should_sync_speed: bool = false
var speed_now: float = 0
var speed_delta: float = 0.5
var rev_normalized_max = 1

func update_state(car: VehicleController) -> float:
	var cut_off: bool
	var vmax: float = car.gearbox.get_vmax()
	var v_cut_off: float = vmax * 0.97
	var speed: float = car.linear_velocity.length()
	var rev_normalized: float = get_rev_from_speed(speed, vmax)
	time_now = Time.get_ticks_msec()
	if time_now >= time_start + 2 * time_diff:
		time_start = time_now
	if time_now >= time_start + time_diff:
		cut_off = true
	else:
		cut_off = false
	set_volume(car, speed, v_cut_off, cut_off, rev_normalized)
	synchronize_speed()
	return rev_normalized * rev_normalized_max

func set_volume(car: VehicleController, speed: float, v_cut_off: float, cut_off: bool, rev_normalized: float):
	if car.gearbox.gear_changing:
		on = -40
		off = -20
	else: if !car.on_ground:
		on = -40
		off = -20
	else: if car.driver.did_accelerate:
		if speed > v_cut_off && cut_off:
			on = -40
		else:
			on = -3
		off = -40
	else:
		on = -40
		off = -20 * rev_normalized

func synchronize_speed():
	should_sync_speed = true

func get_rev_from_speed(speed: float, vmax: float) -> float:
	if is_zero_approx(speed):
		speed = speed_now
	if should_sync_speed:
		speed_now = speed
		should_sync_speed = false
	var rev_normalized: float = speed / vmax
	return rev_normalized
