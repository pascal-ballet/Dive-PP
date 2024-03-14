extends Node2D

# ***********************
# Model parameters
# ***********************
var age: int = 25
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
# Compartments functions
# ***********************

## Compute the partial pressure of air



## Compute the partial pressure of aw
func airways():
	var delta = (0.8 * pp_O2_aw_t0 + 0.1 * pp_O2_air_t0 + 0.1 * pp_O2_alv_t0)*dt
	pp_O2_aw_t1 = pp_O2_aw_t0 + delta

## Execute One step (dt) of the model
func step():
	# Display parameters
	print(str(age))
	print("Time = " + str(time))
	print("    O2 in aw = " + str(pp_O2_aw_t0))

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
	$RichTextLabel.bbcode_enabled = true
	$RichTextLabel.bbcode_text = "[center]Application to compute Partial Pressure of O2 and N2 in human body[/center]"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if play == true:
		step()

func _on_play_button_down():
	play = true

func _on_stop_button_down():
	play = false

# ***********************
# Variable change functions
# *********************** 

func _on_text_age(new_text):
	if(new_text==""):
		age = 25
	else:
		age = int(new_text)
	print("Nouvel âge: " +str(age))

