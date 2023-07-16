extends Node

@export var on_node: NodePath
@export var off_node: NodePath

var on: AudioStreamPlayer3D
var off: AudioStreamPlayer3D

var rev_min: float = 1
var rev_multiplier: float = 5 # Higher values result in higher revs.
var amplification_on: AudioEffectAmplify
var amplification_off: AudioEffectAmplify
var time_start: int
var time_now: int
var time_diff: float


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
	var v_cut_off = vmax * 0.94
	var speed: float = car.linear_velocity.length()
	var gradient: float = rev_multiplier * speed / vmax
	var pitch: float
	time_now = Time.get_ticks_msec()
	if time_now >= time_start + 105:
		time_diff = 0.5 * (time_now - time_start)
		time_start = time_now
	if time_now >= time_start + time_diff:
		cut_off = true
	else:
		cut_off = false
	if car.on_ground:
		if car.is_shifting():
			amplification_on.volume_db = -40
			amplification_off.volume_db = -20
		else: if car.driver.did_accelerate:
			if speed > v_cut_off && cut_off:
				amplification_on.volume_db = -40
			else:
				amplification_on.volume_db = 0
			amplification_off.volume_db = -40
		else:
			amplification_on.volume_db = -40
			amplification_off.volume_db = -4 * gradient
	else:
		amplification_on.volume_db = -40
		amplification_off.volume_db = -20
	pitch = rev_min + gradient
	on.pitch_scale = pitch
	off.pitch_scale = pitch
