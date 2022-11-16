extends Camera3D

@export var target_node: NodePath

var target: Node3D
var distance_measured: Vector3
var distance_magnitude: float

func _ready():
	target = get_node(target_node)
	distance_measured = target.global_transform.origin - global_transform.origin
	distance_magnitude = distance_measured.length()

func _physics_process(_delta: float):
	var cameraRotation = Quaternion(transform.basis)
	transform.origin = target.global_transform.origin - cameraRotation * Vector3.FORWARD * distance_magnitude
