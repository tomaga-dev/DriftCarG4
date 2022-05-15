extends Node

@export var f1_node: NodePath
@export var f2_node: NodePath
@export var f3_node: NodePath

var f1: AudioStreamPlayer3D
var f2: AudioStreamPlayer3D
var f3: AudioStreamPlayer3D
var rev_min: float = 1
var rev_multiplier: float = 6 # Higher values result in higher revs.
var amplification_high: AudioEffectAmplify
var amplification_mid: AudioEffectAmplify
var amplification_low: AudioEffectAmplify
var time_start: int
var time_now: int
var time_diff: float


func _ready():
	f1 = get_node(f1_node)
	f2 = get_node(f2_node)
	f3 = get_node(f3_node)
	f1.play()
	f2.play()
	f3.play()
	var index_low = AudioServer.get_bus_index("Low")
	amplification_low = AudioServer.get_bus_effect(index_low, 0)
	var index_mid = AudioServer.get_bus_index("Mid")
	amplification_mid = AudioServer.get_bus_effect(index_mid, 0)
	var index_high = AudioServer.get_bus_index("High")
	amplification_high = AudioServer.get_bus_effect(index_high, 0)
	time_start = Time.get_ticks_msec()

func _on_monteri_update_motor_sound(vehicle_controller):
	var car: VehicleController = vehicle_controller
	var cut_off: bool
	var vmax: float = car.gearbox.get_vmax()
	var v_cut_off = vmax * 0.94
	var speed: float = car.linear_velocity.length()
	var pitch = rev_min + rev_multiplier * speed / vmax
	time_now = Time.get_ticks_msec()
	if time_now >= time_start + 105:
		time_diff = 0.5 * (time_now - time_start)
		time_start = time_now
	if time_now >= time_start + time_diff:
		cut_off = true
	else:
		cut_off = false
	if car.driver.did_accelerate && car.on_ground:
		amplification_low.volume_db = 6
		amplification_mid.volume_db = 6
		if speed > v_cut_off && cut_off:
			amplification_high.volume_db = -24
		else:
			amplification_high.volume_db = 0
	else:
		amplification_low.volume_db = 6
		amplification_mid.volume_db = -3
		amplification_high.volume_db = -20
	f1.pitch_scale = pitch
	f2.pitch_scale = pitch
	f3.pitch_scale = pitch
