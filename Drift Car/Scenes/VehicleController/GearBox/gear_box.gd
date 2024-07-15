extends Node

class_name GearBox

var gear_shift_start_time: int
var gear_shift_time: int
var gear_max: int
var gear: int
var gear_changing: bool
var vmin: Array = [0, 0, 14.0, 25.0, 39.0, 50.0]
var vmax: Array = [0, 25.0, 39.0, 50.0, 58.0, 77.0]
var force_max_value: Array = [1.0, 0.8, 0.65, 0.55, 0.5, 0.5]

func _init():
	gear_max = vmax.size() - 1
	gear = 1
	gear_changing = false
	gear_shift_start_time = 0

func set_force_limits(max_force: float):
	var i: int = 0
	for value in force_max_value:
		force_max_value[i] = max_force * value
		i += 1 
	
func get_vmax() -> float:
	return vmax[gear]

func select_gear(speed: float, accelerating: bool):
	if Time.get_ticks_msec() < gear_shift_start_time + gear_shift_time:
		return
	gear_changing = false
	gear_shift_start_time = 0
	if accelerating:
		if gear < gear_max:
			if speed > 0.95 * vmax[gear]:
				gear += 1
				gear_changing = true
				gear_shift_start_time = Time.get_ticks_msec()
		if speed < vmin[gear]:
			for index in range(vmin.size()):
				if vmin[index] < speed:
					gear = index
					gear_changing = true
					gear_shift_start_time = Time.get_ticks_msec()
	else:
		if gear > 1:
			if speed < vmin[gear]:
				gear -= 1
