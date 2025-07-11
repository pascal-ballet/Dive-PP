extends Node2D
# ***********************
# Variables modifiables
# ***********************

var vent: float = 8.1 # debit ventilatoire 
var vaw: float = 1.5 #volume des voix aérienne
var valg: float = 1.0 # volume du gaz alvéolaire
var valb: float = 0.5 # volume de sang alvéolaire
var q: float = 4.209 # debit cardiaque
var va: float = 1.7 #volume artériel
var vv: float = 3.0 #volume veineux
var patm: float = 101325.0 # presion ambiante
const fn2: float = 0.79 #fraction d azote dans le gaz respiré 
var t = [1,null,null,null,null,null,null,null,null,null]
var s = [10,null,null,null,null,null,null,null,null,null]

######################################################################################################################################
# LISTE DES VARIABLES QU'ON VEUT POUVOIR MODIFIER ? Q et volume pour chaque + dt
# DESCENDRE RAPIDEMENT
######################################################################################################################################

# ***********************
# Paramètres du modèle
# ***********************

var alpha_n2:float = 0.0000619 #coef solubilite azote
var ph2o:float = 6246.0 # presstion partiel de vapeur d eau
var K1:float = 0.00267 # coef de difusion respiratoire
var K2:float = 0.00748 # coef de difusion alveolo capilaire
var R:float = 8.314 # constante des gaz parfait
var T:float = 310.0 # Temperature en K
var tmp_t:float = 0.0
var tmp_s:float = 0.0
var time:float = 0.0
var dtINI:float = 0.0009  #variable global de dt permet de changer tout les dt "0.0002 euler" "0.0004 rk4""0.0009 rk6" "RK8 0.0009"
var dt:float = dtINI
var i = 1
var k = 0
var iteration = 0 ## test
var debug_textbox
var debug_textbox2
var debug_textbox3
var debug_textbox4
var debug_textbox5
var debug_textbox6
var debug_textbox7
var debug_textbox8
var debug_textbox9
var debug_textbox10
var debug_textbox11
var debug_textbox12
var seuil: float = 115007.41
var temps_seuils = {
	"pp_N2_aw": null,
	"pp_N2_alv": null,
	"pp_N2_alb": null,
	"pp_N2_v": null,
	"pp_N2_tiCE": null,
	"pp_N2_tiME": null,
	"pp_N2_tiTA": null,
	"pp_N2_tiMH": null,
	"pp_N2_tiM": null,
	"pp_N2_tiR": null,
	"pp_N2_tiO": null,
	"pp_N2_tiTGI": null,
	"pp_N2_tiF": null,
	"pp_N2_tiRDC": null,
	"pp_N2_a": null
}

# Variables tissus

# Variables du cerveau

var vtiCE: float = 1.35 # Volume en L
var vcCE: float = 0.027 # Capilaire Vol en L
var mo2CE:float = 1.596 # MO2 en mMol/kg/min
var kn2CE: float = 0.00214 # diff coef N2
var QCE: float = 0.63 # débit sangin en L/min
var pp_N2_tiCE_t0: float = 75112.41 #pression partiel d azote initiale
var pp_N2_tiCE_t1: float = 0.0
var pp_N2_cCE_t0: float = 75112.41 # pression partiel capillaire
var pp_N2_cCE_t1: float = 0.0

# Variables du tissu adipeux

var vtiTA: float = 16 # Volume en L
var vcTA: float = 0.011 # Cap Vol en L
var mo2TA:float = 0.026 # MO2 en mMol/kg/min
var kn2TA: float = 0.0000214 # diff coef N2
var QTA: float = 0.419 # débit sangin en L/min
var pp_N2_tiTA_t0: float = 75112.41
var pp_N2_tiTA_t1: float = 0.0
var pp_N2_cTA_t0: float = 75112.41
var pp_N2_cTA_t1: float = 0.0

# Variables des muscles du haut du corps

var vtiMH: float = 6.72 # Volume en L
var vcMH: float = 0.0095 # Cap Vol en L
var mo2MH:float = 0.087 # MO2 en mMol/kg/min
var kn2MH: float = 0.000022 # diff coef N2
var QMH: float = 0.07 # débit sangin en L/min
var pp_N2_tiMH_t0: float = 75112.41
var pp_N2_tiMH_t1: float = 0.0
var pp_N2_cMH_t0: float = 75112.41
var pp_N2_cMH_t1: float = 0.0

# Variables des muscles 

var vtiM: float = 20.17 # Volume en L
var vcM: float = 0.0285 # Cap Vol en L
var mo2M: float = 0.087 # MO2 en mMol/kg/min
var kn2M: float = 0.000021 # diff coef N2
var QM: float = 0.21 # débit sangin en L/min
var pp_N2_tiM_t0: float = 75112.41
var pp_N2_tiM_t1: float = 0.0
var pp_N2_cM_t0: float = 75112.41
var pp_N2_cM_t1: float = 0.0

# Varibles du rein

var vtiR: float = 0.30 # Volume en L
var vcR: float = 0.042 # Cap Vol en L
var mo2R:float = 2.95 # MO2 en mMol/kg/min
var kn2R: float = 0.002 # diff coef N2
var QR: float = 1.2 # débit sangin en L/min
var pp_N2_tiR_t0: float = 75112.41
var pp_N2_tiR_t1: float = 0.0
var pp_N2_cR_t0: float = 75112.41
var pp_N2_cR_t1: float = 0.0

# Variables des os

var vtiO: float = 6.81 # Volume en L
var vcO: float = 0.011 # Cap Vol en L
var mo2O:float = 0.113 # MO2 en mMol/kg/min
var kn2O: float = 0.0000535 # diff coef N2
var QO: float = 0.5 # débit sangin en L/min
var pp_N2_tiO_t0: float = 75112.41
var pp_N2_tiO_t1: float = 0.0
var pp_N2_cO_t0: float = 75112.41
var pp_N2_cO_t1: float = 0.0

# Variables du transit gastro-intestinal

var vtiTGI: float = 1.28 # Volume en L
var vcTGI: float = 0.040 # Cap Vol en L
var mo2TGI:float = 0.0806 # MO2 en mMol/kg/min
var kn2TGI: float = 0.000043 # diff coef N2
var QTGI: float = 0.065 # débit sangin en L/min
var pp_N2_tiTGI_t0: float = 75112.41
var pp_N2_tiTGI_t1: float = 0.0
var pp_N2_cTGI_t0: float = 75112.41
var pp_N2_cTGI_t1: float = 0.0

# Variables du foie

var vtiF: float = 1.71 # Volume en L
var vcF:float = 0.054 # Cap Vol en L
var mo2F:float = 1.3507 # MO2 en mMol/kg/min
var kn2F: float = 0.00107 # diff coef N2
var QF: float = 0.8 # débit sangin en L/min
var pp_N2_tiF_t0: float = 75112.41
var pp_N2_tiF_t1: float = 0.0
var pp_N2_cF_t0: float = 75112.41
var pp_N2_cF_t1: float = 0.0

# Variables du ME

var vtiME: float = 0.03 # Volume en L
var vcME:float = 0.006 # Cap Vol en L
var mo2ME:float = 1.596 # MO2 en mMol/kg/min
var kn2ME: float = 0.00214 # diff coef N2
var QME: float = 0.15 # débit sangin en L/min TODO valeur
var pp_N2_tiME_t0: float = 75112.41
var pp_N2_tiME_t1: float = 0.0
var pp_N2_cME_t0: float = 75112.41
var pp_N2_cME_t1: float = 0.0

# Variables du reste du corps

var vtiRDC: float = 6.07 # Volume en L
var vcRDC: float = 0.045 # Cap Vol en L
var mo2RDC: float = 5.0965 # MO2 en mMol/kg/min
var kn2RDC: float = 0.00107 # diff coef N2
var QRDC: float = 0.315 
var pp_N2_tiRDC_t0: float = 75112.41
var pp_N2_tiRDC_t1: float = 0.0
var pp_N2_cRDC_t0: float = 75112.41
var pp_N2_cRDC_t1: float = 0.0


# Air paramètres
var pp_N2_air:float = 0.0

# Airways paramètres
var pp_N2_aw_t0:float = 75112.41
var pp_N2_aw_t1:float = 0.0

# Alveols gas paramètres
var pp_N2_alv_t0:float = 75112.41
var pp_N2_alv_t1:float = 0.0

# Alveols blood paramètres
var pp_N2_alb_t0:float = 75112.41
var pp_N2_alb_t1:float = 0.0

# Venous blood paramètres
var pp_N2_v_t0:float = 75112.41
var pp_N2_v_t1: float = 0.0

# Arterial blood paramètres
var pp_N2_a_t0: float = 75112.41
var pp_N2_a_t1: float = 0.0


# ***********************
# Fonctions de compartiments
# ***********************
#profil de plonge
func pressure_atm():
	if(t[0]!=null&&s[0]!=null):
		if(time<=t[0]+dt):
			var r1 = t[0]/dt
			var r2 = s[0]/r1
			patm = patm + r2*10100
			tmp_t = t[0]
			tmp_s = s[0]
	while (i < t.size() && (t[i] == null || s[i] == null)): i += 1 
	if (i < t.size() && t[i] != null && s[i] != null):
		if (time > tmp_t && time <= t[i] + dt):
			var r1 = (t[i] - tmp_t) / dt
			var r2 = (s[i] - tmp_s) / r1
			patm = patm + r2 * 10100
	if(i < t.size() && time>t[i]):
		tmp_t = t[i]
		tmp_s = s[i]
		i = i + 1

## Compute the partial pressure of air
func air():
	pp_N2_air = (patm-ph2o)*fn2
	
	
## Compute the partial pressure of aw
#methode euler
func airways():
	var delta = ((vent/vaw*pp_N2_air)-(vent+K1*R*T)/vaw*pp_N2_aw_t0+(K1*R*T)/vaw*pp_N2_alv_t0)*dt
	pp_N2_aw_t1 = pp_N2_aw_t0 + delta

#methode runge kutta 4

# Fonction dérivée définie globalement
func f_airways(pp_N2_aw):
	return ((vent / vaw * pp_N2_air) - (vent + K1 * R * T) / vaw * pp_N2_aw + (K1 * R * T) / vaw * pp_N2_alv_t0)

func airways_rk4():
		# Étapes de Runge-Kutta
	var k1 = dt * f_airways(pp_N2_aw_t0)
	var k2 = dt * f_airways(pp_N2_aw_t0 + 0.5 * k1)
	var k3 = dt * f_airways(pp_N2_aw_t0 + 0.5 * k2)
	var k4 = dt * f_airways(pp_N2_aw_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_aw_t1 = pp_N2_aw_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6


## Compute the partial pressure of alv
#methode euler
func alveolar():
	var delta = (-R*T/valg*(K1+K2)*pp_N2_alv_t0+R*T/valg*(K1*pp_N2_aw_t0+K2*pp_N2_alb_t0))*dt
	pp_N2_alv_t1 = pp_N2_alv_t0 + delta
	
#methode runge kutta 4
# Fonction dérivée définie globalement
func f_alveolar(pp_N2_alv):
	return (-R * T / valg * (K1 + K2) * pp_N2_alv + R * T / valg * (K1 * pp_N2_aw_t0 + K2 * pp_N2_alb_t0))

func alveolar_rk4(): #alveolagaz
		# Étapes de Runge-Kutta
	var k1 = dt * f_alveolar(pp_N2_alv_t0)
	var k2 = dt * f_alveolar(pp_N2_alv_t0 + 0.5 * k1)
	var k3 = dt * f_alveolar(pp_N2_alv_t0 + 0.5 * k2)
	var k4 = dt * f_alveolar(pp_N2_alv_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_alv_t1 = pp_N2_alv_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6


## Compute the partial pressure of alb
#methode euler
func alveolar_blood():
	var delta = (1/(valb*alpha_n2)*(K2*pp_N2_alv_t0-pp_N2_alb_t0*(K2+alpha_n2*q)+alpha_n2*q*pp_N2_v_t0))*dt
	pp_N2_alb_t1 = pp_N2_alb_t0 + delta

##methode tunge kutta 4
# Fonction dérivée définie globalement
func f_alveolar_blood(pp_N2_alb):
		return (1 / (valb * alpha_n2) * (K2 * pp_N2_alv_t0 - pp_N2_alb * (K2 + alpha_n2 * q) + alpha_n2 * q * pp_N2_v_t0))

func alveolar_blood_rk4():
	# Étapes de Runge-Kutta
	var k1 = dt * f_alveolar_blood(pp_N2_alb_t0)
	var k2 = dt * f_alveolar_blood(pp_N2_alb_t0 + 0.5 * k1)
	var k3 = dt * f_alveolar_blood(pp_N2_alb_t0 + 0.5 * k2)
	var k4 = dt * f_alveolar_blood(pp_N2_alb_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_alb_t1 = pp_N2_alb_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6


## Compute the partial pressure of a
##methode euler
func arterial_blood():
	var delta = (q/va*(pp_N2_alb_t0-pp_N2_a_t0))*dt
	pp_N2_a_t1 = pp_N2_a_t0 + delta
	
##methode runge kutta 4

# Fonction dérivée définie globalement
func f_arterial_blood(pp_N2_a):
		return (q / va * (pp_N2_alb_t0 - pp_N2_a))

func arterial_blood_rk4():
	# Étapes de Runge-Kutta
	var k1 = dt * f_arterial_blood(pp_N2_a_t0)
	var k2 = dt * f_arterial_blood(pp_N2_a_t0 + 0.5 * k1)
	var k3 = dt * f_arterial_blood(pp_N2_a_t0 + 0.5 * k2)
	var k4 = dt * f_arterial_blood(pp_N2_a_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_a_t1 = pp_N2_a_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6


## Compute the partial pressure of v
##methode euler
func venous_blood():
	var delta = (1/vv*((QCE*pp_N2_cCE_t0+QTA*pp_N2_cTA_t0+QMH*pp_N2_cMH_t0+QM*pp_N2_cM_t0+QR*pp_N2_cR_t0+QO*pp_N2_cO_t0+QF*pp_N2_cF_t0+QRDC*pp_N2_cRDC_t0)-(QCE+QTA+QMH+QM+QR+QO+QF+QRDC)*pp_N2_v_t0))*dt
	pp_N2_v_t1 = pp_N2_v_t0 + delta
	
##methode runge kutta 4

# Fonction dérivée définie globalement
func f_venous_blood(pp_N2_v):
	return (1 / vv * (
		(QCE * pp_N2_cCE_t0 + QTA * pp_N2_cTA_t0 + QMH * pp_N2_cMH_t0 + QM * pp_N2_cM_t0 + QR * pp_N2_cR_t0 + QO * pp_N2_cO_t0 + QF * pp_N2_cF_t0 + QRDC * pp_N2_cRDC_t0) - 
		(QCE + QTA + QMH + QM + QR + QO + QF + QRDC) * pp_N2_v
	))
	#
func venous_blood_mono():
	var delta =q/vv*(pp_N2_c_t0 - pp_N2_v_t0)*dt
	pp_N2_v_t1 = pp_N2_v_t0 + delta

func venous_blood_rk4():
		# Étapes de Runge-Kutta
	var k1 = dt * f_venous_blood(pp_N2_v_t0)
	var k2 = dt * f_venous_blood(pp_N2_v_t0 + 0.5 * k1)
	var k3 = dt * f_venous_blood(pp_N2_v_t0 + 0.5 * k2)
	var k4 = dt * f_venous_blood(pp_N2_v_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_v_t1 = pp_N2_v_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6

var vc:float =0.5
var Q: float =4.2
var kn2 :float =0.0000619
var pp_N2_c_t0 : float = pp_N2_cCE_t0 
var pp_N2_ti_t0 :float = pp_N2_tiCE_t0 


func capilar_blood_mono():
	var delta = (1/(vc*alpha_n2)*(q*alpha_n2*pp_N2_a_t0-(alpha_n2*q+K3_N2_mono)*pp_N2_c_t0+K3_N2_mono*pp_N2_ti_t0))*dt
	#print("delta_cap_CE = ",delta)
	pp_N2_c_t1 = pp_N2_c_t0 + delta
	
## Compute the partial pressure of c methode euler
func capilar_blood_CE():
	var delta = (1/(vcCE*alpha_n2)*(QCE*alpha_n2*pp_N2_a_t0-(alpha_n2*QCE+kn2CE)*pp_N2_cCE_t0+kn2CE*pp_N2_tiCE_t0))*dt
	#print("delta_cap_CE = ",delta)
	pp_N2_cCE_t1 = pp_N2_cCE_t0 + delta
	
#methode runge kutta 4
# Fonction dérivée définie globalement
func f_CE(pp_N2_cCE):
	return (1 / (vcCE * alpha_n2) * (
 		QCE * alpha_n2 * pp_N2_a_t0 
 		- (alpha_n2 * QCE + kn2CE) * pp_N2_cCE 
 		+ kn2CE * pp_N2_tiCE_t0))
		
func capilar_blood_CE_rk4():
	# Étapes de Runge-Kutta
	var k1 = dt * f_CE(pp_N2_cCE_t0)
	var k2 = dt * f_CE(pp_N2_cCE_t0 + 0.5 * k1)
	var k3 = dt * f_CE(pp_N2_cCE_t0 + 0.5 * k2)
	var k4 = dt * f_CE(pp_N2_cCE_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_cCE_t1 = pp_N2_cCE_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6


# methode euler
func capilar_blood_ME(): 
	var delta = (1/(vcME*alpha_n2)*(QME*alpha_n2*pp_N2_a_t0-(alpha_n2*QME+kn2ME)*pp_N2_cME_t0+kn2ME*pp_N2_tiME_t0))*dt
#	print("delta_cap_ME = ",delta) 
	pp_N2_cME_t1 = pp_N2_cME_t0 + delta

#methode runge kutta 4	
func f_ME(pp_N2_cME):
	return (1 / (vcME * alpha_n2) * (
		QME * alpha_n2 * pp_N2_a_t0 
		- (alpha_n2 * QME + kn2ME) * pp_N2_cME 
		+ kn2ME * pp_N2_tiME_t0))	
		
func capilar_blood_ME_rk4():
	# Étapes de Runge-Kutta
	var k1 = dt * f_ME(pp_N2_cME_t0)
	var k2 = dt * f_ME(pp_N2_cME_t0 + 0.5 * k1)
	var k3 = dt * f_ME(pp_N2_cME_t0 + 0.5 * k2)
	var k4 = dt * f_ME(pp_N2_cME_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_cME_t1 = pp_N2_cME_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6	

# Implémentation du schéma Runge-Kutta d'ordre 6
func capilar_blood_ME_rk6():
	# Coefficients intermédiaires pour RK6
	var k1 = dt * f_ME(pp_N2_cME_t0)
	var k2 = dt * f_ME(pp_N2_cME_t0 + k1 / 3)
	var k3 = dt * f_ME(pp_N2_cME_t0 + (k1 + k2) / 6)
	var k4 = dt * f_ME(pp_N2_cME_t0 + (k1 - k2 + 2 * k3) / 8)
	var k5 = dt * f_ME(pp_N2_cME_t0 + (k1 + 4 * k2 + k3 - k4) / 2)
	var k6 = dt * f_ME(pp_N2_cME_t0 + (-k1 + 2 * k2 + k3 + 2 * k4 + k5) / 6)
	
	# Mise à jour de la variable selon le schéma RK6
	pp_N2_cME_t1 = pp_N2_cME_t0 + (k1 + 4 * k2 + k3 + k4 + k5 + k6) / 10

# Implémentation du schéma Runge-Kutta d'ordre 8
func capilar_blood_ME_rk8():
	# Étapes intermédiaires du schéma RK8
	var k1 = dt * f_ME(pp_N2_cME_t0)
	var k2 = dt * f_ME(pp_N2_cME_t0 + k1 / 6)
	var k3 = dt * f_ME(pp_N2_cME_t0 + k1 / 27 + k2 / 27)
	var k4 = dt * f_ME(pp_N2_cME_t0 + (k1 + 3 * k3) / 24)
	var k5 = dt * f_ME(pp_N2_cME_t0 + (k1 + 3 * k4) / 20)
	var k6 = dt * f_ME(pp_N2_cME_t0 + (k1 - 9 * k3 + 12 * k4) / 45)
	var k7 = dt * f_ME(pp_N2_cME_t0 + (7 * k1 + 32 * k5 + 12 * k6) / 90)
	var k8 = dt * f_ME(pp_N2_cME_t0 + (k1 - 8 * k4 + 14 * k5 - 2 * k6 + k7) / 60)
	
	# Mise à jour de la variable
	pp_N2_cME_t1 = pp_N2_cME_t0 + (41 * k1 + 216 * k3 + 27 * k4 + 272 * k5 + 27 * k6 + 41 * k8) / 840



	
# methode euler
func capilar_blood_TA():
	var delta = (1/(vcTA*alpha_n2)*(QTA*alpha_n2*pp_N2_a_t0-(alpha_n2*QTA+kn2TA)*pp_N2_cTA_t0+kn2TA*pp_N2_tiTA_t0))*dt
	pp_N2_cTA_t1 = pp_N2_cTA_t0 + delta
	
	#methode runge kutta 4
	
	# Fonction dérivée définie globalement
func f_TA(pp_N2_cTA):
	return (1 / (vcTA * alpha_n2) * (
		QTA * alpha_n2 * pp_N2_a_t0 
		- (alpha_n2 * QTA + kn2TA) * pp_N2_cTA 
		+ kn2TA * pp_N2_tiTA_t0))

func capilar_blood_TA_rk4():
	# Étapes de Runge-Kutta
	var k1 = dt * f_TA(pp_N2_cTA_t0)
	var k2 = dt * f_TA(pp_N2_cTA_t0 + 0.5 * k1)
	var k3 = dt * f_TA(pp_N2_cTA_t0 + 0.5 * k2)
	var k4 = dt * f_TA(pp_N2_cTA_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_cTA_t1 = pp_N2_cTA_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6

# methode euler
func capilar_blood_MH():
	var delta = (1/(vcMH*alpha_n2)*(QMH*alpha_n2*pp_N2_a_t0-(alpha_n2*QMH+kn2MH)*pp_N2_cMH_t0+kn2MH*pp_N2_tiMH_t0))*dt
	pp_N2_cMH_t1 = pp_N2_cMH_t0 + delta

#methode runge kutta4

# Fonction dérivée définie globalement
func f_MH(pp_N2_cMH):
	return (1 / (vcMH * alpha_n2) * (
		QMH * alpha_n2 * pp_N2_a_t0 
		- (alpha_n2 * QMH + kn2MH) * pp_N2_cMH 
		+ kn2MH * pp_N2_tiMH_t0))

func capilar_blood_MH_rk4():
	# Étapes de Runge-Kutta
	var k1 = dt * f_MH(pp_N2_cMH_t0)
	var k2 = dt * f_MH(pp_N2_cMH_t0 + 0.5 * k1)
	var k3 = dt * f_MH(pp_N2_cMH_t0 + 0.5 * k2)
	var k4 = dt * f_MH(pp_N2_cMH_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_cMH_t1 = pp_N2_cMH_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6

# methode euler
func capilar_blood_M():
	var delta = (1/(vcM*alpha_n2)*(QM*alpha_n2*pp_N2_a_t0-(alpha_n2*QM+kn2M)*pp_N2_cM_t0+kn2M*pp_N2_tiM_t0))*dt
	pp_N2_cM_t1 = pp_N2_cM_t0 + delta
	
	#methode runge kutta 4

# Fonction dérivée définie globalement
# Fonction dérivée définie globalement
func f_M(pp_N2_cM):
	return (1 / (vcM * alpha_n2) * (
		QM * alpha_n2 * pp_N2_a_t0 
		- (alpha_n2 * QM + kn2M) * pp_N2_cM 
		+ kn2M * pp_N2_tiM_t0))

func capilar_blood_M_rk4():
	# Étapes de Runge-Kutta
	var k1 = dt * f_M(pp_N2_cM_t0)
	var k2 = dt * f_M(pp_N2_cM_t0 + 0.5 * k1)
	var k3 = dt * f_M(pp_N2_cM_t0 + 0.5 * k2)
	var k4 = dt * f_M(pp_N2_cM_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_cM_t1 = pp_N2_cM_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6

# methode euler
func capilar_blood_R():
	var delta = (1/(vcR*alpha_n2)*(QR*alpha_n2*pp_N2_a_t0-(alpha_n2*QR+kn2R)*pp_N2_cR_t0+kn2R*pp_N2_tiR_t0))*dt
	pp_N2_cR_t1 = pp_N2_cR_t0 + delta

# methode runge kutta 4

# Fonction dérivée définie globalement
func f_R(pp_N2_cR):
	return (1 / (vcR * alpha_n2) * (
		QR * alpha_n2 * pp_N2_a_t0 
		- (alpha_n2 * QR + kn2R) * pp_N2_cR 
		+ kn2R * pp_N2_tiR_t0))

func capilar_blood_R_rk4():
	# Étapes de Runge-Kutta
	var k1 = dt * f_R(pp_N2_cR_t0)
	var k2 = dt * f_R(pp_N2_cR_t0 + 0.5 * k1)
	var k3 = dt * f_R(pp_N2_cR_t0 + 0.5 * k2)
	var k4 = dt * f_R(pp_N2_cR_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_cR_t1 = pp_N2_cR_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6


# methode euler
func capilar_blood_O():
	var delta = (1/(vcO*alpha_n2)*(QO*alpha_n2*pp_N2_a_t0-(alpha_n2*QO+kn2O)*pp_N2_cO_t0+kn2O*pp_N2_tiO_t0))*dt
	pp_N2_cO_t1 = pp_N2_cO_t0 + delta
	
#methode runge kutta 4

# Fonction dérivée définie globalement
func f_O(pp_N2_cO):
	return (1 / (vcO * alpha_n2) * (
		QO * alpha_n2 * pp_N2_a_t0 
		- (alpha_n2 * QO + kn2O) * pp_N2_cO 
		+ kn2O * pp_N2_tiO_t0))

func capilar_blood_O_rk4():
	# Étapes de Runge-Kutta
	var k1 = dt * f_O(pp_N2_cO_t0)
	var k2 = dt * f_O(pp_N2_cO_t0 + 0.5 * k1)
	var k3 = dt * f_O(pp_N2_cO_t0 + 0.5 * k2)
	var k4 = dt * f_O(pp_N2_cO_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_cO_t1 = pp_N2_cO_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6

# methode euler
func capilar_blood_TGI():
	var delta = (1/(vcTGI*alpha_n2)*(QTGI*alpha_n2*pp_N2_a_t0-(alpha_n2*QTGI+kn2TGI)*pp_N2_cTGI_t0+kn2TGI*pp_N2_tiTGI_t0))*dt
	pp_N2_cTGI_t1 = pp_N2_cTGI_t0 + delta

# methode runge kutta 4

# Fonction dérivée définie globalement
func f_TGI(pp_N2_cTGI):
	return (1 / (vcTGI * alpha_n2) * (
		QTGI * alpha_n2 * pp_N2_a_t0 
		- (alpha_n2 * QTGI + kn2TGI) * pp_N2_cTGI 
		+ kn2TGI * pp_N2_tiTGI_t0))

func capilar_blood_TGI_rk4():
	# Étapes de Runge-Kutta
	var k1 = dt * f_TGI(pp_N2_cTGI_t0)
	var k2 = dt * f_TGI(pp_N2_cTGI_t0 + 0.5 * k1)
	var k3 = dt * f_TGI(pp_N2_cTGI_t0 + 0.5 * k2)
	var k4 = dt * f_TGI(pp_N2_cTGI_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_cTGI_t1 = pp_N2_cTGI_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6

# methode euler
func capilar_blood_F():
	var delta = (1/(vcF*alpha_n2)*(alpha_n2*(QTGI*pp_N2_cTGI_t0+QF*pp_N2_a_t0)-(alpha_n2*(QF+QTGI)+kn2F)*pp_N2_cF_t0+kn2F*pp_N2_tiF_t0))*dt
	pp_N2_cF_t1 = pp_N2_cF_t0 + delta
	
#methode runge kutta 4

# Fonction dérivée définie globalement
func f_F(pp_N2_cF):
	return (1 / (vcF * alpha_n2) * (
		alpha_n2 * (QTGI * pp_N2_cTGI_t0 + QF * pp_N2_a_t0) 
		- (alpha_n2 * (QF + QTGI) + kn2F) * pp_N2_cF 
		+ kn2F * pp_N2_tiF_t0))

func capilar_blood_F_rk4():
	# Étapes de Runge-Kutta
	var k1 = dt * f_F(pp_N2_cF_t0)
	var k2 = dt * f_F(pp_N2_cF_t0 + 0.5 * k1)
	var k3 = dt * f_F(pp_N2_cF_t0 + 0.5 * k2)
	var k4 = dt * f_F(pp_N2_cF_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_cF_t1 = pp_N2_cF_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6

# methode euler
func capilar_blood_RDC():
	var delta = (1/(vcRDC*alpha_n2)*(QRDC*alpha_n2*pp_N2_a_t0-(alpha_n2*QRDC+kn2RDC)*pp_N2_cRDC_t0+kn2RDC*pp_N2_tiRDC_t0))*dt
	pp_N2_cRDC_t1 = pp_N2_cRDC_t0 + delta
	
#methode tunge kutta 4
	# Fonction dérivée définie globalement
func f_RDC(pp_N2_cRDC):
		return (1 / (vcRDC * alpha_n2) * (
			QRDC * alpha_n2 * pp_N2_a_t0 
			- (alpha_n2 * QRDC + kn2RDC) * pp_N2_cRDC 
			+ kn2RDC * pp_N2_tiRDC_t0))

func capilar_blood_RDC_rk4():
		# Étapes de Runge-Kutta
		var k1 = dt * f_RDC(pp_N2_cRDC_t0)
		var k2 = dt * f_RDC(pp_N2_cRDC_t0 + 0.5 * k1)
		var k3 = dt * f_RDC(pp_N2_cRDC_t0 + 0.5 * k2)
		var k4 = dt * f_RDC(pp_N2_cRDC_t0 + k3)
		
		# Mise à jour de la variable
		pp_N2_cRDC_t1 = pp_N2_cRDC_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6


## Compute the partial pressure of ti
##methode euler
var Vt = 70
var K3_N2_mono=0.00267

func tissue_mono():
	var delta =(K3_N2_mono/(alpha_n2*Vt)*(pp_N2_c_t0-pp_N2_ti_t0))*dt
	pp_N2_ti_t1 = pp_N2_ti_t0 + delta
	
func tissue_CE():
	var delta = (kn2CE/(alpha_n2*vtiCE)*(pp_N2_cCE_t0-pp_N2_tiCE_t0))*dt
	#print("delta_tissue_CE = ",delta)
	pp_N2_tiCE_t1 = pp_N2_tiCE_t0 + delta

#methode runge kutta 4
# Fonction dérivée définie globalement
func f_tissue(pp_N2_tiCE):
	return kn2CE / (alpha_n2 * vtiCE) * (pp_N2_cCE_t0 - pp_N2_tiCE)


func tissue_CE_rk4():
	# Étapes de Runge-Kutta
	var k1 = dt * f_tissue(pp_N2_tiCE_t0)
	var k2 = dt * f_tissue(pp_N2_tiCE_t0 + 0.5 * k1)
	var k3 = dt * f_tissue(pp_N2_tiCE_t0 + 0.5 * k2)
	var k4 = dt * f_tissue(pp_N2_tiCE_t0 + k3)
	
	# Mise à jour de la variable pp_N2_tiCE_t1
	pp_N2_tiCE_t1 = pp_N2_tiCE_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6



# methode euler
func tissue_ME():
	var delta = (kn2ME/(alpha_n2*vtiME)*(pp_N2_cME_t0-pp_N2_tiME_t0))*dt
#	print("delta_tissue_ME = ",delta)
	pp_N2_tiME_t1 = pp_N2_tiME_t0 + delta
	
	
	#methode runge kutta 4
func f_tissue_ME(pp_N2_tiME):
	return kn2ME / (alpha_n2 * vtiME) * (pp_N2_cME_t0 - pp_N2_tiME)

func tissue_ME_rk4():

	var k1 = dt * f_tissue_ME(pp_N2_tiME_t0)
	var k2 = dt * f_tissue_ME(pp_N2_tiME_t0 + 0.5 * k1)
	var k3 = dt * f_tissue_ME(pp_N2_tiME_t0 + 0.5 * k2)
	var k4 = dt * f_tissue_ME(pp_N2_tiME_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_tiME_t1 = pp_N2_tiME_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6

# Implémentation du schéma Runge-Kutta d'ordre 6
func tissue_ME_rk6():
	# Étapes intermédiaires du schéma RK6
	var k1 = dt * f_tissue_ME(pp_N2_tiME_t0)
	var k2 = dt * f_tissue_ME(pp_N2_tiME_t0 + k1 / 3)
	var k3 = dt * f_tissue_ME(pp_N2_tiME_t0 + (k1 + k2) / 6)
	var k4 = dt * f_tissue_ME(pp_N2_tiME_t0 + (k1 - k2 + 2 * k3) / 8)
	var k5 = dt * f_tissue_ME(pp_N2_tiME_t0 + (k1 + 4 * k2 + k3 - k4) / 2)
	var k6 = dt * f_tissue_ME(pp_N2_tiME_t0 + (-k1 + 2 * k2 + k3 + 2 * k4 + k5) / 6)
	
	# Mise à jour de la variable
	pp_N2_tiME_t1 = pp_N2_tiME_t0 + (k1 + 4 * k2 + k3 + k4 + k5 + k6) / 10

# Implémentation du schéma Runge-Kutta d'ordre 8
func tissue_ME_rk8():
	# Étapes intermédiaires du schéma RK8
	var k1 = dt * f_tissue_ME(pp_N2_tiME_t0)
	var k2 = dt * f_tissue_ME(pp_N2_tiME_t0 + k1 / 6)
	var k3 = dt * f_tissue_ME(pp_N2_tiME_t0 + k1 / 27 + k2 / 27)
	var k4 = dt * f_tissue_ME(pp_N2_tiME_t0 + (k1 + 3 * k3) / 24)
	var k5 = dt * f_tissue_ME(pp_N2_tiME_t0 + (k1 + 3 * k4) / 20)
	var k6 = dt * f_tissue_ME(pp_N2_tiME_t0 + (k1 - 9 * k3 + 12 * k4) / 45)
	var k7 = dt * f_tissue_ME(pp_N2_tiME_t0 + (7 * k1 + 32 * k5 + 12 * k6) / 90)
	var k8 = dt * f_tissue_ME(pp_N2_tiME_t0 + (k1 - 8 * k4 + 14 * k5 - 2 * k6 + k7) / 60)
	
	# Mise à jour de la variable
	pp_N2_tiME_t1 = pp_N2_tiME_t0 + (41 * k1 + 216 * k3 + 27 * k4 + 272 * k5 + 27 * k6 + 41 * k8) / 840


# methode euler
func tissue_TA():
	var delta = (kn2TA/(alpha_n2*vtiTA)*(pp_N2_cTA_t0-pp_N2_tiTA_t0))*dt
	pp_N2_tiTA_t1 = pp_N2_tiTA_t0 + delta

#methode runge kutta 4
# Fonction dérivée définie globalement
func f_ti_TA(pp_N2_tiTA):
	return (kn2TA / (alpha_n2 * vtiTA) * (pp_N2_cTA_t0 - pp_N2_tiTA))

func tissue_TA_rk4():
	# Étapes de Runge-Kutta
	var k1 = dt * f_ti_TA(pp_N2_tiTA_t0)
	var k2 = dt * f_ti_TA(pp_N2_tiTA_t0 + 0.5 * k1)
	var k3 = dt * f_ti_TA(pp_N2_tiTA_t0 + 0.5 * k2)
	var k4 = dt * f_ti_TA(pp_N2_tiTA_t0 + k3)
	
		# Mise à jour de la variable
	pp_N2_tiTA_t1 = pp_N2_tiTA_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6

# methode euler
func tissue_MH():
	var delta = (kn2MH/(alpha_n2*vtiMH)*(pp_N2_cMH_t0-pp_N2_tiMH_t0))*dt
	pp_N2_tiMH_t1 = pp_N2_tiMH_t0 + delta

#methode runge kutta4

# Fonction dérivée définie globalement
func f_ti_MH(pp_N2_tiMH):
		return (kn2MH / (alpha_n2 * vtiMH) * (pp_N2_cMH_t0 - pp_N2_tiMH))

func tissue_MH_rk4():
		# Étapes de Runge-Kutta
	var k1 = dt * f_ti_MH(pp_N2_tiMH_t0)
	var k2 = dt * f_ti_MH(pp_N2_tiMH_t0 + 0.5 * k1)
	var k3 = dt * f_ti_MH(pp_N2_tiMH_t0 + 0.5 * k2)
	var k4 = dt * f_ti_MH(pp_N2_tiMH_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_tiMH_t1 = pp_N2_tiMH_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6

# methode euler
func tissue_M():
	var delta = (kn2M/(alpha_n2*vtiM)*(pp_N2_cM_t0-pp_N2_tiM_t0))*dt
	pp_N2_tiM_t1 = pp_N2_tiM_t0 + delta
	
#methode runge kutta 4

# Fonction dérivée définie globalement
func f_ti_M(pp_N2_tiM):
		return (kn2M / (alpha_n2 * vtiM) * (pp_N2_cM_t0 - pp_N2_tiM))

func tissue_M_rk4():
		# Étapes de Runge-Kutta
		var k1 = dt * f_ti_M(pp_N2_tiM_t0)
		var k2 = dt * f_ti_M(pp_N2_tiM_t0 + 0.5 * k1)
		var k3 = dt * f_ti_M(pp_N2_tiM_t0 + 0.5 * k2)
		var k4 = dt * f_ti_M(pp_N2_tiM_t0 + k3)
		
		# Mise à jour de la variable
		pp_N2_tiM_t1 = pp_N2_tiM_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6


# methode euler
func tissue_R():
	var delta = (kn2R/(alpha_n2*vtiR)*(pp_N2_cR_t0-pp_N2_tiR_t0))*dt
	pp_N2_tiR_t1 = pp_N2_tiR_t0 + delta
	
#methode runge kutta 4

func f_ti_R(pp_N2_tiR):
		return (kn2R / (alpha_n2 * vtiR) * (pp_N2_cR_t0 - pp_N2_tiR))

func tissue_R_rk4():
	# Étapes de Runge-Kutta
	var k1 = dt * f_ti_R(pp_N2_tiR_t0)
	var k2 = dt * f_ti_R(pp_N2_tiR_t0 + 0.5 * k1)
	var k3 = dt * f_ti_R(pp_N2_tiR_t0 + 0.5 * k2)
	var k4 = dt * f_ti_R(pp_N2_tiR_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_tiR_t1 = pp_N2_tiR_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6



# methode euler
func tissue_O():
	var delta = (kn2O/(alpha_n2*vtiO)*(pp_N2_cO_t0-pp_N2_tiO_t0))*dt
	pp_N2_tiO_t1 = pp_N2_tiO_t0 + delta	


#methode runge kutta 4
# Fonction dérivée définie globalement
func f_ti_O(pp_N2_tiO):
	return (kn2O / (alpha_n2 * vtiO) * (pp_N2_cO_t0 - pp_N2_tiO))

func tissue_O_rk4():
		# Étapes de Runge-Kutta
	var k1 = dt * f_ti_O(pp_N2_tiO_t0)
	var k2 = dt * f_ti_O(pp_N2_tiO_t0 + 0.5 * k1)
	var k3 = dt * f_ti_O(pp_N2_tiO_t0 + 0.5 * k2)
	var k4 = dt * f_ti_O(pp_N2_tiO_t0 + k3)
		
	# Mise à jour de la variable
	pp_N2_tiO_t1 = pp_N2_tiO_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6



# methode euler
func tissue_TGI():
	var delta = (kn2TGI/(alpha_n2*vtiTGI)*(pp_N2_cTGI_t0-pp_N2_tiTGI_t0))*dt
	pp_N2_tiTGI_t1 = pp_N2_tiTGI_t0 + delta	

#methode euler 
# Fonction dérivée définie globalement
func f_ti_TGI(pp_N2_tiTGI):
	return (kn2TGI / (alpha_n2 * vtiTGI) * (pp_N2_cTGI_t0 - pp_N2_tiTGI))

func tissue_TGI_rk4():
	# Étapes de Runge-Kutta
	var k1 = dt * f_ti_TGI(pp_N2_tiTGI_t0)
	var k2 = dt * f_ti_TGI(pp_N2_tiTGI_t0 + 0.5 * k1)
	var k3 = dt * f_ti_TGI(pp_N2_tiTGI_t0 + 0.5 * k2)
	var k4 = dt * f_ti_TGI(pp_N2_tiTGI_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_tiTGI_t1 = pp_N2_tiTGI_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6


# methode euler
func tissue_F():
	var delta = (kn2F/(alpha_n2*vtiF)*(pp_N2_cF_t0-pp_N2_tiF_t0))*dt
	pp_N2_tiF_t1 = pp_N2_tiF_t0 + delta
	
#mehode runge kutta 4
# Fonction dérivée définie globalement
func f_ti_F(pp_N2_tiF):
	return (kn2F / (alpha_n2 * vtiF) * (pp_N2_cF_t0 - pp_N2_tiF))

func tissue_F_rk4():
		# Étapes de Runge-Kutta
	var k1 = dt * f_ti_F(pp_N2_tiF_t0)
	var k2 = dt * f_ti_F(pp_N2_tiF_t0 + 0.5 * k1)
	var k3 = dt * f_ti_F(pp_N2_tiF_t0 + 0.5 * k2)
	var k4 = dt * f_ti_F(pp_N2_tiF_t0 + k3)
	
	# Mise à jour de la variable
	pp_N2_tiF_t1 = pp_N2_tiF_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6



# methode euler
func tissue_RDC():
	var delta = (kn2RDC/(alpha_n2*vtiRDC)*(pp_N2_cRDC_t0-pp_N2_tiRDC_t0))*dt
	pp_N2_tiRDC_t1 = pp_N2_tiRDC_t0 + delta

#methode runge kutta 4
# Fonction dérivée définie globalement
func f_ti_RDC(pp_N2_tiRDC):
		return (kn2RDC / (alpha_n2 * vtiRDC) * (pp_N2_cRDC_t0 - pp_N2_tiRDC))

func tissue_RDC_rk4():
		# Étapes de Runge-Kutta
		var k1 = dt * f_ti_RDC(pp_N2_tiRDC_t0)
		var k2 = dt * f_ti_RDC(pp_N2_tiRDC_t0 + 0.5 * k1)
		var k3 = dt * f_ti_RDC(pp_N2_tiRDC_t0 + 0.5 * k2)
		var k4 = dt * f_ti_RDC(pp_N2_tiRDC_t0 + k3)
		
		# Mise à jour de la variable
		pp_N2_tiRDC_t1 = pp_N2_tiRDC_t0 + (k1 + 2 * k2 + 2 * k3 + k4) / 6


func update_debug_textbox(debug_message):
	# Ajoutez le message de débogage à la zone de texte
	debug_textbox.text += debug_message + "\n"
	
func update_debug_textbox2(debug_message):
	# Ajoutez le message de débogage à la zone de texte
	debug_textbox2.text += debug_message + "\n"

func update_debug_textbox3(debug_message):
	# Ajoutez le message de débogage à la zone de texte
	debug_textbox3.text += debug_message + "\n"
	
func update_debug_textbox4(debug_message):
	# Ajoutez le message de débogage à la zone de texte
	debug_textbox4.text += debug_message + "\n"
	
func update_debug_textbox5(debug_message):
	# Ajoutez le message de débogage à la zone de texte
	debug_textbox5.text += debug_message + "\n"
	
func update_debug_textbox6(debug_message):
	# Ajoutez le message de débogage à la zone de texte
	debug_textbox6.text += debug_message + "\n"
	
func update_debug_textbox7(debug_message):
	# Ajoutez le message de débogage à la zone de texte
	debug_textbox7.text += debug_message + "\n"
	
func update_debug_textbox8(debug_message):
	# Ajoutez le message de débogage à la zone de texte
	debug_textbox8.text += debug_message + "\n"
	
func update_debug_textbox9(debug_message):
	# Ajoutez le message de débogage à la zone de texte
	debug_textbox9.text += debug_message + "\n"
	
func update_debug_textbox10(debug_message):
	# Ajoutez le message de débogage à la zone de texte
	debug_textbox10.text += debug_message + "\n"
	
func update_debug_textbox11(debug_message):
	# Ajoutez le message de débogage à la zone de texte
	debug_textbox11.text += debug_message + "\n"
	
func update_debug_textbox12(debug_message):
	# Ajoutez le message de débogage à la zone de texte
	debug_textbox12.text += debug_message + "\n"

func verifier_et_stocker_temps_seuil():
	if pp_N2_aw_t1 >= seuil and temps_seuils["pp_N2_aw"] == null:
		temps_seuils["pp_N2_aw"] = time
	if pp_N2_alv_t1 >= seuil and temps_seuils["pp_N2_alv"] == null:
		temps_seuils["pp_N2_alv"] = time
	if pp_N2_alb_t1 >= seuil and temps_seuils["pp_N2_alb"] == null:
		temps_seuils["pp_N2_alb"] = time
	if pp_N2_v_t1 >= seuil and temps_seuils["pp_N2_v"] == null:
		temps_seuils["pp_N2_v"] = time
	if pp_N2_tiCE_t1 >= seuil and temps_seuils["pp_N2_tiCE"] == null:
		temps_seuils["pp_N2_tiCE"] = time
	if pp_N2_tiME_t1 >= seuil and temps_seuils["pp_N2_tiME"] == null: #TODO fais planter le programe
		temps_seuils["pp_N2_tiME"] = time
	if pp_N2_tiTA_t1 >= seuil and temps_seuils["pp_N2_tiTA"] == null:
		temps_seuils["pp_N2_tiTA"] = time
	if pp_N2_tiMH_t1 >= seuil and temps_seuils["pp_N2_tiMH"] == null:
		temps_seuils["pp_N2_tiMH"] = time
	if pp_N2_tiM_t1 >= seuil and temps_seuils["pp_N2_tiM"] == null:
		temps_seuils["pp_N2_tiM"] = time
	if pp_N2_tiR_t1 >= seuil and temps_seuils["pp_N2_tiR"] == null:
		temps_seuils["pp_N2_tiR"] = time
	if pp_N2_tiO_t1 >= seuil and temps_seuils["pp_N2_tiO"] == null:
		temps_seuils["pp_N2_tiO"] = time
	if pp_N2_tiTGI_t1 >= seuil and temps_seuils["pp_N2_tiTGI"] == null:
		temps_seuils["pp_N2_tiTGI"] = time
	if pp_N2_tiF_t1 >= seuil and temps_seuils["pp_N2_tiF"] == null:
		temps_seuils["pp_N2_tiF"] = time
	if pp_N2_tiRDC_t1 >= seuil and temps_seuils["pp_N2_tiRDC"] == null:
		temps_seuils["pp_N2_tiRDC"] = time
	if pp_N2_a_t1 >= seuil and temps_seuils["pp_N2_a"] == null:
		temps_seuils["pp_N2_a"] = time
		
@export var file_path:String = ""
func save_data_to_file():
	#METTRE LE CHEMIN VOULU POUR L'EMPLACEMENT DU FICHIER DE DONNEES
	#CHANGER LE NOM DU FICHIER AU BOUT POUR CREER UN NOUVEAU FICHIER

	# Lire le contenu existant du fichier
	var existing_data = ""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		existing_data = file.get_as_text()
		file.close()
	else:
		print("File not found, creating new file.")

	# Créez une chaîne pour stocker toutes les lignes sur une seule ligne
	var line = ""
	line += "Time = " + str(time) + ", "
	line += "Pressure atm = " + str(patm) + ", "
	line += "N2 in air in Pa = " + str(pp_N2_air) + ", "
	line += "N2 in aw in Pa = " + str(pp_N2_aw_t0) + ", "
	line += "N2 in alv in Pa = " + str(pp_N2_alv_t0) + ", "
	line += "N2 in alb in Pa = " + str(pp_N2_alb_t0) + ", "
	line += "N2 in a in Pa = " + str(pp_N2_a_t0) + ", "
	line += "N2 in v in Pa = " + str(pp_N2_v_t0) + ", "
	line += "N2 in Capilar CE (Pa) = " + str(pp_N2_cCE_t0) + ", "
	line += "N2 in Tissue CE (Pa) = " + str(pp_N2_tiCE_t0) + ", "
	line += "N2 in Capilar ME (Pa) = " + str(pp_N2_cME_t0) + ", "
	line += "N2 in Tissue ME (Pa) = " + str(pp_N2_tiME_t0) + ", "	
	line += "N2 in Capilar TA (Pa) = " + str(pp_N2_cTA_t0) + ", "
	line += "N2 in Tissue TA (Pa) = " + str(pp_N2_tiTA_t0) + ", "
	line += "N2 in Capilar MH (Pa) = " + str(pp_N2_cMH_t0) + ", "
	line += "N2 in Tissue MH (Pa) = " + str(pp_N2_tiMH_t0) + ", "
	line += "N2 in Capilar M (Pa) = " + str(pp_N2_cM_t0) + ", "
	line += "N2 in Tissue M (Pa) = " + str(pp_N2_tiM_t0) + ", "
	line += "N2 in Capilar R (Pa) = " + str(pp_N2_cR_t0) + ", "
	line += "N2 in Tissue R (Pa) = " + str(pp_N2_tiR_t0) + ", "
	line += "N2 in Capilar O (Pa) = " + str(pp_N2_cO_t0) + ", "
	line += "N2 in Tissue O (Pa) = " + str(pp_N2_tiO_t0) + ", "
	line += "N2 in Capilar TGI (Pa) = " + str(pp_N2_cTGI_t0) + ", "
	line += "N2 in Tissue TGI (Pa) = " + str(pp_N2_tiTGI_t0) + ", "
	line += "N2 in Capilar F (Pa) = " + str(pp_N2_cF_t0) + ", "
	line += "N2 in Tissue F (Pa) = " + str(pp_N2_tiF_t0) + ", "
	line += "N2 in Capilar RDC (Pa) = " + str(pp_N2_cRDC_t0) + ", "
	line += "N2 in Tissue RDC (Pa) = " + str(pp_N2_tiRDC_t0) + ", "
	line+="\n"

	# Ajouter les nouvelles données au contenu existant
	existing_data += line + "\n"

	# Réécrire le fichier avec les nouvelles données
	file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(existing_data)
		file.close()
		print("Data successfully appended to file at: " + file_path)
	else:
		print("Error: Unable to open file for writing at: " + file_path)

## Execute 1 step (dt) du modèle
func step():
	# parameters
	print("Time = " + str(time))
	print("    Pressure atm = " + str(patm))
	print("    N2 in air in Pa = " + str(pp_N2_air))
	print("    N2 in aw in Pa = " + str(pp_N2_aw_t0))
	print("    N2 in alv in Pa = " + str(pp_N2_alv_t0))
	print("    N2 in alb in Pa = " + str(pp_N2_alb_t0))
	print("    N2 in a in Pa = " + str(pp_N2_a_t0))
	print("    N2 in v in Pa = " + str(pp_N2_v_t0))
	
	var message = "Time = " + str(time) + "\n" + "Pressure atm = " + str(patm) + "\n" + "N2 in air in Pa = " + str(pp_N2_air) + "\n" + "N2 in aw in Pa = " + str(pp_N2_aw_t0) + "\n" + "N2 in alv in Pa = " + str(pp_N2_alv_t0) + "\n" + "N2 in alb in Pa = " + str(pp_N2_alb_t0) + "\n" +"N2 in a in Pa = " + str(pp_N2_a_t0) + "\n" +"N2 in v in Pa = " + str(pp_N2_v_t0) + "\n"
	var message2 = "Time = " + str(time) + "\n" + "N2 in Capilar (Pa) = " + str(pp_N2_cCE_t0) + "\n" + "N2 in Tissue (Pa) = " + str(pp_N2_tiCE_t0) + "\n"
	var message3 = "Valeurs des t1/2 :" + str(temps_seuils) + "\n" 
	var message4 = "Time = " + str(time) + "\n" + "N2 in Capilar (Pa) = " + str(pp_N2_cTA_t0) + "\n" + "N2 in Tissue (Pa) = " + str(pp_N2_tiTA_t0) + "\n"
	var message5 = "Time = " + str(time) + "\n" + "N2 in Capilar (Pa) = " + str(pp_N2_cMH_t0) + "\n" + "N2 in Tissue (Pa) = " + str(pp_N2_tiMH_t0) + "\n"
	var message6 = "Time = " + str(time) + "\n" + "N2 in Capilar (Pa) = " + str(pp_N2_cM_t0) + "\n" + "N2 in Tissue (Pa) = " + str(pp_N2_tiM_t0) + "\n"
	var message7 = "Time = " + str(time) + "\n" + "N2 in Capilar (Pa) = " + str(pp_N2_cR_t0) + "\n" + "N2 in Tissue (Pa) = " + str(pp_N2_tiR_t0) + "\n"
	var message8 = "Time = " + str(time) + "\n" + "N2 in Capilar (Pa) = " + str(pp_N2_cO_t0) + "\n" + "N2 in Tissue (Pa) = " + str(pp_N2_tiO_t0) + "\n"
	var message9 = "Time = " + str(time) + "\n" + "N2 in Capilar (Pa) = " + str(pp_N2_cTGI_t0) + "\n" + "N2 in Tissue (Pa) = " + str(pp_N2_tiTGI_t0) + "\n"
	var message10 = "Time = " + str(time) + "\n" + "N2 in Capilar (Pa) = " + str(pp_N2_cF_t0) + "\n" + "N2 in Tissue (Pa) = " + str(pp_N2_tiF_t0) + "\n"
	var message11 = "Time = " + str(time) + "\n" + "N2 in Capilar (Pa) = " + str(pp_N2_cRDC_t0) + "\n" + "N2 in Tissue (Pa) = " + str(pp_N2_tiRDC_t0) + "\n"
	var message12 = "Time = " + str(time) + "\n" + "N2 in Capilar (Pa) = " + str(pp_N2_cME_t0) + "\n" + "N2 in Tissue (Pa) = " + str(pp_N2_tiME_t0) + "\n"
	
	update_debug_textbox(message)
	update_debug_textbox2(message2)
	update_debug_textbox3(message3)
	update_debug_textbox4(message4)
	update_debug_textbox5(message5)
	update_debug_textbox6(message6)
	update_debug_textbox7(message7)
	update_debug_textbox8(message8)
	update_debug_textbox9(message9)
	update_debug_textbox10(message10)
	update_debug_textbox11(message11)
	update_debug_textbox12(message12)	
	
	time = time + dt
	iteration = iteration + 1 
		# Compute one step
	pressure_atm()
	air()
	airways_rk4()
	alveolar_blood_rk4()
	alveolar_blood_rk4()
	arterial_blood_rk4()
	venous_blood_rk4()
	capilar_blood_CE_rk4()
	tissue_CE_rk4()
	capilar_blood_ME_rk6()
	tissue_ME_rk6()
	capilar_blood_TA_rk4()
	tissue_TA_rk4()
	capilar_blood_MH_rk4()
	tissue_MH_rk4()
	capilar_blood_M_rk4()
	tissue_M_rk4()
	capilar_blood_R_rk4()
	tissue_R_rk4()
	capilar_blood_O_rk4()
	tissue_O_rk4()
	capilar_blood_TGI_rk4()
	tissue_TGI_rk4()
	capilar_blood_F_rk4()
	tissue_F_rk4()
	capilar_blood_RDC_rk4()
	tissue_RDC_rk4()
	verifier_et_stocker_temps_seuil()
	
		# Preparer le prochain step
	pp_N2_aw_t0 	= pp_N2_aw_t1
	pp_N2_alv_t0	= pp_N2_alv_t1
	pp_N2_alb_t0	 = pp_N2_alb_t1
	pp_N2_a_t0		= pp_N2_a_t1
	pp_N2_v_t0		= pp_N2_v_t1
	
		# Variables tissus
	pp_N2_tiCE_t0		= pp_N2_tiCE_t1
	pp_N2_cCE_t0		= pp_N2_cCE_t1
	pp_N2_tiME_t0 	= pp_N2_tiME_t1
	pp_N2_cME_t0		= pp_N2_cME_t1
	pp_N2_tiTA_t0 	= pp_N2_tiTA_t1
	pp_N2_cTA_t0		= pp_N2_cTA_t1
	pp_N2_tiMH_t0 	= pp_N2_tiMH_t1
	pp_N2_cMH_t0		= pp_N2_cMH_t1
	pp_N2_cM_t0		= pp_N2_cM_t1
	pp_N2_tiM_t0 	= pp_N2_tiM_t1
	pp_N2_cR_t0		= pp_N2_cR_t1
	pp_N2_tiR_t0 	= pp_N2_tiR_t1
	pp_N2_cO_t0		= pp_N2_cO_t1
	pp_N2_tiO_t0 	= pp_N2_tiO_t1
	pp_N2_cTGI_t0		= pp_N2_cTGI_t1
	pp_N2_tiTGI_t0 	= pp_N2_tiTGI_t1
	pp_N2_cF_t0		= pp_N2_cF_t1
	pp_N2_tiF_t0 	= pp_N2_tiF_t1
	pp_N2_cRDC_t0		= pp_N2_cRDC_t1
	pp_N2_tiRDC_t0 	= pp_N2_tiRDC_t1
	
	save_data_to_file()
	
	k = k + 1
	
	if(k==99):
		debug_textbox.text = ""  # Vide la zone de texte de débogage 1 toutes les 100 itérations
		debug_textbox2.text = ""  # Vide la zone de texte de débogage 2 toutes les 100 itérations
		debug_textbox3.text = ""  # Vide la zone de texte de débogage 3 toutes les 100 itérations
		debug_textbox4.text = ""  # Vide la zone de texte de débogage 4 toutes les 100 itérations
		debug_textbox5.text = ""  # Vide la zone de texte de débogage 5 toutes les 100 itérations
		debug_textbox6.text = ""  # Vide la zone de texte de débogage 6 toutes les 100 itérations
		debug_textbox7.text = ""  # Vide la zone de texte de débogage 7 toutes les 100 itérations
		debug_textbox8.text = ""  # Vide la zone de texte de débogage 8 toutes les 100 itérations
		debug_textbox9.text = ""  # Vide la zone de texte de débogage 9 toutes les 100 itérations
		debug_textbox10.text = ""  # Vide la zone de texte de débogage 10 toutes les 100 itérations
		debug_textbox11.text = ""  # Vide la zone de texte de débogage 11 toutes les 100 itérations
		debug_textbox12.text = ""  # Vide la zone de texte de débogage 12 toutes les 100 itérations
		k = 0



## Execute 1 step (dt) du modèle pour le graphe
func step2():


		# Compute one step
	pressure_atm()
	air()
	airways_rk4()
	alveolar_rk4()
	alveolar_blood_rk4()
	arterial_blood_rk4()
	venous_blood_rk4()
	capilar_blood_CE_rk4()
	tissue_CE_rk4()
	capilar_blood_ME_rk6()
	tissue_ME_rk6()
	capilar_blood_TA_rk4()
	tissue_TA_rk4()
	capilar_blood_MH_rk4()
	tissue_MH_rk4()
	capilar_blood_M_rk4()
	tissue_M_rk4()
	capilar_blood_R_rk4()
	tissue_R_rk4()
	capilar_blood_O_rk4()
	tissue_O_rk4()
	capilar_blood_TGI_rk4()
	tissue_TGI_rk4()
	capilar_blood_F_rk4()
	tissue_F_rk4()
	capilar_blood_RDC_rk4()
	tissue_RDC_rk4()
	
		# Preparer le prochain step
	pp_N2_aw_t0 	= pp_N2_aw_t1
	pp_N2_alv_t0	= pp_N2_alv_t1
	pp_N2_alb_t0	 = pp_N2_alb_t1
	pp_N2_a_t0		= pp_N2_a_t1
	pp_N2_v_t0		= pp_N2_v_t1
	
		# Variables tissus
	pp_N2_tiCE_t0		= pp_N2_tiCE_t1
	pp_N2_cCE_t0		= pp_N2_cCE_t1
	pp_N2_tiME_t0 	= pp_N2_tiME_t1
	pp_N2_cME_t0		= pp_N2_cME_t1
	pp_N2_tiTA_t0 	= pp_N2_tiTA_t1
	pp_N2_cTA_t0		= pp_N2_cTA_t1
	pp_N2_tiMH_t0 	= pp_N2_tiMH_t1
	pp_N2_cMH_t0		= pp_N2_cMH_t1
	pp_N2_cM_t0		= pp_N2_cM_t1
	pp_N2_tiM_t0 	= pp_N2_tiM_t1
	pp_N2_cR_t0		= pp_N2_cR_t1
	pp_N2_tiR_t0 	= pp_N2_tiR_t1
	pp_N2_cO_t0		= pp_N2_cO_t1
	pp_N2_tiO_t0 	= pp_N2_tiO_t1
	pp_N2_cTGI_t0		= pp_N2_cTGI_t1
	pp_N2_tiTGI_t0 	= pp_N2_tiTGI_t1
	pp_N2_cF_t0		= pp_N2_cF_t1
	pp_N2_tiF_t0 	= pp_N2_tiF_t1
	pp_N2_cRDC_t0		= pp_N2_cRDC_t1
	pp_N2_tiRDC_t0 	= pp_N2_tiRDC_t1
	
	
	k = k + 1
	#next step
	time = time + dt
	iteration = iteration + 1 


# ***********************
# Fonctions de simulation
# ***********************

# Paramètres de simulations
var play:bool = false

# Appelé à l'initialisation.
# ***********************
# Fonctions de Graph
# ***********************
var my_plotCE : PlotItem = null
var my_plotTA : PlotItem = null
var my_plotME : PlotItem = null
var my_plotR : PlotItem = null
var my_plotO : PlotItem = null
var my_plotMH : PlotItem = null
var my_plotM : PlotItem = null
var my_plotRDC : PlotItem = null
var my_plotTGI : PlotItem = null
var my_plotti : PlotItem = null
var swapCE: bool = true
var swapME: bool = true
var swapTA: bool = true
var swapMH: bool = true
var swapR: bool = true
var swapO: bool = true
var swapTGI: bool = true
var swapRDC: bool = true
var swapM: bool = true
var swapti: bool = true
#play
func _on_add_Play_pressed() -> void:
	_on_add_plot_CE_pressed()
	_on_add_plot_pressedM()
	_on_add_plot_pressedME()
	_on_add_plot_pressedMH()
	_on_add_plot_pressedOS()
	_on_add_plot_pressedR()
	_on_add_plot_pressedRDC()
	_on_add_plot_pressedTA()
	_on_add_plot_pressedTGI()
	#graphe cerveau

func _on_add_plot_CE_pressed() -> void:
	

	# Créer un nouveau plot avec un label unique et une couleur dynamique
	Input.set_default_cursor_shape(Input.CURSOR_IBEAM)  # Change le curseur en IBeameur
	await get_tree().process_frame  # Met à jour l'affichage
	my_plotCE = $TabContainer/Graph/Graph2D.add_plot_item(  
			"Plot %d" % [$TabContainer/Graph/Graph2D.count()],
			[Color.RED][$TabContainer/Graph/Graph2D.count() % 1],
			[1.0, 1.0, 1.0].pick_random()
			)
	print("press add CE!")
	var x: float = 0.0  # Initialize the x value
	var y: float = 0.0  # Initialize the y value
	
	while time <120:

		step2()#met a jour lest valeur
		if iteration % 500 == 0: #recupere 1 valeur toute les 500 #or pp_N2_tiCE_t1>yt0*0.1
			x = time  # Increment x 
			y = pp_N2_tiCE_t0  # increment  y 
			# Add the point (x, y) to the plot
			my_plotCE.add_point(Vector2(x, y))

	_reset_valuesCourbe()
	print("Plot updated with points!")
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

 
func _swapCE() -> void:#passage de l'état visible a invisible de la courbe
	if my_plotCE :
		if swapCE :
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotCE, Color.TRANSPARENT)
			swapCE=false
		else:
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotCE, Color.RED)	
			swapCE=true



#graphe tissue adipeux
func _on_add_plot_pressedTA() -> void:
	# Créer un nouveau plot avec un label unique et une couleur dynamique
	my_plotTA = $TabContainer/Graph/Graph2D.add_plot_item(  
			"Plot %d" % [$TabContainer/Graph/Graph2D.count()],
			[Color.GREEN][$TabContainer/Graph/Graph2D.count() % 1],
			[1.0, 1.0, 1.0].pick_random()
			)
	print("press add TA!")
	
	var x: float = 0.0  # Initialize the x value
	var y: float = 0.0  # Initialize the y value
	
	while time <120:
		step2()#met a jour lest valeur
		if iteration % 500 == 0: #recupere 1 valeur toute les 500 
			x = time  # Increment x 
			y = pp_N2_tiTA_t0  # increment  y 
			# Add the point (x, y) to the plot
			my_plotTA.add_point(Vector2(x, y))
	_reset_valuesCourbe()
	print("Plot updated with points!")
func _swapTA() -> void:
	if my_plotTA :
		if swapTA :
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotTA, Color.TRANSPARENT)
			swapTA=false
		else:
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotTA, Color.GREEN)	
			swapTA=true




#graph muscle haut du corp
func _on_add_plot_pressedMH() -> void:
	# Créer un nouveau plot avec un label unique et une couleur dynamique
	my_plotMH = $TabContainer/Graph/Graph2D.add_plot_item(  
			"Plot %d" % [$TabContainer/Graph/Graph2D.count()],
			[Color.BLUE][$TabContainer/Graph/Graph2D.count() % 1],
			[1.0, 1.0, 1.0].pick_random()
			)
	print("press add MH!")
	
	
	var x: float = 0.0  # Initialize the x value
	var y: float = 0.0  # Initialize the y value
	
	while time <120:
		step2()#met a jour lest valeur
		if iteration % 500 == 0: #recupere 1 valeur toute les 500 
			x = time  # Increment x 
			y = pp_N2_tiMH_t0  # increment  y 
			# Add the point (x, y) to the plot
			my_plotMH.add_point(Vector2(x, y))
	_reset_valuesCourbe()
	print("Plot updated with points!")
func _swapMH() -> void:
	if my_plotMH :
		if swapMH :
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotMH, Color.TRANSPARENT)
			swapMH=false
		else:
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotMH, Color.BLUE)	
			swapMH=true



#graphe muscle bas du corp
func _on_add_plot_pressedM() -> void:
	# Créer un nouveau plot avec un label unique et une couleur dynamique
	my_plotM = $TabContainer/Graph/Graph2D.add_plot_item(  
			"Plot %d" % [$TabContainer/Graph/Graph2D.count()],
			[Color.YELLOW][$TabContainer/Graph/Graph2D.count() % 1],
			[1.0, 1.0, 1.0].pick_random()
			)
	print("press add M!")
	
	var x: float = 0.0  # Initialize the x value
	var y: float = 0.0  # Initialize the y value
	
	while time <120:
		step2()#met a jour lest valeur
		if iteration % 500 == 0: #recupere 1 valeur toute les 500 
			x = time  # Increment x 
			y = pp_N2_tiM_t0  # increment  y 
			# Add the point (x, y) to the plot
			my_plotM.add_point(Vector2(x, y))
	_reset_valuesCourbe()
	print("Plot updated with points!")
func _swapM() -> void:
	if my_plotM :
		if swapM :
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotM, Color.TRANSPARENT)
			swapM=false
		else:
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotM, Color.YELLOW)	
			swapM=true

#graphe rein
func _on_add_plot_pressedR() -> void:
	# Créer un nouveau plot avec un label unique et une couleur dynamique
	my_plotR = $TabContainer/Graph/Graph2D.add_plot_item(  
			"Plot %d" % [$TabContainer/Graph/Graph2D.count()],
			[Color.REBECCA_PURPLE][$TabContainer/Graph/Graph2D.count() % 1],
			[1.0, 1.0, 1.0].pick_random()
			)
	print("press add R!")
	
	var x: float = 0.0  # Initialize the x value
	var y: float = 0.0  # Initialize the y value
	
	while time <120:
		step2()#met a jour lest valeur
		if iteration % 500 == 0: #recupere 1 valeur toute les 500 
			x = time  # Increment x 
			y = pp_N2_tiR_t0  # increment  y 
			# Add the point (x, y) to the plot
			my_plotR.add_point(Vector2(x, y))
	_reset_valuesCourbe()
	print("Plot updated with points!")
	

func _swapR() -> void:
	if my_plotR :
		if swapR :
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotR, Color.TRANSPARENT)
			swapR=false
		else:
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotR, Color.REBECCA_PURPLE)	
			swapR=true

#graphe OS		
func _on_add_plot_pressedOS() -> void:
	# Créer un nouveau plot avec un label unique et une couleur dynamique
	my_plotO = $TabContainer/Graph/Graph2D.add_plot_item(  
			"Plot %d" % [$TabContainer/Graph/Graph2D.count()],
			[Color.ORANGE][$TabContainer/Graph/Graph2D.count() % 1],
			[1.0, 1.0, 1.0].pick_random()
			)
	print("press add OS!")
	
	var x: float = 0.0  # Initialize the x value
	var y: float = 0.0  # Initialize the y value
	
	while time <120:
		step2()#met a jour lest valeur
		if iteration % 500 == 0: #recupere 1 valeur toute les 500 
			x = time  # Increment x 
			y = pp_N2_tiO_t0  # increment  y 
			# Add the point (x, y) to the plot
			my_plotO.add_point(Vector2(x, y))
	_reset_valuesCourbe()
	print("Plot updated with points!")
	
func _swapO() -> void:
	if my_plotO :
		if swapO :
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotO, Color.TRANSPARENT)
			swapO=false
		else:
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotO, Color.ORANGE)	
			swapO=true

		
#graphe du transit gastro-intestinal
func _on_add_plot_pressedTGI() -> void:
	# Créer un nouveau plot avec un label unique et une couleur dynamique
	my_plotTGI = $TabContainer/Graph/Graph2D.add_plot_item(  
			"Plot %d" % [$TabContainer/Graph/Graph2D.count()],
			[Color.TEAL][$TabContainer/Graph/Graph2D.count() % 1],
			[1.0, 1.0, 1.0].pick_random()
			)
	print("press add TGI!")

	var x: float = 0.0  # Initialize the x value
	var y: float = 0.0  # Initialize the y value
	
	while time <120:
		step2()#met a jour lest valeur
		if iteration % 500 == 0: #recupere 1 valeur toute les 500 
			x = time  # Increment x 
			y = pp_N2_tiTGI_t0  # increment  y 
			# Add the point (x, y) to the plot
			my_plotTGI.add_point(Vector2(x, y))
	_reset_valuesCourbe()
	print("Plot updated with points!")

func _swapTGI() -> void:
	if my_plotTGI :
		if swapTGI :
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotTGI, Color.TRANSPARENT)
			swapTGI=false
		else:
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotTGI, Color.TEAL)	
			swapTGI=true


#graphe ME
func _on_add_plot_pressedME() -> void:
	# Créer un nouveau plot avec un label unique et une couleur dynamique
	my_plotME = $TabContainer/Graph/Graph2D.add_plot_item(  
			"Plot %d" % [$TabContainer/Graph/Graph2D.count()],
			[Color.BLACK][$TabContainer/Graph/Graph2D.count() % 1],
			[1.0, 1.0, 1.0].pick_random()
			)
	print("press add ME !")

	var x: float = 0.0  # Initialize the x value
	var y: float = 0.0  # Initialize the y value
	
	while time <120:
		step2()#met a jour lest valeur
		if iteration % 500 == 0: #recupere 1 valeur toute les 500 
			x = time  # Increment x 
			y = pp_N2_tiME_t0  # increment  y 
			# Add the point (x, y) to the plot
			my_plotME.add_point(Vector2(x, y))
	_reset_valuesCourbe()
	print("Plot updated with points!")

func _swapME() -> void:
	if my_plotME :
		if swapME :
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotME, Color.TRANSPARENT)
			swapME=false
		else:
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotME, Color.BLACK)	
			swapME=true



#graph rest du corp
func _on_add_plot_pressedRDC() -> void:
	# Créer un nouveau plot avec un label unique et une couleur dynamique
	my_plotRDC = $TabContainer/Graph/Graph2D.add_plot_item(  
			"Plot %d" % [$TabContainer/Graph/Graph2D.count()],
			[Color.FLORAL_WHITE][$TabContainer/Graph/Graph2D.count() % 1],
			[1.0, 1.0, 1.0].pick_random()
			)
	print("press add RDC!")

	var x: float = 0.0  # Initialize the x value
	var y: float = 0.0  # Initialize the y value
	
	while time <120:
		step2()#met a jour lest valeur
		if iteration % 500 == 0: #recupere 1 valeur toute les 500 
			x = time  # Increment x 
			y = pp_N2_tiRDC_t0  # increment  y 
			# Add the point (x, y) to the plot
			my_plotRDC.add_point(Vector2(x, y))
	_reset_valuesCourbe()
	print("Plot updated with points!")

func _swapRDC() -> void:
	if my_plotRDC :
		if swapRDC :
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotRDC, Color.TRANSPARENT)
			swapRDC=false
		else:
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotRDC, Color.FLORAL_WHITE)	
			swapRDC=true




func _on_add_plot_pressedti() -> void:
	# Créer un nouveau plot avec un label unique et une couleur dynamique
	my_plotti = $TabContainer/Graph/Graph2D.add_plot_item(  
			"Plot %d" % [$TabContainer/Graph/Graph2D.count()],
			[Color.YELLOW][$TabContainer/Graph/Graph2D.count() % 1],
			[1.0, 1.0, 1.0].pick_random()
			)
	print("press add 1 tissue !")
	
	var x: float = 0.0  # Initialize the x value
	var y: float = 0.0  # Initialize the y value
	
	while time <60:
		step_mono()#met a jour lest valeur
		if iteration % 500 == 0: #recupere 1 valeur toute les 500 
			x = time  # Increment x 
			y = pp_N2_ti_t0  # increment  y 
			# Add the point (x, y) to the plot
			my_plotti.add_point(Vector2(x, y))
	_reset_valuesCourbe()
	print("Plot updated with points!")
func _swapti() -> void:
	if my_plotti :
		if swapti :
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotti, Color.TRANSPARENT)
			swapM=false
		else:
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotti, Color.YELLOW)	
			swapM=true





func _on_remove_all_plots_pressed() -> void:
	$TabContainer/Graph/Graph2D.remove_all()
	print("press remove !")
	

# ***********************
# Fonction de reset Pour les courbes
# ***********************
func _reset_valuesCourbe(): 
	iteration =0
	time = 0.0
	patm = 101325.0
	pp_N2_air = 0.0
	pp_N2_aw_t0 = 75112.41
	pp_N2_aw_t1 = 0.0
	pp_N2_alv_t0 = 75112.41
	pp_N2_alv_t1 = 0.0
	pp_N2_alb_t0 = 75112.41
	pp_N2_alb_t1 = 0.0
	pp_N2_v_t0 = 75112.41
	pp_N2_v_t1 = 0.0
	pp_N2_a_t0 = 75112.41
	pp_N2_a_t1 = 0.0
	vtiCE = 1.35
	vcCE = 0.027
	mo2CE = 1.596
	kn2CE = 0.00214
	QCE = 0.63
	pp_N2_tiCE_t0 = 75112.41
	pp_N2_tiCE_t1 = 0.0
	pp_N2_cCE_t0 = 75112.41
	pp_N2_cCE_t1 = 0.0
	
	vtiME = 0.03
	vcME = 0.006
	mo2ME = 1.596
	kn2ME = 0.00214
	QME = 0.15#TODO a verifier
	pp_N2_tiME_t0 = 75112.41
	pp_N2_tiME_t1 = 0.0
	pp_N2_cME_t0 = 75112.41
	pp_N2_cME_t1 = 0.0
	
	vtiTA = 16
	vcTA = 0.011
	mo2TA = 0.026
	kn2TA = 0.0000214
	QTA = 0.419
	pp_N2_tiTA_t0 = 75112.41
	pp_N2_tiTA_t1 = 0.0
	pp_N2_cTA_t0 = 75112.41
	pp_N2_cTA_t1 = 0.0
	vtiMH = 6.72
	vcMH = 0.0095
	mo2MH = 0.087
	kn2MH = 0.000022
	QMH = 0.07
	pp_N2_tiMH_t0 = 75112.41
	pp_N2_tiMH_t1 = 0.0
	pp_N2_cMH_t0 = 75112.41
	pp_N2_cMH_t1 = 0.0
	vtiM = 20.17
	vcM = 0.0285
	mo2M = 0.087
	kn2M = 0.000021
	QM = 0.21
	pp_N2_tiM_t0 = 75112.41
	pp_N2_tiM_t1 = 0.0
	pp_N2_cM_t0 = 75112.41
	pp_N2_cM_t1 = 0.0
	vtiR = 0.30
	vcR = 0.042
	mo2R = 2.95
	kn2R = 0.002
	QR = 1.2
	pp_N2_tiR_t0 = 75112.41
	pp_N2_tiR_t1 = 0.0
	pp_N2_cR_t0 = 75112.41
	pp_N2_cR_t1 = 0.0
	vtiO = 6.81
	vcO = 0.011
	mo2O = 0.113
	kn2O = 0.0000535
	QO = 0.5
	pp_N2_tiO_t0 = 75112.41
	pp_N2_tiO_t1 = 0.0
	pp_N2_cO_t0 = 75112.41
	pp_N2_cO_t1 = 0.0
	vtiTGI = 1.28
	vcTGI = 0.040
	mo2TGI = 0.0806
	kn2TGI = 0.000043
	QTGI = 0.065
	pp_N2_tiTGI_t0 = 75112.41
	pp_N2_tiTGI_t1 = 0.0
	pp_N2_cTGI_t0 = 75112.41
	pp_N2_cTGI_t1 = 0.0
	vtiF = 1.71
	vcF = 0.054
	mo2F = 1.3507
	kn2F = 0.00107
	QF = 0.8
	pp_N2_tiF_t0 = 75112.41
	pp_N2_tiF_t1 = 0.0
	pp_N2_cF_t0 = 75112.41
	pp_N2_cF_t1 = 0.0
	vtiRDC = 6.04
	vcRDC = 0.039
	mo2RDC = 5.0965
	kn2RDC = 0.00107
	QRDC = 0.3
	pp_N2_tiRDC_t0 = 75112.41
	pp_N2_tiRDC_t1 = 0.0
	pp_N2_cRDC_t0 = 75112.41
	pp_N2_cRDC_t1 = 0.0
	tmp_t = 0.0
	tmp_s = 0.0
	vent = 8.1
	vaw = 1.5
	valg = 1.0
	valb = 0.5
	q = 4.2
	va = 1.7
	vv = 3.0
	patm = 101325.0
	dt = dtINI
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
	
#func _on_text_fo2(new_text):
	#if(new_text==""):
		#fn2 = 0.79
	#else:
		#fn2 = float(new_text)
	#print("Nouvelle valeur de fN₂: " +str(fn2))

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

func _on_text_dt(new_text):
	if(new_text==""):
		dt = dtINI
	else:
		dt = float(new_text)
	print("Nouvelle valeur de dt: " +str(dt))
	
func _on_text_vtice(new_text):
	if(new_text==""):
		vtiCE = 1.35
	else:
		vtiCE = float(new_text)
	print("Nouvelle valeur de vtiCE: " +str(vtiCE))
	
func _on_text_vcce(new_text):
	if(new_text==""):
		vcCE = 0.027
	else:
		vcCE = float(new_text)
	print("Nouvelle valeur de vcCE: " +str(vcCE))
	
func _on_text_qce(new_text):
	if(new_text==""):
		QCE = 0.63
	else:
		QCE = float(new_text)
	print("Nouvelle valeur de QCE: " +str(QCE))
	
func _on_text_vtita(new_text):
	if(new_text==""):
		vtiTA = 16
	else:
		vtiTA = float(new_text)
	print("Nouvelle valeur de vtiTA: " +str(vtiTA))
	
func _on_text_vcta(new_text):
	if(new_text==""):
		vcTA = 0.011
	else:
		vcTA = float(new_text)
	print("Nouvelle valeur de vcTA: " +str(vcTA))
	
func _on_text_qta(new_text):
	if(new_text==""):
		QTA = 0.419
	else:
		QTA = float(new_text)
	print("Nouvelle valeur de QTA: " +str(QTA))
	
func _on_text_vtimh(new_text):
	if(new_text==""):
		vtiMH = 6.72
	else:
		vtiMH = float(new_text)
	print("Nouvelle valeur de vtiMH: " +str(vtiMH))
	
func _on_text_vcmh(new_text):
	if(new_text==""):
		vcMH = 0.0095
	else:
		vcMH = float(new_text)
	print("Nouvelle valeur de vcMH: " +str(vcMH))
	
func _on_text_qmh(new_text):
	if(new_text==""):
		QMH = 0.07
	else:
		QMH = float(new_text)
	print("Nouvelle valeur de QMH: " +str(QMH))
	
func _on_text_vtim(new_text):
	if(new_text==""):
		vtiM = 20.17
	else:
		vtiM = float(new_text)
	print("Nouvelle valeur de vtiM: " +str(vtiM))
	
func _on_text_vcm(new_text):
	if(new_text==""):
		vcM = 0.0285
	else:
		vcM = float(new_text)
	print("Nouvelle valeur de vcM: " +str(vcM))
	
func _on_text_qm(new_text):
	if(new_text==""):
		QM = 0.21
	else:
		QM = float(new_text)
	print("Nouvelle valeur de QM: " +str(QM))
	
func _on_text_vtir(new_text):
	if(new_text==""):
		vtiR = 0.30
	else:
		vtiR = float(new_text)
	print("Nouvelle valeur de vtiR: " +str(vtiR))
	
func _on_text_vcR(new_text):
	if(new_text==""):
		vcR = 0.042
	else:
		vcR = float(new_text)
	print("Nouvelle valeur de vcR: " +str(vcR))
	
func _on_text_qr(new_text):
	if(new_text==""):
		QR = 1.2
	else:
		QR = float(new_text)
	print("Nouvelle valeur de QR: " +str(QR))
	
func _on_text_vtio(new_text):
	if(new_text==""):
		vtiO = 6.81
	else:
		vtiO = float(new_text)
	print("Nouvelle valeur de vtiO: " +str(vtiO))
	
func _on_text_vco(new_text):
	if(new_text==""):
		vcO = 0.011
	else:
		vcO = float(new_text)
	print("Nouvelle valeur de vcO: " +str(vcO))
	
func _on_text_qo(new_text):
	if(new_text==""):
		QO = 0.5
	else:
		QO = float(new_text)
	print("Nouvelle valeur de QO: " +str(QO))
	
func _on_text_vtitgi(new_text):
	if(new_text==""):
		vtiTGI = 1.28
	else:
		vtiTGI = float(new_text)
	print("Nouvelle valeur de vtiTGI: " +str(vtiTGI))
	
func _on_text_vctgi(new_text):
	if(new_text==""):
		vcTGI = 0.04
	else:
		vcTGI = float(new_text)
	print("Nouvelle valeur de vcTGI: " +str(vcTGI))
	
func _on_text_qtgi(new_text):
	if(new_text==""):
		QTGI = 0.065
	else:
		QTGI = float(new_text)
	print("Nouvelle valeur de QTGI: " +str(QTGI))
	
func _on_text_vtif(new_text):
	if(new_text==""):
		vtiF = 1.71
	else:
		vtiF = float(new_text)
	print("Nouvelle valeur de vtiF: " +str(vtiF))
	
func _on_text_vcf(new_text):
	if(new_text==""):
		vcF = 0.054
	else:
		vcF = float(new_text)
	print("Nouvelle valeur de vcF: " +str(vcF))
	
func _on_text_qf(new_text):
	if(new_text==""):
		QF = 0.8
	else:
		QF = float(new_text)
	print("Nouvelle valeur de QF: " +str(QF))
	
func _on_text_vtirdc(new_text):
	if(new_text==""):
		vtiRDC = 6.07
	else:
		vtiRDC = float(new_text)
	print("Nouvelle valeur de vtiRDC: " +str(vtiRDC))
	
func _on_text_vcrdc(new_text):
	if(new_text==""):
		vcRDC = 0.045
	else:
		vcRDC = float(new_text)
	print("Nouvelle valeur de vcRDC: " +str(vcRDC))
	
func _on_text_qrdc(new_text):
	if(new_text==""):
		QRDC = 0.315
	else:
		QRDC = float(new_text)
	print("Nouvelle valeur de QRDC: " +str(QRDC))


############################################
#Afficher ce que signifie les boutons
#
############################################
func _on_me_mouse_entered() -> void:
	
	$TabContainer/Graph/RichTextLabelME.visible = true


func _on_me_mouse_exited() -> void:
		$TabContainer/Graph/RichTextLabelME.visible = false


func _on_tissu_adipeux_mouse_entered() -> void:
	$TabContainer/Graph/RichTextLabelTA.visible = true


func _on_tissu_adipeux_mouse_exited() -> void:
	$TabContainer/Graph/RichTextLabelTA.visible = false


func _on_muscle_mouse_entered() -> void:
	$TabContainer/Graph/RichTextLabelM.visible = true


func _on_muscle_mouse_exited() -> void:
	$TabContainer/Graph/RichTextLabelM.visible = false


func _on_mh_mouse_entered() -> void:
	$TabContainer/Graph/RichTextLabelMH.visible = true


func _on_mh_mouse_exited() -> void:
	$TabContainer/Graph/RichTextLabelMH.visible = false


func _on_rein_mouse_entered() -> void:
	$TabContainer/Graph/RichTextLabelR.visible = true


func _on_rein_mouse_exited() -> void:
	$TabContainer/Graph/RichTextLabelR.visible = false


func _on_os_mouse_entered() -> void:
	$TabContainer/Graph/RichTextLabelOS.visible = true


func _on_os_mouse_exited() -> void:
	$TabContainer/Graph/RichTextLabelOS.visible = false


func _on_tgi_mouse_entered() -> void:
	$TabContainer/Graph/RichTextLabelTGI.visible = true


func _on_tgi_mouse_exited() -> void:
	$TabContainer/Graph/RichTextLabelTGI.visible = false


func _on_rdc_mouse_entered() -> void:
	$TabContainer/Graph/RichTextLabelRDC.visible = true


func _on_rdc_mouse_exited() -> void:
	$TabContainer/Graph/RichTextLabelRDC.visible = false


func _on_add_plot_ce_mouse_entered() -> void:
	$TabContainer/Graph/RichTextLabelCE.visible = true


func _on_add_plot_ce_mouse_exited() -> void:
	$TabContainer/Graph/RichTextLabelCE.visible = false




func _on_me_mouse_entered2() -> void:
	
	$TabContainer/Graph/RichTextLabelME.visible = true


func _on_me_mouse_exited2() -> void:
		$TabContainer/Graph/RichTextLabelME.visible = false


func _on_tissu_adipeux_mouse_entered2() -> void:
	$TabContainer/Graph/RichTextLabelTA.visible = true


func _on_tissu_adipeux_mouse_exited2() -> void:
	$TabContainer/Graph/RichTextLabelTA.visible = false


func _on_muscle_mouse_entered2() -> void:
	$TabContainer/Graph/RichTextLabelM.visible = true


func _on_muscle_mouse_exited2() -> void:
	$TabContainer/Graph/RichTextLabelM.visible = false


func _on_mh_mouse_entered2() -> void:
	$TabContainer/Graph/RichTextLabelMH.visible = true


func _on_mh_mouse_exited2() -> void:
	$TabContainer/Graph/RichTextLabelMH.visible = false


func _on_rein_mouse_entered2() -> void:
	$TabContainer/Graph/RichTextLabelR.visible = true


func _on_rein_mouse_exited2() -> void:
	$TabContainer/Graph/RichTextLabelR.visible = false


func _on_os_mouse_entered2() -> void:
	$TabContainer/Graph/RichTextLabelOS.visible = true


func _on_os_mouse_exited2() -> void:
	$TabContainer/Graph/RichTextLabelOS.visible = false


func _on_tgi_mouse_entered2() -> void:
	$TabContainer/Graph/RichTextLabelTGI.visible = true


func _on_tgi_mouse_exited2() -> void:
	$TabContainer/Graph/RichTextLabelTGI.visible = false


func _on_rdc_mouse_entered2() -> void:
	$TabContainer/Graph/RichTextLabelRDC.visible = true


func _on_rdc_mouse_exited2() -> void:
	$TabContainer/Graph/RichTextLabelRDC.visible = false


func _on_add_plot_ce_mouse_entered2() -> void:
	$TabContainer/Graph/RichTextLabelCE.visible = true


func _on_add_plot_ce_mouse_exited2() -> void:
	$TabContainer/Graph/RichTextLabelCE.visible = false
	
###############################################################
#Analyse de sobole 1 tissue
###############################################################
var pp_N2_ti_t1 = 0
var pp_N2_c_t1 = 0
var N = 10000 # Nombre d'échantillons Monte Carlo
#var parametres = [
	#{"nom": "Vt", "moyenne": 70.0, "variation": 10},
	#{"nom": "vc", "moyenne": 0.5, "variation": 0.05},
	#{"nom": "valg", "moyenne": 1.0, "variation": 0.1},
	#{"nom": "valb", "moyenne": 0.5, "variation": 0.05},
	#{"nom": "va", "moyenne": 1.7, "variation": 0.17},
	#{"nom": "vv", "moyenne": 3.0, "variation": 0.3},
	#{"nom": "vaw", "moyenne": 1.5, "variation": 0.15},
	#{"nom": "q", "moyenne": 4.209, "variation": 0.4},
	#{"nom": "k1", "moyenne": 0.00267, "variation": 0.000267},
	#{"nom": "k2", "moyenne": 0.00748, "variation": 0.000748},
	#{"nom": "k3", "moyenne": 0.00267, "variation": 0.000267},
	#
#]
var l =0 
func _ready_s() -> void:
	print("Sobol Analysis start at " + str(Time.get_ticks_msec() ) )

	var panel := get_node("TabContainer/Graph/Control/ResultBox")
	panel.visible = !panel.visible
	#var d := 3                               # nombre de variables
	var N := 10000                         # taille d’échantillon
	var rng := RandomNumberGenerator.new()
	
	rng.randomize()   # graine aléatoire basée sur l’horloge
	#rng.seed = 1                             # reproductibilité

	# ─────────────────────────────────────────────────────────────
	# 1) Génération des échantillons  A  et  B  (séparés par variable)
	# ─────────────────────────────────────────────────────────────
	var ax1 : Array[float] = [];  var bx1 : Array[float] = []
	var ax2 : Array[float] = [];  var bx2 : Array[float] = []
	var ax3 : Array[float] = [];  var bx3 : Array[float] = []
	var ax4 : Array[float] = []; var bx4 : Array[float] = []
	var ax5 : Array[float] = []; var bx5 : Array[float] = []
	var ax6 : Array[float] = []; var bx6 : Array[float] = []
	var ax7 : Array[float] = []; var bx7 : Array[float] = []
	var ax8 : Array[float] = []; var bx8 : Array[float] = []
	var ax9 : Array[float] = []; var bx9 : Array[float] = []
	var ax10 : Array[float] = []; var bx10 : Array[float] = []
	var ax11 : Array[float] = []; var bx11 : Array[float] = []
	
	ax1.resize(N); ax2.resize(N); ax3.resize(N); ax4.resize(N); ax5.resize(N); ax6.resize(N); ax7.resize(N); ax8.resize(N); ax9.resize(N); ax10.resize(N); ax11.resize(N)
	bx1.resize(N); bx2.resize(N); bx3.resize(N); bx4.resize(N); bx5.resize(N); bx6.resize(N); bx7.resize(N); bx8.resize(N); bx9.resize(N); bx10.resize(N); bx11.resize(N)
	
	print("Array creation at " + str(Time.get_ticks_msec() ) )


	for l in range(N):
		ax1[l] = Vt + rng.randf_range(-100, 100);   bx1[l] = Vt + rng.randf_range(-100, 100)#vt
		vc= vc + rng.randf_range(-0.5, 0.5)
		ax2[l] = vc 
		vc= vc + rng.randf_range(-0.5, 0.5)#vc
		bx2[l] = vc
		ax3[l] = valg + rng.randf_range(-1, 1);   bx3[l] = valg + rng.randf_range(-1, 1)#valg
		ax4[l] = valb + rng.randf_range(-0.5, 0.5);    bx4[l] = valb + rng.randf_range(-0.5, 0.5)#valb
		ax5[l] = va + rng.randf_range(-1.7, 1.7);    bx5[l] = va + rng.randf_range(-1.7, 1.7)#va
		ax6[l] = vv + rng.randf_range(-3, 3);    bx6[l] = vv + rng.randf_range(-3, 3)#vv
		ax7[l] = vaw + rng.randf_range(-1.5, 1.5);    bx7[l] = vaw + rng.randf_range(-1.5, 1.5)#vaw
		ax8[l] = q + rng.randf_range(-4, 4);    bx8[l] = q + rng.randf_range(-4, 4)#q
		ax9[l] = K1 + rng.randf_range(-0.00267, 0.00267);    bx9[l] = K1 + rng.randf_range(-0.00267, 0.00267)#k1
		ax10[l] = K2 + rng.randf_range(-0.00748, 0.00748);    bx10[l] = K2 + rng.randf_range(-0.00748, 0.00748)#k2
		ax11[l] = K3 + rng.randf_range(-0.00267, 0.00267);    bx11[l] = K3 + rng.randf_range(-0.00267, 0.00267)#k3
	print("1 - " + str(Time.get_ticks_msec() ) )
#Vt: float, vc: float, valg: float,valb: float,va: float,vv: float, vaw
	#vaw =1.5	valg =1.0	valb =0.5	va =1.7 	vv =3.0 	vc =0.5 
	#q 4.209
	#Vt=70L
	#pp_N2_ti_t0: float = 75112.41
	#pp_N2_c_t0: float = 75112.41
	# ─────────────────────────────────────────────────────────────
	# 2) Évaluations du modèle  f(A)  et  f(B)
	# ─────────────────────────────────────────────────────────────
	var YA : Array[float] = [];  YA.resize(N)
	var YB : Array[float] = [];  YB.resize(N)

	print("2 - " + str(Time.get_ticks_msec() ) )

	for l in range(N):
		YA[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l])
		YB[l] = mon_model(bx1[l], bx2[l], bx3[l], bx4[l], bx5[l], bx6[l], bx7[l], bx8[l], bx9[l], bx10[l], bx11[l])

	print("3 - " + str(Time.get_ticks_msec() ) )

	# ─────────────────────────────────────────────────────────────
	## 3) Matrices mixtes  A_Bi  (pick & freeze) 
	#La méthode vise à évaluer l'influence de chaque variable d’entrée sur la sortie du modèle, en ne changeant qu’une variable à la fois (on la "pick") tandis que les autres restent fixes (on les "freeze").
	# ─────────────────────────────────────────────────────────────
	var YAB0 : Array[float] = [];  var YAB1 : Array[float] = [];  var YAB2 : Array[float] = []; var YAB3 : Array[float] = [];var YAB4 : Array[float] = []; var YAB5 : Array[float] = []; var YAB6 : Array[float] = []; var YAB7 : Array[float] = []; var YAB8 : Array[float] = []; var YAB9 : Array[float] = []; var YAB10 : Array[float] = []
	YAB0.resize(N);    YAB1.resize(N);    YAB2.resize(N)	;YAB3.resize(N);	YAB4.resize(N);	YAB5.resize(N);	YAB6.resize(N);	YAB7.resize(N);	YAB8.resize(N);	YAB9.resize(N);	YAB10.resize(N)
	print("4 - " + str(Time.get_ticks_msec() ) )


	for l in range(N):
		## i = 0 : on prend x1 de B, les autres de A
		#YAB0[l] = mon_model(bx1[l], ax2[l], ax3[l])
		## i = 1 : on prend x2 de B, les autres de A
		#YAB1[l] = mon_model(ax1[l], bx2[l], ax3[l])
		## i = 2 : on prend x3 de B, les autres de A
		#YAB2[l] = mon_model(ax1[l], ax2[l], bx3[l])
		YAB0[l] = mon_model(bx1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l])
		YAB1[l] = mon_model(ax1[l], bx2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l])
		YAB2[l] = mon_model(ax1[l], ax2[l], bx3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l])
		YAB3[l] = mon_model(ax1[l], ax2[l], ax3[l], bx4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l])
		YAB4[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], bx5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l])
		YAB5[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], bx6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l])
		YAB6[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], bx7[l], ax8[l], ax9[l], ax10[l], ax11[l])
		YAB7[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], bx8[l], ax9[l], ax10[l], ax11[l])
		YAB8[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], bx9[l], ax10[l], ax11[l])
		YAB9[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], bx10[l], ax11[l])
		YAB10[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], bx11[l])
	print("5 - " + str(Time.get_ticks_msec() ) )


	# ─────────────────────────────────────────────────────────────
	# 4) Variance totale de la sortie
	# ─────────────────────────────────────────────────────────────
	var all_Y : Array[float] = YA.duplicate()
	all_Y.append_array(YB)
	var VY := variance(all_Y)

	print("6 - " + str(Time.get_ticks_msec() ) )

	# ─────────────────────────────────────────────────────────────
	# 5) Indices de Sobol  S_i  et  S_Ti
	# ─────────────────────────────────────────────────────────────
	var S : Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	var ST : Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

	var acc_S0 := 0.0; var acc_S1 := 0.0; var acc_S2 := 0.0; var acc_S3 := 0.0; var acc_S4 := 0.0; var acc_S5 := 0.0; var acc_S6 := 0.0; var acc_S7 := 0.0; var acc_S8 := 0.0; var acc_S9 := 0.0; var acc_S10 := 0.0
	var acc_ST0 := 0.0; var acc_ST1 := 0.0; var acc_ST2 := 0.0; var acc_ST3 := 0.0; var acc_ST4 := 0.0; var acc_ST5 := 0.0; var acc_ST6 := 0.0; var acc_ST7 := 0.0; var acc_ST8 := 0.0; var acc_ST9 := 0.0; var acc_ST10 := 0.0

	for l in range(N):
		acc_S0  += YB[l] * (YAB0[l] - YA[l])
		acc_S1  += YB[l] * (YAB1[l] - YA[l])
		acc_S2  += YB[l] * (YAB2[l] - YA[l])
		acc_S3  += YB[l] * (YAB3[l] - YA[l])
		acc_S4  += YB[l] * (YAB4[l] - YA[l])
		acc_S5  += YB[l] * (YAB5[l] - YA[l])
		acc_S6  += YB[l] * (YAB6[l] - YA[l])
		acc_S7  += YB[l] * (YAB7[l] - YA[l])
		acc_S8  += YB[l] * (YAB8[l] - YA[l])
		acc_S9  += YB[l] * (YAB9[l] - YA[l])
		acc_S10  += YB[l] * (YAB10[l] - YA[l])


		var d0 := YA[l] - YAB0[l];  acc_ST0 += d0 * d0
		var d1 := YA[l] - YAB1[l];  acc_ST1 += d1 * d1
		var d2 := YA[l] - YAB2[l];  acc_ST2 += d2 * d2
		var d3 := YA[l] - YAB3[l];  acc_ST3 += d3 * d3
		var d4 := YA[l] - YAB4[l];  acc_ST4 += d4 * d4
		var d5 := YA[l] - YAB5[l];  acc_ST5 += d5 * d5
		var d6 := YA[l] - YAB6[l];  acc_ST6 += d6 * d6
		var d7 := YA[l] - YAB7[l];  acc_ST7 += d7 * d7
		var d8 := YA[l] - YAB8[l];  acc_ST8 += d8 * d8
		var d9 := YA[l] - YAB9[l];  acc_ST9 += d9 * d9
		var d10 := YA[l] - YAB10[l];  acc_ST10 += d10 * d10

	S [0] = acc_S0  / N / VY;     ST[0] = 0.5 * acc_ST0 / N / VY
	S [1] = acc_S1  / N / VY;     ST[1] = 0.5 * acc_ST1 / N / VY
	S [2] = acc_S2  / N / VY;     ST[2] = 0.5 * acc_ST2 / N / VY
	S [3] = acc_S3  / N / VY;     ST[3] = 0.5 * acc_ST3 / N / VY
	S [4] = acc_S4  / N / VY;     ST[4] = 0.5 * acc_ST4 / N / VY
	S [5] = acc_S5  / N / VY;     ST[5] = 0.5 * acc_ST5 / N / VY
	S [6] = acc_S6  / N / VY;     ST[6] = 0.5 * acc_ST6 / N / VY
	S [7] = acc_S7  / N / VY;     ST[7] = 0.5 * acc_ST7 / N / VY
	S [8] = acc_S8  / N / VY;     ST[8] = 0.5 * acc_ST8 / N / VY
	S [9] = acc_S9  / N / VY;     ST[9] = 0.5 * acc_ST9 / N / VY
	S [10] = acc_S10  / N / VY;     ST[10] = 0.5 * acc_ST10 / N / VY
	print("Sobol Analysis end   at " + str(Time.get_ticks_msec() ) )


	# ─────────────────────────────────────────────────────────────
	# 6) Affichage
	# ─────────────────────────────────────────────────────────────
	#var names := ["x₁", "x₂", "x₃"]
	#print("\nIndices de Sobol — fonction de mon_model (N =", N, ")")
	#print("────────────────────────────────────────────────────────")
	#for i in range(d):
		#print("%s :  Sᵢ = %.4f   |   Sₜᵢ = %.4f" % [names[i], S[i], ST[i]])
	var display_text := "[color=#003366]" 
	display_text +="		Indices de Sobol — fonction de mon_model (N = %d)\n" % N
	display_text += "──────────────────────────────────────────────────────────\n"
	display_text += "Variable                |   Sᵢ (effet direct)   |   Sₜᵢ (effet total)\n"
	display_text += "──────────────────────────────────────────────────────────\n"
	display_text += "Volume du tissu (x₁)    :   %.4f               |   %.4f\n" % [S[0], ST[0]]
	display_text += "Volume du capillaire (x₂)        :   %.4f               |   %.4f\n" % [S[1], ST[1]]
	display_text += "Volume alveolar gaz (x₃)   :   %.4f               |   %.4f\n" % [S[2], ST[2]]
	display_text += "Volume alveolar blood (x4)   :   %.4f               |   %.4f\n" % [S[3], ST[3]]
	display_text += "Volume arterial blood  (x5)   :   %.4f               |   %.4f\n" % [S[4], ST[4]]
	display_text += "Volume veinous blood (x6)   :   %.4f               |   %.4f\n" % [S[5], ST[5]]
	display_text += "Volume airways (x7)   :   %.4f               |   %.4f\n" % [S[6], ST[6]]
	display_text += "Q (x8)   :   %.4f               |   %.4f\n" % [S[7], ST[7]]
	display_text += "K1 (x9)   :   %.4f               |   %.4f\n" % [S[8], ST[8]]
	display_text += "K2 (x10)   :   %.4f               |   %.4f\n" % [S[9], ST[9]]
	display_text += "K3 (11)   :   %.4f               |   %.4f\n" % [S[10], ST[10]]


	# Affiche le texte dans le RichTextLabel
	get_node("TabContainer/Graph/Control/ResultBox/SobolResults").text = display_text

	#get_tree().quit()  # ferme l’application Godot
#Sᵢ : Indice de Sobol de premier ordre
#Part de la variance de la sortie due uniquement à la variable xᵢ prise seule.

#Sₜᵢ : Indice de Sobol total
#Part de la variance due à xᵢ et à toutes ses interactions avec les autres variables.


# ────────────────────────────────────────────────────────────────────
# Fonctions utilitaires
# ────────────────────────────────────────────────────────────────────
func mon_model(Vt_: float, vc_: float, valg_: float,valb_: float,va_: float,vv_: float, vaw_: float, q_:float,K1_:float,K2_:float,K3_:float ) -> float: #1 tissue
	_reset_mono()
	Vt=Vt_
	vc=vc_
	valg=valg_
	valb = valb_
	va=va_
	vv=vv_
	vaw=vaw_
	q=q_
	K1=K1_
	K2=K2_
	K3=K3_
	#var K3: float=0.00267
	var alpha_n2 :float=0.000061
	#step_mono()
	sobol_step()
	print (str(l)+":"+str(pp_N2_ti_t0))

	return pp_N2_ti_t0
	#return (K3/(alpha_n2*Vt)*(pp_N2_c_t0-pp_N2_ti_t0))#tissue
	#return (1/(vc*alpha_n2)*(q*alpha_n2*pp_N2_a_t0-(alpha_n2*q+K3_N2_mono)*pp_N2_c_t0+K3_N2_mono*pp_N2_ti_t0))#capilaire
	
	#x1 + x2/10.0 + x3/2
	#return sin(x1) + 7.0 * pow(sin(x2), 2) + 0.1 * pow(x3, 4) * sin(x1)
	
	## fonction step pour 1 seul tissue
func sobol_step() :
	while time < 60:
		step_mono()
#
var K3:float =0.00267
func step_mono() :
	# Compute one step
	pressure_atm()
	air()
	airways_rk4()
	alveolar_rk4()
	alveolar_blood_rk4()
	arterial_blood_rk4()
	venous_blood_mono()
	capilar_blood_mono()
	tissue_mono()
	# Preparer le prochain step
	pp_N2_aw_t0 	= pp_N2_aw_t1
	pp_N2_alv_t0	= pp_N2_alv_t1
	pp_N2_alb_t0	= pp_N2_alb_t1
	pp_N2_a_t0		= pp_N2_a_t1
	pp_N2_v_t0		= pp_N2_v_t1
	
		# Variables tissus
	pp_N2_ti_t0	= pp_N2_ti_t1
	pp_N2_c_t0		= pp_N2_c_t1

	# Next step
	time = time + dt
	iteration = iteration + 1 

func mean(arr: Array[float]) -> float:
	var s := 0.0
	for v in arr: s += v
	return s / arr.size()

func variance(arr: Array[float]) -> float:
	var m := mean(arr)
	var s2 := 0.0
	for v in arr:
		var d := v - m
		s2 += d * d
	return s2 / arr.size()
	
	##TODO lse parametre a varier 
		##var V debi ventilatoire
		##Q debit qaurdiaque
		##K1 K2 K3
		##tous les volume 7 
		##
		
func _reset_mono():
	time = 0.0
	
	vent = 8.1 # debit ventilatoire 
	vaw = 1.5 #volume des voix aérienne
	valg = 1.0 # volume du gaz alvéolaire
	valb = 0.5 # volume de sang alvéolaire
	q= 4.209 # debit cardiaque
	va = 1.7 #volume artériel
	vv = 3.0 #volume veineux
	patm = 101325.0 # presion ambiante
	#fn2 = 0.79 #fraction d azote dans le gaz respiré 
	
	alpha_n2 = 0.0000619 #coef solubilite azote
	ph2o = 6246.0 # presstion partiel de vapeur d eau
	K1 = 0.00267 # coef de difusion respiratoire
	K2 = 0.00748 # coef de difusion alveolo capilaire
	R = 8.314 # constante des gaz parfait
	T = 310.0 # Temperature en K
	i = 1
	k = 0
	dt = dtINI
	iteration = 0 

	pp_N2_air = 0.0
	
	pp_N2_aw_t0 = 75112.41
	pp_N2_aw_t1 = 0.0
	
	pp_N2_alv_t0 = 75112.41
	pp_N2_alv_t1 = 0.0
	
	pp_N2_alb_t0 = 75112.41
	pp_N2_alb_t1 = 0.0
	
	pp_N2_v_t0 = 75112.41
	pp_N2_v_t1 = 0.0
	
	pp_N2_a_t0 = 75112.41
	pp_N2_a_t1 = 0.0
	
	pp_N2_ti_t0 = 75112.41
	pp_N2_ti_t1 = 0.0
	
	pp_N2_c_t0 = 75112.41
	pp_N2_c_t1 = 0.0
	
	K3 = 0.000267
	Vt = 70
	vc = 0.5
	mo2CE = 1.596
	kn2CE = 0.00214




	
