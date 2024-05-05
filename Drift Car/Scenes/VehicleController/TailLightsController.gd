extends Node3D

var tail_lights: MeshInstance3D
var material: Material
var left: OmniLight3D
var right: OmniLight3D
var left_energy: float
var right_energy: float

func _ready():
	tail_lights = get_node_or_null("TailLights")
	if !tail_lights:
		return
	left = tail_lights.get_node_or_null("Left")
	left_energy = left.light_energy
	right = tail_lights.get_node_or_null("Right")
	right_energy = right.light_energy
	material = tail_lights.get_active_material(0)
	material.emission_enabled = true
	material.emission = Color(1, 0, 0)
	material.emission_energy_multiplier = 0

func show_brake_light(value: bool):
	if !material:
		return
	if value:
		material.emission_energy_multiplier = 0.4
	else:
		material.emission_energy_multiplier = 0
	if !left || !right:
		return
	if value:
		left.light_energy = left_energy
		right.light_energy = right_energy
	else:
		left.light_energy = 0
		right.light_energy = 0
