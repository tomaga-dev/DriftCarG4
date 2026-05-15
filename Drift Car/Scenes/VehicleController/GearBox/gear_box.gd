extends Node

class_name GearBox

@export var v_max: float = 62

var gear_shift_start_time: int
var gear_shift_time: int = 333 # in milliseconds
var gear_max: int
var gear: int
var gear_changing: bool
var vmin: Array = [0, 0, 0.22, 0.4, 0.63, 0.8]
var vmax: Array = [0, 0.4, 0.63, 0.8, 1.0, 1.1]
var force_max_value: Array = [1.0, 0.9, 0.8, 0.7, 0.6, 0.5]

func _init() -> void:
	gear_max = vmax.size() - 1
	gear = 1
	gear_changing = false
	gear_shift_start_time = 0

func get_vmax() -> float:
	return v_max * vmax[gear]

func select_gear(speed: float, accelerating: bool) -> void:
	if Time.get_ticks_msec() < gear_shift_start_time + gear_shift_time:
		return
	gear_changing = false
	gear_shift_start_time = 0
	if accelerating:
		if gear < gear_max:
			if speed > 0.95 * v_max * vmax[gear]:
				gear += 1
				gear_changing = true
				gear_shift_start_time = Time.get_ticks_msec()
		if speed < v_max * vmin[gear]:
			for index: int in range(vmin.size()):
				if v_max * vmin[index] < speed:
					gear = index
					gear_changing = true
					gear_shift_start_time = Time.get_ticks_msec()
	else:
		if gear > 1:
			if speed < v_max * vmin[gear]:
				gear -= 1
