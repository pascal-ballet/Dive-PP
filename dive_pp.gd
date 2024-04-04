extends Node2D

# ***********************
# Editable variables
# ***********************

var vent: float = 8.1
var vaw: float = 1.5
var valg: float = 1.0
var valb: float = 0.5
var q: float = 4.2
var va: float = 1.7
var vc: float = 0.5
var vv: float = 3.0
var vti: float = 70.0
var mo2: float = 8.33
var patm: float = 101325.0
var fo2: float = 0.21

# ***********************
# Model parameters
# ***********************

var a: float = 55000000000.0
var b: float = 2500000.0
var hb: float = 2.1911765
var oxc:float = 4* (1.34 / 1.39)
var alpha_o2:float = 0.00000997
var ph2o:float = 6246.0
var k1o2:float = 0.0025
var k2o2:float = 0.007
var k3o2:float = 0.0025
var R:float = 8.314
var T:float = 310.0
var time:float = 0.0
var dt:float = 0.001
# Air compartment parameter
var pp_O2_air:float = 19967.0

# Airways compartment parameters
var pp_O2_aw_t0:float = 17300.0
var pp_O2_aw_t1:float = 0.0

# Alveols gas compartment parameters
var pp_O2_alv_t0:float = 14000.0
var pp_O2_alv_t1:float = 0.0

# Alveols blood compartment parameters
var pp_O2_alb_t0:float = 13300.0
var pp_O2_alb_t1:float = 0.0

# Venous blood compartment parameters
var pp_O2_v_t0:float = 5300.0
var pp_O2_v_t1 = 0.0

# Arterial blood compartment parameters
var pp_O2_a_t0 = 12800.0
var pp_O2_a_t1 = 0.0

# Capilar blood compartment parameters
var pp_O2_c_t0 = 6000.0
var pp_O2_c_t1 = 0.0

# Tissue compartment parameters
var pp_O2_ti_t0 = 2000.0
var pp_O2_ti_t1 = 0.0


# ***********************
# Compartments functions
# ***********************

## Compute the partial pressure of air
func air():
	pp_O2_air = (patm-ph2o)*fo2

## Compute the partial pressure of aw
func airways():
	var delta = ((vent/vaw*pp_O2_air)-(vent+k1o2*R*T)/vaw*pp_O2_aw_t0+(k1o2*R*T)/vaw*pp_O2_alv_t0)*dt
	pp_O2_aw_t1 = pp_O2_aw_t0 + delta

## Compute the partial pressure of alv
func alveolar():
	var delta = (-R*T/valg*(k1o2+k2o2)*pp_O2_alv_t0+R*T/valg*(k1o2*pp_O2_aw_t0+k2o2*pp_O2_alb_t0))*dt
	pp_O2_alv_t1 = pp_O2_alv_t0 + delta

## Compute the partial pressure of alb
func alveolar_blood():
	var f1 = ((a*(pp_O2_v_t0**3+b*pp_O2_v_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_v_t0
	var f2 = ((a*(pp_O2_alb_t0**3+b*pp_O2_alb_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_alb_t0
	var f3 = a*hb*oxc*(3*pp_O2_alb_t0**2+b)/(pp_O2_alb_t0**3+b*pp_O2_alb_t0+a)**2+alpha_o2
	var delta = (1/(valb*f3)*(k2o2*(pp_O2_alv_t0-pp_O2_alb_t0)+q*(f1-f2)))*dt
	pp_O2_alb_t1 = pp_O2_alb_t0 + delta

## Compute the partial pressure of a
func arterial_blood():
	var f1 = ((a*(pp_O2_alb_t0**3+b*pp_O2_alb_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_alb_t0
	var f2 = ((a*(pp_O2_a_t0**3+b*pp_O2_a_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_a_t0
	var f3 = a*hb*oxc*(3*pp_O2_a_t0**2+b)/(pp_O2_a_t0**3+b*pp_O2_a_t0+a)**2+alpha_o2
	var delta = (q/(va*f3)*(f1-f2))*dt
	pp_O2_a_t1 = pp_O2_a_t0 + delta

## Compute the partial pressure of v
func venous_blood():
	var f1 = ((a*(pp_O2_c_t0**3+b*pp_O2_c_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_c_t0
	var f2 = ((a*(pp_O2_v_t0**3+b*pp_O2_v_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_v_t0
	var f3 = a*hb*oxc*(3*pp_O2_v_t0**2+b)/(pp_O2_v_t0**3+b*pp_O2_v_t0+a)**2+alpha_o2
	var delta = (q/(vv*f3)*(f1-f2))*dt
	pp_O2_v_t1 = pp_O2_v_t0 + delta

## Compute the partial pressure of c
func capilar_blood():
	var f1 = ((a*(pp_O2_a_t0**3+b*pp_O2_a_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_a_t0
	var f2 = ((a*(pp_O2_c_t0**3+b*pp_O2_c_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_c_t0
	var f3 = a*hb*oxc*(3*pp_O2_c_t0**2+b)/(pp_O2_c_t0**3+b*pp_O2_c_t0+a)**2+alpha_o2
	var delta = (1/(vc*f3)*(q*(f1-f2)-k3o2*(pp_O2_c_t0-pp_O2_ti_t0)))*dt
	pp_O2_c_t1 = pp_O2_c_t0 + delta

## Compute the partial pressure of ti
func tissue():
	var delta = (1/(vti*alpha_o2)*(k3o2*(pp_O2_c_t0-pp_O2_ti_t0)-mo2))*dt
	pp_O2_ti_t1 = pp_O2_ti_t0 + delta

## Execute One step (dt) of the model
func step():
	# Display parameters
	print("Time = " + str(time))
	print("    O2 in air in Pa = " + str(pp_O2_air))
	print("    O2 in aw in Pa = " + str(pp_O2_aw_t0))
	print("    O2 in alv in Pa = " + str(pp_O2_alv_t0))
	print("    O2 in alb in Pa = " + str(pp_O2_alb_t0))
	print("    O2 in a in Pa = " + str(pp_O2_a_t0))
	print("    O2 in c in Pa = " + str(pp_O2_c_t0))
	print("    O2 in v in Pa = " + str(pp_O2_v_t0))
	print("    O2 in ti in Pa = " + str(pp_O2_ti_t0))
	time = time + dt
	
		# Compute one step
	air()
	airways()
	alveolar()
	alveolar_blood()
	arterial_blood()
	venous_blood()
	capilar_blood()
	tissue()
	
		# Prepare the next step
	pp_O2_aw_t0 	= pp_O2_aw_t1
	pp_O2_alv_t0	= pp_O2_alv_t1
	pp_O2_alb_t0	 = pp_O2_alb_t1
	pp_O2_a_t0		= pp_O2_a_t1
	pp_O2_v_t0		= pp_O2_v_t1
	pp_O2_c_t0		= pp_O2_c_t1
	pp_O2_ti_t0 	= pp_O2_ti_t1

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
	
func _on_text_patm(new_text):
	if(new_text==""):
		patm = 101325
	else:
		patm = float(new_text)
	print("Nouvelle valeur de P𝘼𝙩𝙢: " +str(patm))
	
func _on_text_fo2(new_text):
	if(new_text==""):
		fo2 = 0.21
	else:
		fo2 = float(new_text)
	print("Nouvelle valeur de fO₂: " +str(fo2))
	
