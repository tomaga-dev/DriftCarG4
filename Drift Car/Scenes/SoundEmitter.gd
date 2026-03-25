extends Node3D

class_name SoundEmitter

@onready var on: AudioStreamPlayer3D = get_node("Acceleration")
@onready var off: AudioStreamPlayer3D = get_node("Deceleration")

var amplification_on: AudioEffectAmplify
var amplification_off: AudioEffectAmplify

func _ready() -> void:
	on.play()
	off.play()

func update_motor_sound(car: VehicleController) -> void:
	on.volume_db = car.motor.on
	off.volume_db = car.motor.off
	var pitch: float = car.rev_min + car.rev
	on.pitch_scale = pitch
	off.pitch_scale = pitch
