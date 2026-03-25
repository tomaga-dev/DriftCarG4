extends Node

@export var car_node: NodePath

var car: VehicleController


func _ready() -> void:
	car = get_node(car_node)
	car.controlled_by_player = true

func get_player_input(driver: Driver) -> void:
	if Input.is_action_pressed("controller_brake"):
		driver.brake()
	if Input.is_action_pressed("controller_accelerate"):
		driver.accelerate()
	if Input.is_action_pressed("controller_left"):
		driver.turn_left()
	if Input.is_action_pressed("controller_right"):
		driver.turn_right()
	if Input.is_action_pressed("controller_reverse"):
		driver.reverse()
	if Input.is_action_pressed("controller_declutch"):
		driver.declutch()

func query_driver(vehicle: VehicleController) -> void:
	if vehicle != car:
		return
	var driver: Driver = vehicle.driver
	driver.start_query()
	get_player_input(driver)

func _on_monteri_query_driver(vehicle: VehicleController) -> void:
	query_driver(vehicle)
