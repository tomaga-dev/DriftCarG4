extends Camera3D

@export var player_node: NodePath
@export var first_person: bool = false
@export var third_person: bool = true
@export var damping: float = 1

var player: Node
var target: Node3D
var vehicle_controller: VehicleController
var distance_measured: Vector3
var distance_magnitude: float
var x_rotation: Quaternion

func _ready():
	player = get_node(player_node)
	vehicle_controller = player.car
	target = vehicle_controller.get_node("CameraTarget")
	vehicle_controller.visible = !first_person
	distance_measured = target.global_transform.origin - global_transform.origin
	distance_magnitude = distance_measured.length()
	var euler: Vector3 = Quaternion(transform.basis).get_euler()
	x_rotation = Quaternion(Vector3.RIGHT, euler.x)

func _physics_process(delta: float):
	if first_person:
		first_person_view()
	else: if third_person:
		smooth_follow(delta)
	else:
		follow()

func first_person_view():
	var cameraRotation = Quaternion(target.global_transform.basis)
	transform.basis = Basis(cameraRotation)
	transform.origin = target.global_transform.origin

func follow():
	var cameraRotation = Quaternion(transform.basis)
	transform.origin = target.global_transform.origin - cameraRotation * Vector3.FORWARD * distance_magnitude

func smooth_follow(delta: float):
	var target_rotation = Quaternion(target.global_transform.basis)
	var euler: Vector3 = target_rotation.get_euler()
	euler.z = 0
	target_rotation = Quaternion.from_euler(euler)
	var wanted_rotation = target_rotation * x_rotation
	var current_rotation = Basis(transform.basis.orthonormalized())
	var camera_rotation = current_rotation.slerp(wanted_rotation, damping * delta)
	transform.basis = Basis(camera_rotation)
	transform.origin = target.global_transform.origin - camera_rotation * Vector3.FORWARD * distance_magnitude
