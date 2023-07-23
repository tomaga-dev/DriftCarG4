extends Node

@export var on_node: NodePath
@export var off_node: NodePath
@export var rev_min: float = 1.6
@export var rev_multiplier: float = 5.5 # Higher values result in higher revs.

var on: AudioStreamPlayer3D
var off: AudioStreamPlayer3D

var amplification_on: AudioEffectAmplify
var amplification_off: AudioEffectAmplify
var on_volume: float
var off_volume: float
var time_start: int
var time_now: int
var time_diff: int = 52 # milliseconds


func _ready():
	on = get_node(on_node)
	off = get_node(off_node)
	on.play()
	off.play()
	time_start = Time.get_ticks_msec()
	var index_amplifier_on = AudioServer.get_bus_index("On")
	amplification_on = AudioServer.get_bus_effect(index_amplifier_on, 0)
	var index_amplifier_off = AudioServer.get_bus_index("Off")
	amplification_off = AudioServer.get_bus_effect(index_amplifier_off, 0)

func _on_monteri_update_motor_sound(vehicle_controller):
	var car = vehicle_controller
	var cut_off: bool
	var vmax: float = car.gearbox.get_vmax()
	var v_cut_off = vmax * 0.97
	var speed: float = car.linear_velocity.length()
	var gradient: float = rev_multiplier * speed / vmax
	var pitch: float
	time_now = Time.get_ticks_msec()
	if time_now >= time_start + 2 * time_diff:
		time_start = time_now
	if time_now >= time_start + time_diff:
		cut_off = true
	else:
		cut_off = false
	if car.on_ground:
		update_sound(car, speed, v_cut_off, cut_off, gradient)
	else:
		on_volume = -40
		off_volume = -20
	amplification_on.volume_db = on_volume
	amplification_off.volume_db = off_volume
	pitch = rev_min + gradient
	on.pitch_scale = pitch
	off.pitch_scale = pitch

func update_sound(car: VehicleController, speed: float, v_cut_off: float, cut_off: bool, gradient: float):
	if car.gearbox.gear_changing:
		on_volume = -40
		off_volume = -20
	else: if car.driver.did_accelerate:
		if speed > v_cut_off && cut_off:
			on_volume = -40
		else:
			on_volume = -3
		off_volume = -40
	else:
		on_volume = -40
		off_volume = -4 * gradient


