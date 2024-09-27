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
var vv: float = 3.0
var patm: float = 101325.0
var fo2: float = 0.21

# ***********************
# Model parameters
# ***********************

var a: float = 55000000000.0
var b: float = 2500000.0
var hb: float = 2.1911765
var oxc:float = 4*(1.34/1.39)
var alpha_o2:float = 0.00000997
var ph2o:float = 6246.0
var k1o2:float = 0.0025
var k2o2:float = 0.007
var R:float = 8.314
var T:float = 310.0
var time:float = 0.0
var dt:float = 0.001

# Variables tissus

# Variables du cerveau

var vtiCE: float = 1.35
var vcCE: float = 0.027
var mo2CE:float = 1.596
var ko2CE: float = 0.002
var QCE: float = 0.63
var pp_O2_tiCE_t0: float = 4800.0
var pp_O2_tiCE_t1: float = 0.0
var pp_O2_cCE_t0: float = 4000.0
var pp_O2_cCE_t1: float = 0.0

# Variables de la moelle épiniaire

var vtiME: float = 0.03
var vcME: float = 0.006
var mo2ME:float = 1.596
var ko2ME: float = 0.002
var QME: float = 0.015
var pp_O2_tiME_t0: float = 4800.0
var pp_O2_tiME_t1: float = 0.0
var pp_O2_cME_t0: float = 4000.0
var pp_O2_cME_t1: float = 0.0

# Variables du tissu adipeux

var vtiTA: float = 16
var vcTA: float = 0.011
var mo2TA:float = 0.026
var ko2TA: float = 0.00002
var QTA: float = 0.419
var pp_O2_tiTA_t0: float = 5300.0
var pp_O2_tiTA_t1: float = 0.0
var pp_O2_cTA_t0: float = 4000.0
var pp_O2_cTA_t1: float = 0.0

# Variables des muscles du haut du corps

var vtiMH: float = 6.72
var vcMH: float = 0.0095
var mo2MH:float = 0.087
var ko2MH: float = 0.000021
var QMH: float = 0.07
var pp_O2_tiMH_t0: float = 7800.0
var pp_O2_tiMH_t1: float = 0.0
var pp_O2_cMH_t0: float = 3800.0
var pp_O2_cMH_t1: float = 0.0

# Variables des muscles 

var vtiM: float = 20.17
var vcM: float = 0.0285
var mo2M: float = 0.087
var ko2M: float = 0.00002
var QM: float = 0.21
var pp_O2_tiM_t0: float = 7800.0
var pp_O2_tiM_t1: float = 0.0
var pp_O2_cM_t0: float = 3800.0
var pp_O2_cM_t1: float = 0.0

# Varibles du rein

var vtiR: float = 0.30
var vcR: float = 0.042
var mo2R:float = 2.95
var ko2R: float = 0.0019
var QR: float = 1.2
var pp_O2_tiR_t0: float = 8550.0
var pp_O2_tiR_t1: float = 0.0
var pp_O2_cR_t0: float = 7000.0
var pp_O2_cR_t1: float = 0.0

# Variables des os

var vtiO: float = 6.81
var vcO: float = 0.011
var mo2O:float = 0.113
var ko2O: float = 0.00005
var QO: float = 0.5
var pp_O2_tiO_t0: float = 6700.0
var pp_O2_tiO_t1: float = 0.0
var pp_O2_cO_t0: float = 4500.0
var pp_O2_cO_t1: float = 0.0

# Variables du transit gastro-intestinal

var vtiTGI: float = 1.28
var vcTGI: float = 0.040
var mo2TGI:float = 0.0806
var ko2TGI: float = 0.00004
var QTGI: float = 0.065
var pp_O2_tiTGI_t0: float = 6000.0
var pp_O2_tiTGI_t1: float = 0.0
var pp_O2_cTGI_t0: float = 4000.0
var pp_O2_cTGI_t1: float = 0.0

# Variables du foie

var vtiF: float = 1.71
var vcF:float = 0.054
var mo2F:float = 1.3507
var ko2F: float = 0.001
var QF: float = 0.8
var pp_O2_tiF_t0: float = 5600.0
var pp_O2_tiF_t1: float = 0.0
var pp_O2_cF_t0: float = 4500.0
var pp_O2_cF_t1: float = 0.0

# Variables du reste du corps

var vtiRDC: float = 6.04
var vcRDC: float = 0.039
var mo2RDC: float = 5.0965
var ko2RDC: float = 0.001
var QRDC: float = 0.3
var pp_O2_tiRDC_t0: float = 6000.0
var pp_O2_tiRDC_t1: float = 0.0
var pp_O2_cRDC_t0: float = 2000.0
var pp_O2_cRDC_t1: float = 0.0

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
var pp_O2_v_t1: float = 0.0

# Arterial blood compartment parameters
var pp_O2_a_t0: float = 12800.0
var pp_O2_a_t1: float = 0.0


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
#func venous_blood():
	#var f1 = ((a*(pp_O2_c_t0**3+b*pp_O2_c_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_c_t0
	#var f2 = ((a*(pp_O2_v_t0**3+b*pp_O2_v_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_v_t0
	#var f3 = a*hb*oxc*(3*pp_O2_v_t0**2+b)/(pp_O2_v_t0**3+b*pp_O2_v_t0+a)**2+alpha_o2
	#var delta = (q/(vv*f3)*(f1-f2))*dt
	#pp_O2_v_t1 = pp_O2_v_t0 + delta

## Compute the partial pressure of c
func capilar_blood_RDC():
	var f1 = ((a*(pp_O2_a_t0**3+b*pp_O2_a_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_a_t0
	var f2 = ((a*(pp_O2_cRDC_t0**3+b*pp_O2_cRDC_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_cRDC_t0
	var f3 = a*hb*oxc*(3*pp_O2_cRDC_t0**2+b)/(pp_O2_cRDC_t0**3+b*pp_O2_cRDC_t0+a)**2+alpha_o2
	var delta = (1/(vcRDC*f3)*(q*(f1-f2)-ko2RDC*(pp_O2_cRDC_t0-pp_O2_tiRDC_t0)))*dt
	pp_O2_cRDC_t1 = pp_O2_cRDC_t0 + delta

func capilar_blood_CE():
	var f1 = ((a*(pp_O2_a_t0**3+b*pp_O2_a_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_a_t0
	var f2 = ((a*(pp_O2_cCE_t0**3+b*pp_O2_cCE_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_cCE_t0
	var f3 = a*hb*oxc*(3*pp_O2_cCE_t0**2+b)/(pp_O2_cCE_t0**3+b*pp_O2_cCE_t0+a)**2+alpha_o2
	var delta = (1/(vcCE*f3)*(q*(f1-f2)-ko2CE*(pp_O2_cCE_t0-pp_O2_tiCE_t0)))*dt
	pp_O2_cCE_t1 = pp_O2_cCE_t0 + delta

func capilar_blood_ME():
	var f1 = ((a*(pp_O2_a_t0**3+b*pp_O2_a_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_a_t0
	var f2 = ((a*(pp_O2_cME_t0**3+b*pp_O2_cME_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_cME_t0
	var f3 = a*hb*oxc*(3*pp_O2_cME_t0**2+b)/(pp_O2_cME_t0**3+b*pp_O2_cME_t0+a)**2+alpha_o2
	var delta = (1/(vcME*f3)*(q*(f1-f2)-ko2ME*(pp_O2_cME_t0-pp_O2_tiME_t0)))*dt
	pp_O2_cME_t1 = pp_O2_cME_t0 + delta

func capilar_blood_TA():
	var f1 = ((a*(pp_O2_a_t0**3+b*pp_O2_a_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_a_t0
	var f2 = ((a*(pp_O2_cTA_t0**3+b*pp_O2_cTA_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_cTA_t0
	var f3 = a*hb*oxc*(3*pp_O2_cTA_t0**2+b)/(pp_O2_cTA_t0**3+b*pp_O2_cTA_t0+a)**2+alpha_o2
	var delta = (1/(vcTA*f3)*(q*(f1-f2)-ko2TA*(pp_O2_cTA_t0-pp_O2_tiTA_t0)))*dt
	pp_O2_cTA_t1 = pp_O2_cTA_t0 + delta

func capilar_blood_MH():
	var f1 = ((a*(pp_O2_a_t0**3+b*pp_O2_a_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_a_t0
	var f2 = ((a*(pp_O2_cMH_t0**3+b*pp_O2_cMH_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_cMH_t0
	var f3 = a*hb*oxc*(3*pp_O2_cMH_t0**2+b)/(pp_O2_cMH_t0**3+b*pp_O2_cMH_t0+a)**2+alpha_o2
	var delta = (1/(vcMH*f3)*(q*(f1-f2)-ko2MH*(pp_O2_cMH_t0-pp_O2_tiMH_t0)))*dt
	pp_O2_cMH_t1 = pp_O2_cMH_t0 + delta

func capilar_blood_M():
	var f1 = ((a*(pp_O2_a_t0**3+b*pp_O2_a_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_a_t0
	var f2 = ((a*(pp_O2_cM_t0**3+b*pp_O2_cM_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_cM_t0
	var f3 = a*hb*oxc*(3*pp_O2_cM_t0**2+b)/(pp_O2_cM_t0**3+b*pp_O2_cM_t0+a)**2+alpha_o2
	var delta = (1/(vcM*f3)*(q*(f1-f2)-ko2M*(pp_O2_cM_t0-pp_O2_tiM_t0)))*dt
	pp_O2_cM_t1 = pp_O2_cM_t0 + delta

func capilar_blood_R():
	var f1 = ((a*(pp_O2_a_t0**3+b*pp_O2_a_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_a_t0
	var f2 = ((a*(pp_O2_cR_t0**3+b*pp_O2_cR_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_cR_t0
	var f3 = a*hb*oxc*(3*pp_O2_cR_t0**2+b)/(pp_O2_cR_t0**3+b*pp_O2_cR_t0+a)**2+alpha_o2
	var delta = (1/(vcR*f3)*(q*(f1-f2)-ko2R*(pp_O2_cR_t0-pp_O2_tiR_t0)))*dt
	pp_O2_cR_t1 = pp_O2_cR_t0 + delta

func capilar_blood_O():
	var f1 = ((a*(pp_O2_a_t0**3+b*pp_O2_a_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_a_t0
	var f2 = ((a*(pp_O2_cO_t0**3+b*pp_O2_cO_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_cO_t0
	var f3 = a*hb*oxc*(3*pp_O2_cO_t0**2+b)/(pp_O2_cO_t0**3+b*pp_O2_cO_t0+a)**2+alpha_o2
	var delta = (1/(vcO*f3)*(q*(f1-f2)-ko2O*(pp_O2_cO_t0-pp_O2_tiO_t0)))*dt
	pp_O2_cO_t1 = pp_O2_cO_t0 + delta

func capilar_blood_TGI():
	var f1 = ((a*(pp_O2_a_t0**3+b*pp_O2_a_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_a_t0
	var f2 = ((a*(pp_O2_cTGI_t0**3+b*pp_O2_cTGI_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_cTGI_t0
	var f3 = a*hb*oxc*(3*pp_O2_cTGI_t0**2+b)/(pp_O2_cTGI_t0**3+b*pp_O2_cTGI_t0+a)**2+alpha_o2
	var delta = (1/(vcTGI*f3)*(q*(f1-f2)-ko2TGI*(pp_O2_cTGI_t0-pp_O2_tiTGI_t0)))*dt
	pp_O2_cTGI_t1 = pp_O2_cTGI_t0 + delta

func capilar_blood_F():
	var f1 = ((a*(pp_O2_a_t0**3+b*pp_O2_a_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_a_t0
	var f2 = ((a*(pp_O2_cF_t0**3+b*pp_O2_cF_t0)**-1)+1)**-1*hb*oxc+alpha_o2*pp_O2_cF_t0
	var f3 = a*hb*oxc*(3*pp_O2_cF_t0**2+b)/(pp_O2_cF_t0**3+b*pp_O2_cF_t0+a)**2+alpha_o2
	var delta = (1/(vcF*f3)*(q*(f1-f2)-ko2F*(pp_O2_cF_t0-pp_O2_tiF_t0)))*dt
	pp_O2_cF_t1 = pp_O2_cF_t0 + delta

## Compute the partial pressure of ti
func tissue_RDC():
	var delta = (1/(vtiRDC*alpha_o2)*(ko2RDC*(pp_O2_cRDC_t0-pp_O2_tiRDC_t0)-mo2RDC))*dt
	pp_O2_tiRDC_t1 = pp_O2_tiRDC_t0 + delta

func tissue_CE():
	var delta = (1/(vtiCE*alpha_o2)*(ko2CE*(pp_O2_cCE_t0-pp_O2_tiCE_t0)-mo2CE))*dt
	pp_O2_tiCE_t1 = pp_O2_tiCE_t0 + delta

func tissue_ME():
	var delta = (1/(vtiME*alpha_o2)*(ko2ME*(pp_O2_cME_t0-pp_O2_tiME_t0)-mo2ME))*dt
	pp_O2_tiME_t1 = pp_O2_tiME_t0 + delta

func tissue_TA():
	var delta = (1/(vtiTA*alpha_o2)*(ko2TA*(pp_O2_cTA_t0-pp_O2_tiTA_t0)-mo2TA))*dt
	pp_O2_tiTA_t1 = pp_O2_tiTA_t0 + delta

func tissue_MH():
	var delta = (1/(vtiMH*alpha_o2)*(ko2MH*(pp_O2_cMH_t0-pp_O2_tiMH_t0)-mo2MH))*dt
	pp_O2_tiMH_t1 = pp_O2_tiMH_t0 + delta

func tissue_M():
	var delta = (1/(vtiM*alpha_o2)*(ko2M*(pp_O2_cM_t0-pp_O2_tiM_t0)-mo2M))*dt
	pp_O2_tiM_t1 = pp_O2_tiM_t0 + delta

func tissue_R():
	var delta = (1/(vtiR*alpha_o2)*(ko2R*(pp_O2_cR_t0-pp_O2_tiR_t0)-mo2R))*dt
	pp_O2_tiR_t1 = pp_O2_tiR_t0 + delta

func tissue_O():
	var delta = (1/(vtiO*alpha_o2)*(ko2O*(pp_O2_cO_t0-pp_O2_tiO_t0)-mo2O))*dt
	pp_O2_tiO_t1 = pp_O2_tiO_t0 + delta

func tissue_TGI():
	var delta = (1/(vtiTGI*alpha_o2)*(ko2TGI*(pp_O2_cTGI_t0-pp_O2_tiTGI_t0)-mo2TGI))*dt
	pp_O2_tiTGI_t1 = pp_O2_tiTGI_t0 + delta

func tissue_F():
	var delta = (1/(vtiF*alpha_o2)*(ko2F*(pp_O2_cF_t0-pp_O2_tiF_t0)-mo2F))*dt
	pp_O2_tiF_t1 = pp_O2_tiF_t0 + delta

## Execute One step (dt) of the model
func step():
	# Display parameters
	print("Time = " + str(time))
	print("    O2 in air in Pa = " + str(pp_O2_air))
	print("    O2 in aw in Pa = " + str(pp_O2_aw_t0))
	print("    O2 in alv in Pa = " + str(pp_O2_alv_t0))
	print("    O2 in alb in Pa = " + str(pp_O2_alb_t0))
	print("    O2 in a in Pa = " + str(pp_O2_a_t0))
	print("    O2 in v in Pa = " + str(pp_O2_v_t0))
	
	# Affichage des tissus
	
	print("    O2 in cCE in Pa = " + str(pp_O2_cCE_t0))
	print("    O2 in tiCE in Pa = " + str(pp_O2_tiCE_t0))
	print("    O2 in cME in Pa = " + str(pp_O2_cME_t0))
	print("    O2 in tiME in Pa = " + str(pp_O2_tiME_t0))
	print("    O2 in cTA in Pa = " + str(pp_O2_cTA_t0))
	print("    O2 in tiTA in Pa = " + str(pp_O2_tiTA_t0))
	print("    O2 in cMH in Pa = " + str(pp_O2_cMH_t0))
	print("    O2 in tiMH in Pa = " + str(pp_O2_tiMH_t0))
	print("    O2 in cM in Pa = " + str(pp_O2_cM_t0))
	print("    O2 in tiM in Pa = " + str(pp_O2_tiM_t0))
	print("    O2 in cR in Pa = " + str(pp_O2_cR_t0))
	print("    O2 in tiR in Pa = " + str(pp_O2_tiR_t0))
	print("    O2 in cO in Pa = " + str(pp_O2_cO_t0))
	print("    O2 in tiO in Pa = " + str(pp_O2_tiO_t0))
	print("    O2 in cTGI in Pa = " + str(pp_O2_cTGI_t0))
	print("    O2 in tiTGI in Pa = " + str(pp_O2_tiTGI_t0))
	print("    O2 in cF in Pa = " + str(pp_O2_cF_t0))
	print("    O2 in tiF in Pa = " + str(pp_O2_tiF_t0))
	print("    O2 in cRDC in Pa = " + str(pp_O2_cRDC_t0))
	print("    O2 in tiRDC in Pa = " + str(pp_O2_tiRDC_t0))
	
	
	time = time + dt
	
		# Compute one step
	air()
	airways()
	alveolar()
	alveolar_blood()
	arterial_blood()
	#venous_blood()
	capilar_blood_CE()
	tissue_CE()
	capilar_blood_ME()
	tissue_ME()
	capilar_blood_TA()
	tissue_TA()
	capilar_blood_MH()
	tissue_MH()
	capilar_blood_M()
	tissue_M()
	capilar_blood_R()
	tissue_R()
	capilar_blood_O()
	tissue_O()
	capilar_blood_TGI()
	tissue_TGI()
	capilar_blood_F()
	tissue_F()
	capilar_blood_RDC()
	tissue_RDC()
	
		# Prepare the next step
	pp_O2_aw_t0 	= pp_O2_aw_t1
	pp_O2_alv_t0	= pp_O2_alv_t1
	pp_O2_alb_t0	 = pp_O2_alb_t1
	pp_O2_a_t0		= pp_O2_a_t1
	pp_O2_v_t0		= pp_O2_v_t1
	
		# Variables tissus
	pp_O2_cCE_t0		= pp_O2_cCE_t1
	pp_O2_tiME_t0 	= pp_O2_tiME_t1
	pp_O2_cME_t0		= pp_O2_cME_t1
	pp_O2_tiTA_t0 	= pp_O2_tiTA_t1
	pp_O2_cTA_t0		= pp_O2_cTA_t1
	pp_O2_tiMH_t0 	= pp_O2_tiMH_t1
	pp_O2_cMH_t0		= pp_O2_cMH_t1
	pp_O2_tiCE_t0 	= pp_O2_tiCE_t1
	pp_O2_cM_t0		= pp_O2_cM_t1
	pp_O2_tiM_t0 	= pp_O2_tiM_t1
	pp_O2_cR_t0		= pp_O2_cR_t1
	pp_O2_tiR_t0 	= pp_O2_tiR_t1
	pp_O2_cO_t0		= pp_O2_cO_t1
	pp_O2_tiO_t0 	= pp_O2_tiO_t1
	pp_O2_cTGI_t0		= pp_O2_cTGI_t1
	pp_O2_tiTGI_t0 	= pp_O2_tiTGI_t1
	pp_O2_cF_t0		= pp_O2_cF_t1
	pp_O2_tiF_t0 	= pp_O2_tiF_t1
	pp_O2_cRDC_t0		= pp_O2_cRDC_t1
	pp_O2_tiRDC_t0 	= pp_O2_tiRDC_t1

# ***********************
# Simulator functions
# ***********************

# Simulator parameters
var play:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$RichTextLabel.bbcode_enabled = true
	$RichTextLabel.bbcode_text = "[center]Application to compute Partial Pressure of O2 in human body[/center]"

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
	
func _on_text_vv(new_text):
	if(new_text==""):
		vv = 3.0
	else:
		vv = float(new_text)
	print("Nouvelle valeur de V𝒗: " +str(vv))
	
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
	
