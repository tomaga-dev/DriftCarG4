extends Node

class_name Driver

var did_steer: bool
var did_steer_left: bool
var did_steer_right: bool
var did_accelerate: bool
var did_brake: bool
var did_reverse: bool
var did_counter_steer: bool

func start_query():
	did_steer = false
	did_steer_left = false
	did_steer_right = false
	did_accelerate = false
	did_reverse = false
	did_brake = false

func turn_left():
	did_steer_left = true
	did_steer = true

func turn_right():
	did_steer_right = true
	did_steer = true

func accelerate():
	did_accelerate = true

func brake():
	did_brake = true

func reverse():
	did_reverse = true
