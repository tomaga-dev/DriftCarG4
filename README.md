# DriftCarG4

This is a port of the [drift car project](https://notabug.org/tomaga/DriftCarProject) to Godot 4.

### Preview

![Screenshot](Screenshot.jpg)

To try out this project you first have to download the [Godot Engine](https://godotengine.org/). In Godot click the import button. Locate the folder "Drift Car". Then double click "project.godot". The project will be loaded. Once done you just have to click the play-button located at the top right corner.

### How to drift

The car has a behaviour which is called lift-of-oversteer. This means when you turn the car and release the accelerator and then press it again, the car will enter drift mode. In drift mode you can make much tighter turns than normally. To leave drift mode you should counter steer until your car points into the desired direction.

### How it works

There is no friction model of the tires. Instead the drifting is modelled for an arcade-style experience. This means drifting should be easy to control for the player. There are a few PID-controllers that regulate the angular velocity of the car and the lateral forces of the tires. The omega controller regulates the angular velocity. The drift controller regulates the drift angle and the grip controller is responsible for the car to leave drift mode. There is also a steering controller which handles normal steering behaviour. When turning, an artificical torque is applied to the car, the steering torque. This has nothing to do with real life cars. A real car turns because forces act lateral to the front tires. This is purly an arcade-style model. To move the car a single force is applied to the body of the car. This also has nothing to do with real cars. We can now move the car and turn it (with the steering torque), but it looks totally unrealistic (like controlling a space ship in space or a boat on the water). To make it look more realistic, we simulate the lateral forces of the tires with our steering controller. The steering controller measures the sideways velocity of the car and adds a lateral force to the body of the car in order to reduce the sideways velocity. Now we can drive the car nearly like a real car, but not at very low speeds. But that doesn't matter because we want a drift car, not a parking simulator. To make the car drift, we use the drift controller. This controller also adds a lateral force to the body of the car, but it does not try to make the sideways velocity zero. Because of that our car is now drifting. To leave drifting mode and to return to regular steering, the grip controller is used. It is switched on when the angular velocity is nearly zero. Then it tries to make the drift angle zero

### Godot Version
This project was tested with Godot 4.0.

### Credits

The [font](https://fonts.google.com/) used in this project courtesy of Google.

### License

Licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
