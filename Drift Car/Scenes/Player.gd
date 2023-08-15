extends Node

@export var car_node: NodePath
@export var needle_node: NodePath

var car: VehicleController
var needle: TextureRect
var m: float
var b: float


func _ready():
	car = get_node(car_node)
	needle = get_node(needle_node)
	var k = 0.5 * PI + PI
	# max revolutions = 7 (thousand)
	m = 6.2 / 7 * k
	b = 0.8 / 7 * k

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

func query_driver(car_of_driver: VehicleController, rev_normalized: float):
	car_of_driver.driver.start_query()
	if car_of_driver == car:
		get_player_input(car_of_driver.driver)
		needle.rotation = -PI + m * rev_normalized + b

func _on_monteri_query_driver(car_of_driver, rev_normalized):
	query_driver(car_of_driver, rev_normalized)
