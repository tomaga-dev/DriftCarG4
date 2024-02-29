extends Camera3D

@export var vehicle_node: NodePath
@export var first_person: bool = false
@export var third_person: bool = true
@export var race_mode: bool = true
@export var damping: float = 1

var target: Node3D
var vehicle_controller: VehicleController
var distance_measured: Vector3
var distance_magnitude: float
var x_rotation: Quaternion
var y_rotation: Quaternion
var z_rotation: Quaternion

func _ready():
	vehicle_controller = get_node(vehicle_node)
	target = vehicle_controller.get_node("CameraTarget")
	vehicle_controller.visible = !first_person
	distance_measured = target.global_transform.origin - global_transform.origin
	distance_magnitude = distance_measured.length()
	var euler: Vector3 = Quaternion(transform.basis).get_euler()
	x_rotation = Quaternion(Vector3.RIGHT, euler.x)
	y_rotation = Quaternion(Vector3.UP, euler.y)
	z_rotation = Quaternion(Vector3.FORWARD, 0)

func _physics_process(delta: float):
	if first_person:
		first_person_view()
	else: if third_person:
		smooth_follow(delta)
	else:
		follow()

func first_person_view():
	var camera_global_rotation = Quaternion(target.global_transform.basis)
	transform.basis = Basis(camera_global_rotation)
	transform.origin = target.global_transform.origin

func follow():
	var camera_rotation = Quaternion(transform.basis)
	transform.origin = target.global_transform.origin - camera_rotation * Vector3.FORWARD * distance_magnitude

func smooth_follow(delta: float):
	var the_rotation: Quaternion = get_vehicle_rotation()
	if !race_mode:
		the_rotation = get_velocity_rotation()
	var euler: Vector3 = the_rotation.get_euler()
	euler.x = 0
	euler.z = 0
	y_rotation = Quaternion.from_euler(euler)
	var wanted_rotation = z_rotation * y_rotation * x_rotation
	var current_rotation = Basis(transform.basis.orthonormalized())
	var camera_rotation = current_rotation.slerp(wanted_rotation, damping * delta)
	transform.basis = Basis(camera_rotation)
	camera_rotation = Quaternion(transform.basis)
	transform.origin = target.global_transform.origin - camera_rotation * Vector3.FORWARD * distance_magnitude

func get_velocity_rotation() -> Quaternion:
	var velocity_direction: Vector3 = vehicle_controller.vehicle_state.velocity_direction
	var velocity_rotation: Quaternion = Quaternion(Vector3.FORWARD, velocity_direction)
	velocity_rotation = velocity_rotation.normalized()
	return velocity_rotation

func get_vehicle_rotation() -> Quaternion:
	var vehicle_direction: Vector3 = vehicle_controller.vehicle_state.vehicle_direction
	var vehicle_rotation: Quaternion = Quaternion(Vector3.FORWARD, vehicle_direction)
	vehicle_rotation = vehicle_rotation.normalized()
	return vehicle_rotation
