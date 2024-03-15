extends Node2D

# ***********************
# Editable variables
# ***********************

var vent: float = 8.1
var vaw: float = 1.0
var valg: float = 1.5
var valb: float = 0.5
var q: float = 4.2
var va: float = 1.7
var vc: float = 0.5
var vv: float = 3.0
var vti: float = 70.0
var mo2: float = 0.119

# ***********************
# Model parameters
# ***********************

var k1o2:float = 0.0025
var R:float = 8.314
var T:float = 310
var time:float = 0.0
var dt:float = 0.001
# Air compartment parameters
var pp_O2_air_t0:float = 21331.6
var pp_O2_air_t1:float = 0.0

# Airways compartment parameters
var pp_O2_aw_t0:float = 17300
var pp_O2_aw_t1:float = 0.0

# Alveols compartment parameters
var pp_O2_alv_t0:float = 13900
var pp_O2_alv_t1:float = 0.0

# ***********************
# Compartments functions
# ***********************

## Compute the partial pressure of air

## Compute the partial pressure of aw
func airways():
	var delta = ((vent*(pp_O2_air_t0-pp_O2_aw_t0)-k1o2*(pp_O2_aw_t0-pp_O2_alv_t0)*R*T)/vaw)*dt
	pp_O2_aw_t1 = pp_O2_aw_t0 + delta

## Execute One step (dt) of the model
func step():
	# Display parameters
	print("Time = " + str(time))
	print("    O2 in aw en Pa = " + str(pp_O2_aw_t0))
	time = time + dt
	
		# Compute one step
	airways()
	
		# Prepare the next step
	pp_O2_aw_t0 	= pp_O2_aw_t1

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

func _on_text_vent(new_text):
	if(new_text==""):
		vent = 8.1
	else:
		vent = float(new_text)
	print("Nouvelle valeur de V̇: " +str(vent))
	
func _on_text_vaw(new_text):
	if(new_text==""):
		vaw = 1.0
	else:
		vaw = float(new_text)
	print("Nouvelle valeur de V𝑨𝒘: " +str(vaw))
	
func _on_text_valg(new_text):
	if(new_text==""):
		valg = 1.5
	else:
		valg = float(new_text)
	print("Nouvelle valeur de V𝑨𝒍𝒈: " +str(valg))
	
func _on_text_valb(new_text):
	if(new_text==""):
		valb = 0.5
	else:
		valb = float(new_text)
	print("Nouvelle valeur de V𝑨𝒍𝒃: " +str(valb))
	
func _on_text_cardiac(new_text):
	if(new_text==""):
		q = 4.2
	else:
		q = float(new_text)
	print("Nouvelle valeur de Q̇: " +str(q))
	
func _on_text_va(new_text):
	if(new_text==""):
		va = 1.7
	else:
		va = float(new_text)
	print("Nouvelle valeur de V𝑨: " +str(va))
	
func _on_text_vc(new_text):
	if(new_text==""):
		vc = 0.5
	else:
		vc = float(new_text)
	print("Nouvelle valeur de V𝒄: " +str(vc))
	
func _on_text_vv(new_text):
	if(new_text==""):
		vv = 3.0
	else:
		vv = float(new_text)
	print("Nouvelle valeur de V𝒗: " +str(vv))
	
func _on_text_vti(new_text):
	if(new_text==""):
		vti = 70.0
	else:
		vti = float(new_text)
	print("Nouvelle valeur de V𝒕𝒊: " +str(vti))
	
func _on_text_metabolism(new_text):
	if(new_text==""):
		mo2 = 0.119
	else:
		mo2 = float(new_text)
	print("Nouvelle valeur de ṀO₂: " +str(mo2))
	
