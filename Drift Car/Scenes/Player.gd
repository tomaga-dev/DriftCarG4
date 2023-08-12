extends Node

@export var car_node: NodePath

var car: VehicleController


func _ready():
	car = get_node(car_node)

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

func query_driver(car_of_driver: VehicleController, _rev_normalized: float):
	car_of_driver.driver.start_query()
	if car_of_driver == car:
		get_player_input(car_of_driver.driver)

func _on_monteri_query_driver(car_of_driver, rev_normalized):
	query_driver(car_of_driver, rev_normalized)
