extends Node2D

# ***********************
# Model parameters
# ***********************
var time:float = 0.0
var dt:float = 0.001
# Air compartment parameters
var pp_O2_air_t0:float = 1.0
var pp_O2_air_t1:float = 0.0

# Airways compartment parameters
var pp_O2_aw_t0:float = 1.0
var pp_O2_aw_t1:float = 0.0

# Alveols compartment parameters
var pp_O2_alv_t0:float = 1.0
var pp_O2_alv_t1:float = 0.0

# ***********************
# Compartment functions
# ***********************

## Compute the partial pressure of aw
func airways():
	var delta = (0.8 * pp_O2_aw_t0 + 0.1 * pp_O2_air_t0 + 0.1 * pp_O2_alv_t0)*dt
	pp_O2_aw_t1 = pp_O2_aw_t0 + delta

## Execute One step (dt) of the model
func step():
	# Display parameters
	print("Time = " + str(time))
	print("    O2 aw = " + str(pp_O2_aw_t0))

	# Compute one step
	airways()
	
	# Prepare the next step
	pp_O2_air_t0 	= pp_O2_air_t1
	pp_O2_aw_t0 	= pp_O2_aw_t1
	pp_O2_alv_t0 	= pp_O2_alv_t1
	
	time = time + dt

# ***********************
# Simulator functions
# ***********************

# Simulator parameters
var play:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if play == true:
		step()

func _on_play_button_down():
	play = true

func _on_stop_button_down():
	play = false
