extends Camera3D

@export var target_node: NodePath
@export var vehicle_controller_node: NodePath
@export var fixed_angle: bool = true

var target: Node3D
var vehicle_controller: Node3D
var distance_measured: Vector3
var distance_magnitude: float

func _ready():
	target = get_node(target_node)
	vehicle_controller = get_node(vehicle_controller_node)
	vehicle_controller.visible = fixed_angle
	distance_measured = target.global_transform.origin - global_transform.origin
	distance_magnitude = distance_measured.length()

func _physics_process(_delta: float):
	if fixed_angle:
		follow()
	else:
		view_from_inside()

func view_from_inside():
	var targetRotation = Quaternion(target.global_transform.basis)
	var euler: Vector3 = targetRotation.get_euler()
	euler.z = 0
	targetRotation = Quaternion(euler)
	transform.basis = Basis(targetRotation)
	transform.origin = target.global_transform.origin

func follow():
	var targetRotation = Quaternion(transform.basis)
	transform.origin = target.global_transform.origin - targetRotation * Vector3.FORWARD * distance_magnitude
