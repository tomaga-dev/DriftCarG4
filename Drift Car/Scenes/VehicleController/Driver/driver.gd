extends Node

class_name Driver

var did_steer_left: bool
var did_steer_right: bool
var did_accelerate: bool
var did_declutch: bool
var did_brake: bool
var did_reverse: bool

func start_query() -> void:
	did_steer_left = false
	did_steer_right = false
	did_accelerate = false
	did_declutch = false
	did_reverse = false
	did_brake = false

func turn_left() -> void:
	did_steer_left = true

func turn_right() -> void:
	did_steer_right = true

func accelerate() -> void:
	did_accelerate = true

func declutch() -> void:
	did_declutch = true

func brake() -> void:
	did_brake = true

func reverse() -> void:
	did_reverse = true
