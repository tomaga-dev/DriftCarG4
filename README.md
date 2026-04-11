# DriftCarG4
This is a port of the [drift car project](https://notabug.org/tomaga/DriftCarProject) to Godot 4.

### Preview
![Screenshot](Screenshot.jpg)

To try out this project you first have to download the [Godot Engine](https://godotengine.org/). In Godot click the import button. Locate the folder "Drift Car". Then double click "project.godot". The project will be loaded. Once done you just have to click the play-button located at the top right corner.

### How to drift
The car has a behaviour which is called lift-off oversteer. This means when you turn a corner and release the accelerator and then press it again, the car will enter drift mode. In drift mode you can take much tighter turns than normally. To leave drift mode you should counter steer until your car points to the desired direction.

### How it works
There is no friction model for the tires. Instead, drifting is modeled for an arcade-style gaming experience. This means that drifting should be easy for the player to control. There are several PID controllers that regulate the car’s angular velocity and simulate the lateral forces of the tires. The Omega controller regulates the angular velocity. The Drift controller regulates the drift angle, and the Steering controller ensures normal steering behaviour. When cornering, an artificial torque is applied to the car: the steering torque. This has nothing to do with real cars. A real car takes corners because lateral forces act on the front tires. This is a purely arcade-style model. To move the car, a single force is applied to the body. This, too, has nothing to do with real cars. We can now move and steer the car (using the steering torque), but it looks completely unrealistic (like controlling a spaceship in space or a boat on water). To make it look more realistic, we simulate the lateral forces of the tires using our Steering controller. The Steering controller measures the car’s lateral velocity and applies a lateral force to the body to reduce the lateral velocity. Now we can drive the car almost like a real car, though not at very low speeds. But that doesn’t matter, because we want a drift car, not a parking simulator. To make the car drift, we use the Drift controller. This controller also adds a lateral force to the body of the car, but it does not try to set the sideways velocity to zero. Because of that our car is now drifting. When going straight, the angular velocity becomes zero and the car returns to regular steering mode.

### Camera modes
You can change the camera modes in the Godot editor. Click on Camera in the scene tab, then in the inspector tab you can choose first person or third person. If you choose neither of them, the camera will be third person but with a fixed angle. In race mode, the camera rotates according to the car, otherwise it points to the direction the car is moving to (which may be sideways). A high damping value (e.g. 10) lets the camera rotation follow the car's rotation very closely.

### Vehicle controller
To change settings, click on Monteri in the scene tab. You can set the max force to a higher value (e.g. 30000). This allows the car to accelerate much better. Rev min will set the minimum motor sound frequency. Rev multiplier will adjust the frequency range of the motor sound. Omega max sets the maximum angular velocity in regular steering mode. Omega max drift sets the maximum angular velocity in drift mode (try higher values to get a feeling for it).

### Player
If you have more than one car in your scene you can set the players car here.

### Godot version
This project was tested with Godot 4.6.

### Credits
The [font](https://fonts.google.com/) used in this project courtesy of Google.

### License
Licensed under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
