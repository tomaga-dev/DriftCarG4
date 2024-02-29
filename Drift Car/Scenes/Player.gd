extends Node

@export var rev_min: float = 0.8
@export var rev_max: float = 9
@export var car_node: NodePath
@export var needle_node: NodePath
@export var gear_node: NodePath
@export var speed_node: NodePath

var car: VehicleController
var needle: TextureRect
var gear: Label
var speed: Label
var m: float
var b: float


func _ready():
	car = get_node(car_node)
	needle = get_node(needle_node)
	gear = get_node(gear_node)
	speed = get_node(speed_node)
	var k = 0.5 * PI + PI
	m = (rev_max - rev_min) / rev_max * k
	b = rev_min / rev_max * k

func get_player_input(driver):
	if Input.is_action_pressed("controller_brake"):
		driver.brake()
	else:
		if Input.is_action_pressed("controller_accelerate"):
			driver.accelerate()
		if Input.is_action_pressed("controller_left"):
			driver.turn_left()
		if Input.is_action_pressed("controller_right"):
			driver.turn_right()
		if Input.is_action_pressed("controller_reverse"):
			driver.reverse()

func query_driver(vehicle: VehicleController, rev_normalized: float):
	vehicle.driver.start_query()
	if vehicle == car:
		var kmh: float = 3.6 * vehicle.linear_velocity.length()
		get_player_input(vehicle.driver)
		needle.rotation = -PI + m * rev_normalized + b
		gear.text = "%s" % vehicle.gearbox.gear
		speed.text = "%3.0f km/h" % kmh
	else:
		vehicle.driver.brake()

func _on_monteri_query_driver(car_of_driver, rev_normalized):
	query_driver(car_of_driver, rev_normalized)
