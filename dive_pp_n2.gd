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
var fn2: float = 0.79 #fraction d azote dans le gaz respiré 
var t = [null,null,null,null,null,null,null,null,null,null]
var s = [null,null,null,null,null,null,null,null,null,null]

######################################################################################################################################
# LISTE DES VARIABLES QU'ON VEUT POUVOIR MODIFIER ? Q et volume pour chaque + dt
# DESCENDRE RAPIDEMENT
######################################################################################################################################

# ***********************
# Paramètres du modèle
# ***********************

var alpha_n2:float = 0.0000619
var ph2o:float = 6246.0
var k1:float = 0.00267
var k2:float = 0.00748
var R:float = 8.314
var T:float = 310.0
var tmp_t:float = 0.0
var tmp_s:float = 0.0
var time:float = 0.0
var dt:float = 0.001
var i = 1
var k = 0
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
var seuil: float = 115007.41
var temps_seuils = {
	"pp_N2_aw": null,
	"pp_N2_alv": null,
	"pp_N2_alb": null,
	"pp_N2_v": null,
	"pp_N2_tiCE": null,
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
var vcCE: float = 0.027 # Cap Vol en L
var mo2CE:float = 1.596 # MO2 en mMol/kg/min
var kn2CE: float = 0.00214 # diff coef N2
var QCE: float = 0.63 # débit sangin en L/min
var pp_N2_tiCE_t0: float = 75112.41
var pp_N2_tiCE_t1: float = 0.0
var pp_N2_cCE_t0: float = 75112.41
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
	var delta = (1/vv*((QCE*pp_N2_cCE_t0+QTA*pp_N2_cTA_t0+QMH*pp_N2_cMH_t0+QM*pp_N2_cM_t0+QR*pp_N2_cR_t0+QO*pp_N2_cO_t0+QF*pp_N2_cF_t0+QRDC*pp_N2_cRDC_t0)-(QCE+QTA+QMH+QM+QR+QO+QF+QRDC)*pp_N2_v_t0))*dt
	pp_N2_v_t1 = pp_N2_v_t0 + delta

## Compute the partial pressure of c
func capilar_blood_CE():
	var delta = (1/(vcCE*alpha_n2)*(QCE*alpha_n2*pp_N2_a_t0-(alpha_n2*QCE+kn2CE)*pp_N2_cCE_t0+kn2CE*pp_N2_tiCE_t0))*dt
	pp_N2_cCE_t1 = pp_N2_cCE_t0 + delta

#func capilar_blood_ME():
	#var delta = (1/(vcME*alpha_n2)*(QME*alpha_n2*pp_N2_a_t0-(alpha_n2*QME+kn2ME)*pp_N2_cME_t0+kn2ME*pp_N2_tiME_t0))*dt
	#pp_N2_cME_t1 = pp_N2_cME_t0 + delta

func capilar_blood_TA():
	var delta = (1/(vcTA*alpha_n2)*(QTA*alpha_n2*pp_N2_a_t0-(alpha_n2*QTA+kn2TA)*pp_N2_cTA_t0+kn2TA*pp_N2_tiTA_t0))*dt
	pp_N2_cTA_t1 = pp_N2_cTA_t0 + delta

func capilar_blood_MH():
	var delta = (1/(vcMH*alpha_n2)*(QMH*alpha_n2*pp_N2_a_t0-(alpha_n2*QMH+kn2MH)*pp_N2_cMH_t0+kn2MH*pp_N2_tiMH_t0))*dt
	pp_N2_cMH_t1 = pp_N2_cMH_t0 + delta

func capilar_blood_M():
	var delta = (1/(vcM*alpha_n2)*(QM*alpha_n2*pp_N2_a_t0-(alpha_n2*QM+kn2M)*pp_N2_cM_t0+kn2M*pp_N2_tiM_t0))*dt
	pp_N2_cM_t1 = pp_N2_cM_t0 + delta

func capilar_blood_R():
	var delta = (1/(vcR*alpha_n2)*(QR*alpha_n2*pp_N2_a_t0-(alpha_n2*QR+kn2R)*pp_N2_cR_t0+kn2R*pp_N2_tiR_t0))*dt
	pp_N2_cR_t1 = pp_N2_cR_t0 + delta

func capilar_blood_O():
	var delta = (1/(vcO*alpha_n2)*(QO*alpha_n2*pp_N2_a_t0-(alpha_n2*QO+kn2O)*pp_N2_cO_t0+kn2O*pp_N2_tiO_t0))*dt
	pp_N2_cO_t1 = pp_N2_cO_t0 + delta

func capilar_blood_TGI():
	var delta = (1/(vcTGI*alpha_n2)*(QTGI*alpha_n2*pp_N2_a_t0-(alpha_n2*QTGI+kn2TGI)*pp_N2_cTGI_t0+kn2TGI*pp_N2_tiTGI_t0))*dt
	pp_N2_cTGI_t1 = pp_N2_cTGI_t0 + delta

func capilar_blood_F():
	var delta = (1/(vcF*alpha_n2)*(alpha_n2*(QTGI*pp_N2_cTGI_t0+QF*pp_N2_a_t0)-(alpha_n2*(QF+QTGI)+kn2F)*pp_N2_cF_t0+kn2F*pp_N2_tiF_t0))*dt
	pp_N2_cF_t1 = pp_N2_cF_t0 + delta

func capilar_blood_RDC():
	var delta = (1/(vcRDC*alpha_n2)*(QRDC*alpha_n2*pp_N2_a_t0-(alpha_n2*QRDC+kn2RDC)*pp_N2_cRDC_t0+kn2RDC*pp_N2_tiRDC_t0))*dt
	pp_N2_cRDC_t1 = pp_N2_cRDC_t0 + delta
	
## Compute the partial pressure of ti
func tissue_CE():
	var delta = (kn2CE/(alpha_n2*vtiCE)*(pp_N2_cCE_t0-pp_N2_tiCE_t0))*dt
	pp_N2_tiCE_t1 = pp_N2_tiCE_t0 + delta

#func tissue_ME():
	#var delta = (kn2ME/(alpha_n2*vtiME)*(pp_N2_cME_t0-pp_N2_tiME_t0))*dt
	#pp_N2_tiME_t1 = pp_N2_tiME_t0 + delta

func tissue_TA():
	var delta = (kn2TA/(alpha_n2*vtiTA)*(pp_N2_cTA_t0-pp_N2_tiTA_t0))*dt
	pp_N2_tiTA_t1 = pp_N2_tiTA_t0 + delta

func tissue_MH():
	var delta = (kn2MH/(alpha_n2*vtiMH)*(pp_N2_cMH_t0-pp_N2_tiMH_t0))*dt
	pp_N2_tiMH_t1 = pp_N2_tiMH_t0 + delta

func tissue_M():
	var delta = (kn2M/(alpha_n2*vtiM)*(pp_N2_cM_t0-pp_N2_tiM_t0))*dt
	pp_N2_tiM_t1 = pp_N2_tiM_t0 + delta

func tissue_R():
	var delta = (kn2R/(alpha_n2*vtiR)*(pp_N2_cR_t0-pp_N2_tiR_t0))*dt
	pp_N2_tiR_t1 = pp_N2_tiR_t0 + delta

func tissue_O():
	var delta = (kn2O/(alpha_n2*vtiO)*(pp_N2_cO_t0-pp_N2_tiO_t0))*dt
	pp_N2_tiO_t1 = pp_N2_tiO_t0 + delta

func tissue_TGI():
	var delta = (kn2TGI/(alpha_n2*vtiTGI)*(pp_N2_cTGI_t0-pp_N2_tiTGI_t0))*dt
	pp_N2_tiTGI_t1 = pp_N2_tiTGI_t0 + delta

func tissue_F():
	var delta = (kn2F/(alpha_n2*vtiF)*(pp_N2_cF_t0-pp_N2_tiF_t0))*dt
	pp_N2_tiF_t1 = pp_N2_tiF_t0 + delta

func tissue_RDC():
	var delta = (kn2RDC/(alpha_n2*vtiRDC)*(pp_N2_cRDC_t0-pp_N2_tiRDC_t0))*dt
	pp_N2_tiRDC_t1 = pp_N2_tiRDC_t0 + delta

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

func save_data_to_file():
	#METTRE LE CHEMIN VOULU POUR L'EMPLACEMENT DU FICHIER DE DONNEES
	#CHANGER LE NOM DU FICHIER AU BOUT POUR CREER UN NOUVEAU FICHIER
	var file_path = "C:/Users/louis/OneDrive/Documents/Stage M2/model_data.txt"
	
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
	
	time = time + dt
	
		# Compute one step
	pressure_atm()
	air()
	airways()
	alveolar()
	alveolar_blood()
	arterial_blood()
	venous_blood()
	capilar_blood_CE()
	tissue_CE()
	#capilar_blood_ME()
	#tissue_ME()
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
	#pp_N2_tiME_t0 	= pp_N2_tiME_t1
	#pp_N2_cME_t0		= pp_N2_cME_t1
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
		k = 0

# ***********************
# Fonctions de simulation
# ***********************

# Paramètres de simulations
var play:bool = false

# Appelé à l'initialisation.
func _ready():
	debug_textbox = get_node("TabContainer/Simulation/Results")
	debug_textbox2 = get_node("TabContainer/Simulation/Results2")
	debug_textbox3 = get_node("TabContainer/Simulation/Results3")
	debug_textbox4 = get_node("TabContainer/Simulation/Results4")
	debug_textbox5 = get_node("TabContainer/Simulation/Results5")
	debug_textbox6 = get_node("TabContainer/Simulation/Results6")
	debug_textbox7 = get_node("TabContainer/Simulation/Results7")
	debug_textbox8 = get_node("TabContainer/Simulation/Results8")
	debug_textbox9 = get_node("TabContainer/Simulation/Results9")
	debug_textbox10 = get_node("TabContainer/Simulation/Results10")
	debug_textbox11 = get_node("TabContainer/Simulation/Results11")
	$RichTextLabel_N2.bbcode_enabled = true
	$RichTextLabel_N2.bbcode_text = "[center]Application to compute Partial Pressure of N2 in human body[/center]"

#Appelé toutes les frames. 'delta est le temps qui s'est écoulé depuis la dernière frame.
func _process(_delta):
	if play == true:
		step()

func _on_play_button_down():
	play = true
	set_text_editable(false)
	$TabContainer/Simulation/RichTextLabel_N13.visible = true
	$TabContainer/Simulation/RichTextLabel_N12.visible = true
	$TabContainer/Simulation/RichTextLabel_N11.visible = true
	$TabContainer/Simulation/RichTextLabel_N10.visible = true
	$TabContainer/Simulation/RichTextLabel_N9.visible = true
	$TabContainer/Simulation/RichTextLabel_N8.visible = true
	$TabContainer/Simulation/RichTextLabel_N7.visible = true
	$TabContainer/Simulation/RichTextLabel_N6.visible = true
	$TabContainer/Simulation/RichTextLabel_N5.visible = true
	$TabContainer/Simulation/RichTextLabel_N3.visible = true

func _on_pause_button_down():
	play = false

func _on_stop_pressed():
	play = false
	_reset_values()
	set_text_editable(true)
	$TabContainer/Simulation/RichTextLabel_N13.visible = false
	$TabContainer/Simulation/RichTextLabel_N12.visible = false
	$TabContainer/Simulation/RichTextLabel_N11.visible = false
	$TabContainer/Simulation/RichTextLabel_N10.visible = false
	$TabContainer/Simulation/RichTextLabel_N9.visible = false
	$TabContainer/Simulation/RichTextLabel_N8.visible = false
	$TabContainer/Simulation/RichTextLabel_N7.visible = false
	$TabContainer/Simulation/RichTextLabel_N6.visible = false
	$TabContainer/Simulation/RichTextLabel_N5.visible = false
	$TabContainer/Simulation/RichTextLabel_N3.visible = false
	
	
# Désactive ou active les champs de texte en fonction de l'état du booléen play
func set_text_editable(editable: bool):
	var text_edits = [
		"TabContainer/Paramètres/Paramètres/Control/TabProf1", "TabContainer/Paramètres/Paramètres/Control/TabProf2",
		"TabContainer/Paramètres/Paramètres/Control/TabProf3", "TabContainer/Paramètres/Paramètres/Control/TabProf4",
		"TabContainer/Paramètres/Paramètres/Control/TabProf5", "TabContainer/Paramètres/Paramètres/Control/TabProf6",
		"TabContainer/Paramètres/Paramètres/Control/TabProf7", "TabContainer/Paramètres/Paramètres/Control/TabProf8",
		"TabContainer/Paramètres/Paramètres/Control/TabProf9", "TabContainer/Paramètres/Paramètres/Control/TabProf10",
		"TabContainer/Paramètres/Paramètres/Control/TabTime1", "TabContainer/Paramètres/Paramètres/Control/TabTime2",
		"TabContainer/Paramètres/Paramètres/Control/TabTime3", "TabContainer/Paramètres/Paramètres/Control/TabTime4",
		"TabContainer/Paramètres/Paramètres/Control/TabTime5", "TabContainer/Paramètres/Paramètres/Control/TabTime6",
		"TabContainer/Paramètres/Paramètres/Control/TabTime7", "TabContainer/Paramètres/Paramètres/Control/TabTime8",
		"TabContainer/Paramètres/Paramètres/Control/TabTime9", "TabContainer/Paramètres/Paramètres/Control/TabTime10",
		"TabContainer/Paramètres/Paramètres/Control/Ventilatory", "TabContainer/Paramètres/Paramètres/Control/MeanExpiratoryReserveVolume",
		"TabContainer/Paramètres/Paramètres/Control/MeanFunctionalResidualVolume", "TabContainer/Paramètres/Paramètres/Control/AlveolarBloodVolume",
		"TabContainer/Paramètres/Paramètres/Control/CardiacOutput", "TabContainer/Paramètres/Paramètres/Control/ArterialBloodVolume",
		"TabContainer/Paramètres/Paramètres/Control/CapillaryBloodVolume", "TabContainer/Paramètres/Paramètres/Control/VenousBloodVolume",
		"TabContainer/Paramètres/Paramètres/Control/TissueVolume", "TabContainer/Paramètres/Paramètres/Control/PressionAtmospherique",
		"TabContainer/Paramètres/Paramètres/Control/Metabolism3", "TabContainer/Paramètres/Paramètres/Control/DeltaTime",
		"TabContainer/Paramètres/Paramètres/Control/VolumeTissueBrain", "TabContainer/Paramètres/Paramètres/Control/VolumeCapilarBrain",
		"TabContainer/Paramètres/Paramètres/Control/QBrain", "TabContainer/Paramètres/Paramètres/Control/VolumeTissueTA",
		"TabContainer/Paramètres/Paramètres/Control/VolumeCapilarTA", "TabContainer/Paramètres/Paramètres/Control/QTA",
		"TabContainer/Paramètres/Paramètres/Control/VolumeTissueMH", "TabContainer/Paramètres/Paramètres/Control/VolumeCapilarMH",
		"TabContainer/Paramètres/Paramètres/Control/QMH", "TabContainer/Paramètres/Paramètres/Control/VolumeTissueM",
		"TabContainer/Paramètres/Paramètres/Control/VolumeCapilarM", "TabContainer/Paramètres/Paramètres/Control/QM",
		"TabContainer/Paramètres/Paramètres/Control/VolumeTissueR", "TabContainer/Paramètres/Paramètres/Control/VolumeCapilarR",
		"TabContainer/Paramètres/Paramètres/Control/QR", "TabContainer/Paramètres/Paramètres/Control/VolumeTissueO",
		"TabContainer/Paramètres/Paramètres/Control/VolumeCapilarO", "TabContainer/Paramètres/Paramètres/Control/QO",
		"TabContainer/Paramètres/Paramètres/Control/VolumeTissueTGI", "TabContainer/Paramètres/Paramètres/Control/VolumeCapilarTGI",
		"TabContainer/Paramètres/Paramètres/Control/QTGI", "TabContainer/Paramètres/Paramètres/Control/VolumeTissueF",
		"TabContainer/Paramètres/Paramètres/Control/VolumeCapilarF", "TabContainer/Paramètres/Paramètres/Control/QF",
		"TabContainer/Paramètres/Paramètres/Control/VolumeTissueRDC", "TabContainer/Paramètres/Paramètres/Control/VolumeCapilarRDC",
		"TabContainer/Paramètres/Paramètres/Control/QRDC"
	]

	for text_edit in text_edits:
		if has_node(text_edit):
			get_node(text_edit).editable = editable

# ***********************
# Fonction de reset quand stop est pressé
# ***********************
func _reset_values(): 
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
	#vtiME = 0.03
	#vcME = 0.006
	#mo2ME = 1.596
	#kn2ME = 0.00214
	#QME = 0.015
	#pp_N2_tiME_t0 = 150224.82
	#pp_N2_tiME_t1 = 0.0
	#pp_N2_cME_t0 = 150224.82
	#pp_N2_cME_t1 = 0.0
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
	fn2 = 0.79
	dt = 0.001
	t = [null,null,null,null,null,null,null,null,null,null]
	s = [null,null,null,null,null,null,null,null,null,null]
	
	# Vider les cases de l'interface utilisateur
	var text_edits = [
		"TabContainer/Paramètres/Paramètres/Control/TabProf1", "TabContainer/Paramètres/Paramètres/Control/TabProf2",
		"TabContainer/Paramètres/Paramètres/Control/TabProf3", "TabContainer/Paramètres/Paramètres/Control/TabProf4",
		"TabContainer/Paramètres/Paramètres/Control/TabProf5", "TabContainer/Paramètres/Paramètres/Control/TabProf6",
		"TabContainer/Paramètres/Paramètres/Control/TabProf7", "TabContainer/Paramètres/Paramètres/Control/TabProf8",
		"TabContainer/Paramètres/Paramètres/Control/TabProf9", "TabContainer/Paramètres/Paramètres/Control/TabProf10",
		"TabContainer/Paramètres/Paramètres/Control/TabTime1", "TabContainer/Paramètres/Paramètres/Control/TabTime2",
		"TabContainer/Paramètres/Paramètres/Control/TabTime3", "TabContainer/Paramètres/Paramètres/Control/TabTime4",
		"TabContainer/Paramètres/Paramètres/Control/TabTime5", "TabContainer/Paramètres/Paramètres/Control/TabTime6",
		"TabContainer/Paramètres/Paramètres/Control/TabTime7", "TabContainer/Paramètres/Paramètres/Control/TabTime8",
		"TabContainer/Paramètres/Paramètres/Control/TabTime9", "TabContainer/Paramètres/Paramètres/Control/TabTime10",
		"TabContainer/Paramètres/Paramètres/Control/Ventilatory", "TabContainer/Paramètres/Paramètres/Control/MeanExpiratoryReserveVolume",
		"TabContainer/Paramètres/Paramètres/Control/MeanFunctionalResidualVolume", "TabContainer/Paramètres/Paramètres/Control/AlveolarBloodVolume",
		"TabContainer/Paramètres/Paramètres/Control/CardiacOutput", "TabContainer/Paramètres/Paramètres/Control/ArterialBloodVolume",
		"TabContainer/Paramètres/Paramètres/Control/CapillaryBloodVolume", "TabContainer/Paramètres/Paramètres/Control/VenousBloodVolume",
		"TabContainer/Paramètres/Paramètres/Control/TissueVolume", "TabContainer/Paramètres/Paramètres/Control/PressionAtmospherique",
		"TabContainer/Paramètres/Paramètres/Control/Metabolism3", "TabContainer/Paramètres/Paramètres/Control/DeltaTime",
		"TabContainer/Paramètres/Paramètres/Control/VolumeTissueBrain", "TabContainer/Paramètres/Paramètres/Control/VolumeCapilarBrain",
		"TabContainer/Paramètres/Paramètres/Control/QBrain", "TabContainer/Paramètres/Paramètres/Control/VolumeTissueTA",
		"TabContainer/Paramètres/Paramètres/Control/VolumeCapilarTA", "TabContainer/Paramètres/Paramètres/Control/QTA",
		"TabContainer/Paramètres/Paramètres/Control/VolumeTissueMH", "TabContainer/Paramètres/Paramètres/Control/VolumeCapilarMH",
		"TabContainer/Paramètres/Paramètres/Control/QMH", "TabContainer/Paramètres/Paramètres/Control/VolumeTissueM",
		"TabContainer/Paramètres/Paramètres/Control/VolumeCapilarM", "TabContainer/Paramètres/Paramètres/Control/QM",
		"TabContainer/Paramètres/Paramètres/Control/VolumeTissueR", "TabContainer/Paramètres/Paramètres/Control/VolumeCapilarR",
		"TabContainer/Paramètres/Paramètres/Control/QR", "TabContainer/Paramètres/Paramètres/Control/VolumeTissueO",
		"TabContainer/Paramètres/Paramètres/Control/VolumeCapilarO", "TabContainer/Paramètres/Paramètres/Control/QO",
		"TabContainer/Paramètres/Paramètres/Control/VolumeTissueTGI", "TabContainer/Paramètres/Paramètres/Control/VolumeCapilarTGI",
		"TabContainer/Paramètres/Paramètres/Control/QTGI", "TabContainer/Paramètres/Paramètres/Control/VolumeTissueF",
		"TabContainer/Paramètres/Paramètres/Control/VolumeCapilarF", "TabContainer/Paramètres/Paramètres/Control/QF",
		"TabContainer/Paramètres/Paramètres/Control/VolumeTissueRDC", "TabContainer/Paramètres/Paramètres/Control/VolumeCapilarRDC",
		"TabContainer/Paramètres/Paramètres/Control/QRDC"
	]
	
	for text_edit in text_edits:
		if has_node(text_edit):
			get_node(text_edit).text = ""
	
	debug_textbox.text = ""  # Vide la zone de texte de débogage 1
	debug_textbox2.text = ""  # Vide la zone de texte de débogage 2
	debug_textbox3.text = ""  # Vide la zone de texte de débogage 3
	debug_textbox4.text = ""  # Vide la zone de texte de débogage 4
	debug_textbox5.text = ""  # Vide la zone de texte de débogage 5
	debug_textbox6.text = ""  # Vide la zone de texte de débogage 6
	debug_textbox7.text = ""  # Vide la zone de texte de débogage 7
	debug_textbox8.text = ""  # Vide la zone de texte de débogage 8
	debug_textbox9.text = ""  # Vide la zone de texte de débogage 9
	debug_textbox10.text = ""  # Vide la zone de texte de débogage 10
	debug_textbox11.text = ""  # Vide la zone de texte de débogage 11
	
	print("Valeurs remises à zéro !")
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
		fn2 = 0.79
	else:
		fn2 = float(new_text)
	print("Nouvelle valeur de fN₂: " +str(fn2))

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
		dt = 0.001
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
