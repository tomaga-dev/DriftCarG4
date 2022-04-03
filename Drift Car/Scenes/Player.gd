extends Node


func _on_monteri_query_driver(driver):
	driver.start_query()
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
