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
var patm: float = 101325.0
var fn2: float = 0.79
var t = [null,null,null,null,null,null,null,null,null,null]
var s = [null,null,null,null,null,null,null,null,null,null]

# ***********************
# Model parameters
# ***********************

var alpha_n2:float = 0.0000619
var ph2o:float = 6246.0
var k1:float = 0.00267
var k2:float = 0.00748
var k3:float = 0.00267
var R:float = 8.314
var T:float = 310.0
var time:float = 0.0
var dt:float = 0.001

# Air compartment parameter
var pp_N2_air:float = 0.0

# Airways compartment parameters
var pp_N2_aw_t0:float = 75112.41
var pp_N2_aw_t1:float = 0.0

# Alveols gas compartment parameters
var pp_N2_alv_t0:float = 75112.41
var pp_N2_alv_t1:float = 0.0

# Alveols blood compartment parameters
var pp_N2_alb_t0:float = 75112.41
var pp_N2_alb_t1:float = 0.0

# Venous blood compartment parameters
var pp_N2_v_t0:float = 75112.41
var pp_N2_v_t1 = 0.0

# Arterial blood compartment parameters
var pp_N2_a_t0 = 75112.41
var pp_N2_a_t1 = 0.0

# Capilar blood compartment parameters
var pp_N2_c_t0 = 75112.41
var pp_N2_c_t1 = 0.0

# Tissue compartment parameters
var pp_N2_ti_t0 = 75112.41
var pp_N2_ti_t1 = 0.0


# ***********************
# Compartments functions
# ***********************

func pressure_atm():
	pass

## Compute the partial pressure of air
func air():
	pp_N2_air = (patm-ph2o)*fn2
	
## Compute the partial pressure of aw
func airways():
	var delta = ((vent/vaw*pp_N2_air)-(vent+k1*R*T)/vaw*pp_N2_aw_t0+(k1*R*T)/vaw*pp_N2_alv_t0)*dt
	pp_N2_aw_t1 = pp_N2_aw_t0 + delta

## Compute the partial pressure of alv
func alveolar():
	var delta = (-R*T/valg*(k1+k2)*pp_N2_alv_t0+R*T/valg*(k1*pp_N2_aw_t0+k2*pp_N2_alb_t0))*dt
	pp_N2_alv_t1 = pp_N2_alv_t0 + delta

## Compute the partial pressure of alb
func alveolar_blood():
	var delta = (1/(valb*alpha_n2)*(k2*pp_N2_alv_t0-pp_N2_alb_t0*(k2+alpha_n2*q)+alpha_n2*q*pp_N2_v_t0))*dt
	pp_N2_alb_t1 = pp_N2_alb_t0 + delta

## Compute the partial pressure of a
func arterial_blood():
	var delta = (q/va*(pp_N2_alb_t0-pp_N2_a_t0))*dt
	pp_N2_a_t1 = pp_N2_a_t0 + delta
	
## Compute the partial pressure of v
func venous_blood():
	var delta = (q/vv*(pp_N2_c_t0-pp_N2_v_t0))*dt
	pp_N2_v_t1 = pp_N2_v_t0 + delta

## Compute the partial pressure of c
func capilar_blood():
	var delta = (1/(vc*alpha_n2)*(q*alpha_n2*pp_N2_a_t0-(alpha_n2*q+k3)*pp_N2_c_t0+k3*pp_N2_ti_t0))*dt
	pp_N2_c_t1 = pp_N2_c_t0 + delta

## Compute the partial pressure of ti
func tissue():
	var delta = (k3/(alpha_n2*vti)*(pp_N2_c_t0-pp_N2_ti_t0))*dt
	pp_N2_ti_t1 = pp_N2_ti_t0 + delta

## Execute One step (dt) of the model
func step():
	# Display parameters
	print("Time = " + str(time))
	print("    N2 in air in Pa = " + str(pp_N2_air))
	print("    N2 in aw in Pa = " + str(pp_N2_aw_t0))
	print("    N2 in alv in Pa = " + str(pp_N2_alv_t0))
	print("    N2 in alb in Pa = " + str(pp_N2_alb_t0))
	print("    N2 in a in Pa = " + str(pp_N2_a_t0))
	print("    N2 in c in Pa = " + str(pp_N2_c_t0))
	print("    N2 in v in Pa = " + str(pp_N2_v_t0))
	print("    N2 in ti in Pa = " + str(pp_N2_ti_t0))
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
	pp_N2_aw_t0 	= pp_N2_aw_t1
	pp_N2_alv_t0	= pp_N2_alv_t1
	pp_N2_alb_t0	 = pp_N2_alb_t1
	pp_N2_a_t0		= pp_N2_a_t1
	pp_N2_v_t0		= pp_N2_v_t1
	pp_N2_c_t0		= pp_N2_c_t1
	pp_N2_ti_t0 	= pp_N2_ti_t1

# ***********************
# Simulator functions
# ***********************

# Simulator parameters
var play:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$RichTextLabel_N2.bbcode_enabled = true
	$RichTextLabel_N2.bbcode_text = "[center]Application to compute Partial Pressure of N2 in human body[/center]"

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
	
func _on_text_patm(new_text):
	if(new_text==""):
		patm = 101325
	else:
		patm = float(new_text)
	print("Nouvelle valeur de P𝘼𝙩𝙢: " +str(patm))
	
func _on_text_fo2(new_text):
	if(new_text==""):
		fn2 = 0.79
	else:
		fn2 = float(new_text)
	print("Nouvelle valeur de fO₂: " +str(fn2))

func _on_text_s1(new_text):
	if new_text == "":
		s[0] = null
	else:
		s[0] = float(new_text)
	print("Nouvelle valeur de la liste des étape: " + str(s))
	
	
func _on_text_s2(new_text):
	if new_text == "":
		s[1] = null
	else:
		s[1] = float(new_text)
	print("Nouvelle valeur de la liste des étape: " + str(s))
	
func _on_text_s3(new_text):
	if new_text == "":
		s[2] = null
	else:
		s[2] = float(new_text)
	print("Nouvelle valeur de la liste des étape: " + str(s))
	
func _on_text_s4(new_text):
	if new_text == "":
		s[3] = null
	else:
		s[3] = float(new_text)
	print("Nouvelle valeur de la liste des étape: " + str(s))
	
func _on_text_s5(new_text):
	if new_text == "":
		s[4] = null
	else:
		s[4] = float(new_text)
	print("Nouvelle valeur de la liste des étape: " + str(s))
	
func _on_text_s6(new_text):
	if new_text == "":
		s[5] = null
	else:
		s[5] = float(new_text)
	print("Nouvelle valeur de la liste des étape: " + str(s))
	
func _on_text_s7(new_text):
	if new_text == "":
		s[6] = null
	else:
		s[6] = float(new_text)
	print("Nouvelle valeur de la liste des étape: " + str(s))
	
func _on_text_s8(new_text):
	if new_text == "":
		s[7] = null
	else:
		s[7] = float(new_text)
	print("Nouvelle valeur de la liste des étape: " + str(s))
	
func _on_text_s9(new_text):
	if new_text == "":
		s[8] = null
	else:
		s[8] = float(new_text)
	print("Nouvelle valeur de la liste des étape: " + str(s))
	
func _on_text_s10(new_text):
	if new_text == "":
		s[9] = null
	else:
		s[9] = float(new_text)
	print("Nouvelle valeur de la liste des étape: " + str(s))

func _on_text_t1(new_text):
	if(new_text==""):
		t[0] = null
	else:
		t[0] = float(new_text)
	print("Nouvelle valeur de la liste des pas de temps: " +str(t))
	
func _on_text_t2(new_text):
	if(new_text==""):
		t[1] = null
	else:
		t[1] = float(new_text)
	print("Nouvelle valeur de la liste des pas de temps: " +str(t))
	
func _on_text_t3(new_text):
	if(new_text==""):
		t[2] = null
	else:
		t[2] = float(new_text)
	print("Nouvelle valeur de la liste des pas de temps: " +str(t))
	
func _on_text_t4(new_text):
	if(new_text==""):
		t[3] = null
	else:
		t[3] = float(new_text)
	print("Nouvelle valeur de la liste des pas de temps: " +str(t))
	
func _on_text_t5(new_text):
	if(new_text==""):
		t[4] = null
	else:
		t[4] = float(new_text)
	print("Nouvelle valeur de la liste des pas de temps: " +str(t))
	
func _on_text_t6(new_text):
	if(new_text==""):
		t[5] = null
	else:
		t[5] = float(new_text)
	print("Nouvelle valeur de la liste des pas de temps: " +str(t))
	
func _on_text_t7(new_text):
	if(new_text==""):
		t[6] = null
	else:
		t[6] = float(new_text)
	print("Nouvelle valeur de la liste des pas de temps: " +str(t))
	
func _on_text_t8(new_text):
	if(new_text==""):
		t[7] = null
	else:
		t[7] = float(new_text)
	print("Nouvelle valeur de la liste des pas de temps: " +str(t))
	
func _on_text_t9(new_text):
	if(new_text==""):
		t[8] = null
	else:
		t[8] = float(new_text)
	print("Nouvelle valeur de la liste des pas de temps: " +str(t))
	
func _on_text_t10(new_text):
	if(new_text==""):
		t[9] = null
	else:
		t[9] = float(new_text)
	print("Nouvelle valeur de la liste des pas de temps: " +str(t))
