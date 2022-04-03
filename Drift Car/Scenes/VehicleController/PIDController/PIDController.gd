extends Node

class_name PIDController

@export var kp: float = 1
@export var ki: float = 0
@export var kd: float = 0

var error: float
var error_before: float
var integral_error: float
var delta_error: float
var reference: float
var measurement: float
var result: float

func reset() -> float:
	error = 0
	error_before = 0
	integral_error = 0
	delta_error = 0
	reference = 0
	measurement = 0
	result = 0
	return result

func adjust(reference_value: float, measurement_value: float) -> float:
	reference = reference_value
	measurement = measurement_value
	error = reference - measurement
	integral_error += error
	delta_error = error - error_before
	error_before = error
	result = kp * error + ki * integral_error + kd * delta_error
	return result

