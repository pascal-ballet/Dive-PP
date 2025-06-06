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
var K3:float =0.00267
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
	"pp_N2_a": null
}




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


	#
func venous_blood_mono():
	var delta =q/vv*(pp_N2_c_t0 - pp_N2_v_t0)*dt
	pp_N2_v_t1 = pp_N2_v_t0 + delta

var vc:float =0.5
var Q: float =4.2
var kn2 :float =0.0000619
var pp_N2_c_t0 : float = 75112.41
var pp_N2_ti_t0 :float = 0


func capilar_blood_mono():
	var delta = (1/(vc*alpha_n2)*(q*alpha_n2*pp_N2_a_t0-(alpha_n2*q+K3_N2_mono)*pp_N2_c_t0+K3_N2_mono*pp_N2_ti_t0))*dt
	#print("delta_cap_CE = ",delta)
	pp_N2_c_t1 = pp_N2_c_t0 + delta
	
## Compute the partial pressure of c methode euler



# methode euler



## Compute the partial pressure of ti
##methode euler
var Vt = 70
var K3_N2_mono=0.00267

func tissue_mono():
	var delta =(K3_N2_mono/(alpha_n2*Vt)*(pp_N2_c_t0-pp_N2_ti_t0))*dt
	pp_N2_ti_t1 = pp_N2_ti_t0 + delta
	



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
	
	var message3 = "Valeurs des t1/2 :" + str(temps_seuils) + "\n" 
	
	update_debug_textbox(message)

	update_debug_textbox3(message3)
	
	time = time + dt
	iteration = iteration + 1 
		# Compute one step
	pressure_atm()
	air()
	airways_rk4()
	alveolar_blood_rk4()
	alveolar_blood_rk4()
	
	verifier_et_stocker_temps_seuil()
	
		# Preparer le prochain step
	pp_N2_aw_t0 	= pp_N2_aw_t1
	pp_N2_alv_t0	= pp_N2_alv_t1
	pp_N2_alb_t0	 = pp_N2_alb_t1
	pp_N2_a_t0		= pp_N2_a_t1
	pp_N2_v_t0		= pp_N2_v_t1
	
		# Variables tissus
	
	
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
	
	
		# Preparer le prochain step
	pp_N2_aw_t0 	= pp_N2_aw_t1
	pp_N2_alv_t0	= pp_N2_alv_t1
	pp_N2_alb_t0	 = pp_N2_alb_t1
	pp_N2_a_t0		= pp_N2_a_t1
	pp_N2_v_t0		= pp_N2_v_t1
	
		# Variables tissus
	
	
	
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
func _ready():
	debug_textbox = get_node("TabContainer/Valeur/Results")
	debug_textbox2 = get_node("TabContainer/Valeur/Results2")
	debug_textbox3 = get_node("TabContainer/Valeur/Results3")
	debug_textbox4 = get_node("TabContainer/Valeur/Results4")
	debug_textbox5 = get_node("TabContainer/Valeur/Results5")
	debug_textbox6 = get_node("TabContainer/Valeur/Results6")
	debug_textbox7 = get_node("TabContainer/Valeur/Results7")
	debug_textbox8 = get_node("TabContainer/Valeur/Results8")
	debug_textbox9 = get_node("TabContainer/Valeur/Results9")
	debug_textbox10 = get_node("TabContainer/Valeur/Results10")
	debug_textbox11 = get_node("TabContainer/Valeur/Results11")
	debug_textbox12 = get_node("TabContainer/Valeur/Results12")
	#$RichTextLabel_N2.bbcode_enabled = true
	#$RichTextLabel_N2.bbcode_text = "[center]Application to compute Partial Pressure of N2 in human body[/center]"

#Appelé toutes les frames. 'delta est le temps qui s'est écoulé depuis la dernière frame.
func _process(_delta):
	if play == true:
		step()

func _on_play_button_down():
	play = true
	set_text_editable(false)
	$TabContainer/Valeur/RichTextLabel_N14.visible = true
	$TabContainer/Valeur/RichTextLabel_N13.visible = true
	$TabContainer/Valeur/RichTextLabel_N12.visible = true
	$TabContainer/Valeur/RichTextLabel_N11.visible = true
	$TabContainer/Valeur/RichTextLabel_N10.visible = true
	$TabContainer/Valeur/RichTextLabel_N9.visible = true
	$TabContainer/Valeur/RichTextLabel_N8.visible = true
	$TabContainer/Valeur/RichTextLabel_N7.visible = true
	$TabContainer/Valeur/RichTextLabel_N6.visible = true
	$TabContainer/Valeur/RichTextLabel_N5.visible = true
	$TabContainer/Valeur/RichTextLabel_N4.visible = true
	$TabContainer/Valeur/RichTextLabel_N3.visible = true

func _on_pause_button_down():
	play = false

func _on_stop_pressed():
	play = false
	_reset_values()
	set_text_editable(true)
	$TabContainer/Valeur/RichTextLabel_N14.visible = false
	$TabContainer/Valeur/RichTextLabel_N13.visible = false
	$TabContainer/Valeur/RichTextLabel_N12.visible = false
	$TabContainer/Valeur/RichTextLabel_N11.visible = false
	$TabContainer/Valeur/RichTextLabel_N10.visible = false
	$TabContainer/Valeur/RichTextLabel_N9.visible = false
	$TabContainer/Valeur/RichTextLabel_N8.visible = false
	$TabContainer/Valeur/RichTextLabel_N7.visible = false
	$TabContainer/Valeur/RichTextLabel_N6.visible = false
	$TabContainer/Valeur/RichTextLabel_N5.visible = false
	$TabContainer/Valeur/RichTextLabel_N4.visible = false
	$TabContainer/Valeur/RichTextLabel_N3.visible = false
	
	
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
# Fonctions de Graph
# ***********************
var my_plotti : PlotItem = null
var swapti: bool = true
#play
func _on_add_Play_pressed() -> void:

	_on_add_plot_pressedti()








func _on_add_plot_pressedti() -> void:
	_reset_mono()
	# Créer un nouveau plot avec un label unique et une couleur dynamique
	my_plotti = $TabContainer/Graph/Graph2D.add_plot_item(  
			"Plot %d" % [$TabContainer/Graph/Graph2D.count()],
			[Color(randf(), randf(), randf())][$TabContainer/Graph/Graph2D.count() % 1],
			[1.0, 1.0, 1.0].pick_random()
			)
	#print("press add 1 tissue !")
	
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
			swapti=false
		else:
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotti, Color(randf(), randf(), randf()))	
			swapti=true



func _on_add_plot_sobol_A() -> void:
	Vt=ax1[totoA] 
	vc= ax2[totoA] 
	valg = ax3[totoA]
	valb = ax4[totoA] 
	va = ax5[totoA] 
	vv= ax6[totoA] 
	vaw =ax7[totoA] 
	q = ax8[totoA] 
	K1 = ax9[totoA] 
	K2 = ax10[totoA] 
	K3 = ax11[totoA]
	_reset_mono()
	# Créer un nouveau plot avec un label unique et une couleur dynamique
	my_plotti = $TabContainer/Graph/Graph2D.add_plot_item(  
			"Plot %d" % [$TabContainer/Graph/Graph2D.count()],
			[Color(randf(), randf(), randf())][$TabContainer/Graph/Graph2D.count() % 1],
			[1.0, 1.0, 1.0].pick_random()
			)
	#print("press add 1 tissue !")
	
	var x: float = 0.0  # Initialize the x value
	var y: float = 0.0  # Initialize the y value
	
	while time <60:
		step_mono()#met a jour lest valeur
		if iteration % 500 == 0: #recupere 1 valeur toute les 500 
			x = time  # Increment x 
			y = pp_N2_ti_t0  # increment  y 
			# Add the point (x, y) to the plot
			my_plotti.add_point(Vector2(x, y))
		#_reset_valuesCourbe()
	print("Plot updated with points!")
	totoA+= 1
	
	
func _on_add_plot_sobol_B() -> void:
	Vt=bx1[totoB] 
	vc= bx2[totoB] 
	valg = bx3[totoB]
	valb = bx4[totoB] 
	va = bx5[totoB] 
	vv= bx6[totoB] 
	vaw =bx7[totoB] 
	q = bx8[totoB] 
	K1 = bx9[totoB] 
	K2 = bx10[totoB] 
	K3 = bx11[totoB]
	_reset_mono()
	# Créer un nouveau plot avec un label unique et une couleur dynamique
	my_plotti = $TabContainer/Graph/Graph2D.add_plot_item(  
			"Plot %d" % [$TabContainer/Graph/Graph2D.count()],
			[Color(randf(), randf(), randf())][$TabContainer/Graph/Graph2D.count() % 1],
			[1.0, 1.0, 1.0].pick_random()
			)
	#print("press add 1 tissue !")
	
	var x: float = 0.0  # Initialize the x value
	var y: float = 0.0  # Initialize the y value
	
	while time <60:
		step_mono()#met a jour lest valeur
		if iteration % 500 == 0: #recupere 1 valeur toute les 500 
			x = time  # Increment x 
			y = pp_N2_ti_t0  # increment  y 
			# Add the point (x, y) to the plot
			my_plotti.add_point(Vector2(x, y))
		#_reset_valuesCourbe()
	print("Plot updated with points!")
	totoB+= 1

func _swapsobol() -> void:
	if my_plotti :
		if swapti :
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotti, Color.TRANSPARENT)
			swapti=false
		else:
			$TabContainer/Graph/Graph2D.change_plot_color(my_plotti, Color(randf(), randf(), randf()))	
			swapti=true



func _on_remove_all_plots_pressed() -> void:
	$TabContainer/Graph/Graph2D.remove_all()
	print("press remove !")
	
	
	


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
	dt = dtINI
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
	debug_textbox12.text = ""  # Vide la zone de texte de débogage 12
	
	print("Valeurs remises à zéro !")
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
		dt = dtINI
	else:
		dt = float(new_text)
	print("Nouvelle valeur de dt: " +str(dt))
	


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
#var N = 100 # Nombre d'échantillons Monte Carlo (generalement 100 000)
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
var ax12 : Array[float] = []; var bx12 : Array[float] = []
var N : int = 10
var start_time:int=0
var end_time:int=0
var histo:Array = []
var compteur:int = 0

func _ready_s() -> void:
	while compteur<5:
		for i in range(101):
			histo.append(0)
		start_time = Time.get_ticks_msec()
		#print("Sobol Analysis start at " + str(Time.get_ticks_msec() )+"in ms" )
		print("Sobol Analysis start at " + str(start_time)+"in ms" )

		var panel := get_node("TabContainer/Graph/Control/ResultBox")
		#panel.visible = !panel.visible
		#var d := 3                               # nombre de variables
		#var N := 5                         # taille d’échantillon
		var rng := RandomNumberGenerator.new()
		
		rng.randomize()   # graine aléatoire basée sur l’horloge
		#rng.seed = 1                             # reproductibilité

		# ─────────────────────────────────────────────────────────────
		# 1) Génération des échantillons  A  et  B  (séparés par variable)
		# ─────────────────────────────────────────────────────────────
		#var ax1 : Array[float] = [];  var bx1 : Array[float] = []
		#var ax2 : Array[float] = [];  var bx2 : Array[float] = []
		#var ax3 : Array[float] = [];  var bx3 : Array[float] = []
		#var ax4 : Array[float] = []; var bx4 : Array[float] = []
		#var ax5 : Array[float] = []; var bx5 : Array[float] = []
		#var ax6 : Array[float] = []; var bx6 : Array[float] = []
		#var ax7 : Array[float] = []; var bx7 : Array[float] = []
		#var ax8 : Array[float] = []; var bx8 : Array[float] = []
		#var ax9 : Array[float] = []; var bx9 : Array[float] = []
		#var ax10 : Array[float] = []; var bx10 : Array[float] = []
		#var ax11 : Array[float] = []; var bx11 : Array[float] = []
		
		ax1.resize(N); ax2.resize(N); ax3.resize(N); ax4.resize(N); ax5.resize(N); ax6.resize(N); ax7.resize(N); ax8.resize(N); ax9.resize(N); ax10.resize(N); ax11.resize(N); ax12.resize(N)
		bx1.resize(N); bx2.resize(N); bx3.resize(N); bx4.resize(N); bx5.resize(N); bx6.resize(N); bx7.resize(N); bx8.resize(N); bx9.resize(N); bx10.resize(N); bx11.resize(N); bx12.resize(N)
		
		print("Array creation at " + str(Time.get_ticks_msec() ) )


		for l in range(N):#variation de 20%
			ax1[l] = Vt + rng.randf_range(-14, 14);   bx1[l] = Vt + rng.randf_range(-14, 14)#vt
			ax2[l] = vc + rng.randf_range(-0.10, 0.1); bx2[l] = vc + rng.randf_range(-0.1, 0.1)#vc
			ax3[l] = valg + rng.randf_range(-0.2, 0.2);   bx3[l] = valg + rng.randf_range(-0.2, 0.2)#valg
			ax4[l] = valb + rng.randf_range(-0.1, 0.1);    bx4[l] = valb + rng.randf_range(-0.1, 0.1)#valb
			ax5[l] = va + rng.randf_range(-0.34, 0.34);    bx5[l] = va + rng.randf_range(-0.34, 0.34)#va
			ax6[l] = vv + rng.randf_range(-0.6, 0.6);    bx6[l] = vv + rng.randf_range(-0.6, 0.6)#vv
			ax7[l] = vaw + rng.randf_range(-0.30, 0.30);    bx7[l] = vaw + rng.randf_range(-0.30, 0.30)#vaw
			ax8[l] = q + rng.randf_range(-0.8, 0.8);    bx8[l] = q + rng.randf_range(-0.8, 0.8)#q
			ax9[l] = K1 + rng.randf_range(-0.000267*2, 0.000267*2);    bx9[l] = K1 + rng.randf_range(-0.000267*2, 0.000267*2)#k1
			ax10[l] = K2 + rng.randf_range(-0.000748*2, 0.000748*2);    bx10[l] = K2 + rng.randf_range(-0.000748*2, 0.000748*2)#k2
			ax11[l] = K3 + rng.randf_range(-0.000267*2, 0.000267*2);    bx11[l] = K3 + rng.randf_range(-0.000267*2, 0.000267*2)#k3
			ax12[l] = vent + rng.randf_range(-0.81*2, 0.81*2);   bx12[l] = vent + rng.randf_range(-0.81*2, 0.81*2)#vt
			#_on_add_plot_sobol_A()
			#_on_add_plot_sobol_B()
		print("1 - " + str(Time.get_ticks_msec() ) )
		totoA=0
		totoB=0
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
			#print ("l="+str(l))
			toto = l
			YA[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l])
			
			if YA[l]>= 10 and YA[l]<=20:
				var p:int = int(((YA[l]-10)*10))
				histo[p]+=1
				
			YB[l] = mon_model(bx1[l], bx2[l], bx3[l], bx4[l], bx5[l], bx6[l], bx7[l], bx8[l], bx9[l], bx10[l], bx11[l], bx12[l])
			if YA[l]>= 10 and YA[l]<=20:
				var p:int = int(((YA[l]-10)*10))
				histo[p]+=1
				

		print("3 - " + str(Time.get_ticks_msec() ) )

		# ─────────────────────────────────────────────────────────────
		## 3) Matrices mixtes  A_Bi  (pick & freeze) 
		#La méthode vise à évaluer l'influence de chaque variable d’entrée sur la sortie du modèle, en ne changeant qu’une variable à la fois (on la "pick") tandis que les autres restent fixes (on les "freeze").
		# ─────────────────────────────────────────────────────────────
		var YAB0 : Array[float] = [];  var YAB1 : Array[float] = [];  var YAB2 : Array[float] = []; var YAB3 : Array[float] = [];var YAB4 : Array[float] = []; var YAB5 : Array[float] = []; var YAB6 : Array[float] = []; var YAB7 : Array[float] = []; var YAB8 : Array[float] = []; var YAB9 : Array[float] = []; var YAB10 : Array[float] = []; var YAB11 : Array[float] = []
		YAB0.resize(N);    YAB1.resize(N);    YAB2.resize(N)	;YAB3.resize(N);	YAB4.resize(N);	YAB5.resize(N);	YAB6.resize(N);	YAB7.resize(N);	YAB8.resize(N);	YAB9.resize(N);	YAB10.resize(N);	YAB11.resize(N)
		print("4 - " + str(Time.get_ticks_msec() ) )


		for l in range(N):
			## i = 0 : on prend x1 de B, les autres de A
			#YAB0[l] = mon_model(bx1[l], ax2[l], ax3[l])
			## i = 1 : on prend x2 de B, les autres de A
			#YAB1[l] = mon_model(ax1[l], bx2[l], ax3[l])
			## i = 2 : on prend x3 de B, les autres de A
			#YAB2[l] = mon_model(ax1[l], ax2[l], bx3[l])
			YAB0[l] = mon_model(bx1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l])
			YAB1[l] = mon_model(ax1[l], bx2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l])
			YAB2[l] = mon_model(ax1[l], ax2[l], bx3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l])
			YAB3[l] = mon_model(ax1[l], ax2[l], ax3[l], bx4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l])
			YAB4[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], bx5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l])
			YAB5[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], bx6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l])
			YAB6[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], bx7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l])
			YAB7[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], bx8[l], ax9[l], ax10[l], ax11[l], ax12[l])
			YAB8[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], bx9[l], ax10[l], ax11[l], ax12[l])
			YAB9[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], bx10[l], ax11[l], ax12[l])
			YAB10[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], bx11[l], ax12[l])
			YAB11[l] = mon_model(ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], bx12[l])
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
		var S : Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
		var ST : Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

		var acc_S0 := 0.0; var acc_S1 := 0.0; var acc_S2 := 0.0; var acc_S3 := 0.0; var acc_S4 := 0.0; var acc_S5 := 0.0; var acc_S6 := 0.0; var acc_S7 := 0.0; var acc_S8 := 0.0; var acc_S9 := 0.0; var acc_S10 := 0.0; var acc_S11 := 0.0
		var acc_ST0 := 0.0; var acc_ST1 := 0.0; var acc_ST2 := 0.0; var acc_ST3 := 0.0; var acc_ST4 := 0.0; var acc_ST5 := 0.0; var acc_ST6 := 0.0; var acc_ST7 := 0.0; var acc_ST8 := 0.0; var acc_ST9 := 0.0; var acc_ST10 := 0.0; var acc_ST11 := 0.0

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
			acc_S11  += YB[l] * (YAB11[l] - YA[l])


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
			var d11 := YA[l] - YAB11[l];  acc_ST11 += d11 * d11

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
		S [11] = acc_S11  / N / VY;     ST[11] = 0.5 * acc_ST11 / N / VY
		end_time = Time.get_ticks_msec()
		#print("Sobol Analysis end   at " + str(Time.get_ticks_msec() )+"in ms" )
		print("Sobol Analysis end   at " + str(end_time)+"in ms" )
		var duration_ms = end_time - start_time
		var total_seconds = int(duration_ms / 1000)
		var hours = int(total_seconds / 3600)
		var minutes = int((total_seconds % 3600) / 60)
		var seconds = int(total_seconds % 60)

		print("Sobol Analysis duration: %02dh %02dmin %02ds" % [hours, minutes, seconds])

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
		display_text += "Volume du capillaire (x₂)        :   %.4f      |   %.4f\n" % [S[1], ST[1]]
		display_text += "Volume alveolar gaz (x₃)   :   %.4f            |   %.4f\n" % [S[2], ST[2]]
		display_text += "Volume alveolar blood (x4)   :   %.4f          |   %.4f\n" % [S[3], ST[3]]
		display_text += "Volume arterial blood  (x5)   :   %.4f         |   %.4f\n" % [S[4], ST[4]]
		display_text += "Volume veinous blood (x6)   :   %.4f           |   %.4f\n" % [S[5], ST[5]]
		display_text += "Volume airways (x7)   :   %.4f                 |   %.4f\n" % [S[6], ST[6]]
		display_text += "Q (x8)   :   %.4f                              |   %.4f\n" % [S[7], ST[7]]
		display_text += "K1 (x9)   :   %.4f                             |   %.4f\n" % [S[8], ST[8]]
		display_text += "K2 (x10)   :   %.4f                            |   %.4f\n" % [S[9], ST[9]]
		display_text += "K3 (11)   :   %.4f                             |   %.4f\n" % [S[10], ST[10]]
		display_text += "vent (12)   :   %.4f                          |   %.4f\n" % [S[11], ST[11]]
		print(histo)
		creer_dossier_si_absent(save_folder)
		var chemin = get_chemin_fichier(compteur)
		
		sauvegarder_resultats_json(chemin, histo)
		histo=[]
		compteur+=1
		# Affiche le texte dans le RichTextLabel
		await get_tree().process_frame  
		get_node("TabContainer/Graph/Control/ResultBox/SobolResults").text = display_text
		await get_tree().process_frame  #
		capture_screenshot()
		#get_tree().quit()  # ferme l’application Godot
	#Sᵢ : Indice de Sobol de premier ordre
	#Part de la variance de la sortie due uniquement à la variable xᵢ prise seule.

	#Sₜᵢ : Indice de Sobol total
	#Part de la variance due à xᵢ et à toutes ses interactions avec les autres variables.
###################################################################################################	
	##capture d'ecran des resultat
var screenshot_count = 0
var save_folder = "C:/Users/Bio/Documents/sobol_result/echantillon_"+str(N)+"/"# chemin a changer 
func capture_screenshot():
	var filename = save_folder + "sobol_analyse" + str(screenshot_count) + ".png"#non de l'image a changer
	screenshot_count += 1
	var img = get_viewport().get_texture().get_image()
	#img.flip_y()
	var err = img.save_png(filename)
	if err == OK:
		print("Capture d'écran sauvegardée dans ", filename)
	else:
		print("Erreur lors de la sauvegarde de la capture d'écran")
################################################################################################
func sauvegarder_resultats_json(chemin_complet: String, donnees: Array) -> void:
	var file = FileAccess.open(chemin_complet, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(donnees, "\t"))  # "\t" = indentation par tabulation
		file.close()
	else:
		push_error("Erreur : Impossible d’ouvrir le fichier : " + chemin_complet)
func get_chemin_fichier(index: int) -> String:
	return save_folder + "histo" + str(index) + ".json"	
	##########################################################################################
	
func creer_dossier_si_absent(chemin: String) -> void:
	var dir = DirAccess.open("C:/")
	if not DirAccess.dir_exists_absolute(chemin):
		dir.make_dir_recursive(chemin)
	
	
	
	
	
	############################################################################################
# ────────────────────────────────────────────────────────────────────
# Fonctions utilitaires
# ────────────────────────────────────────────────────────────────────
var toto: int =0
var totoA: int =0
var totoB: int =0
func mon_model(Vt_: float, vc_: float, valg_: float,valb_: float,va_: float,vv_: float, vaw_: float, q_:float,K1_:float,K2_:float,K3_:float,vent_:float ) -> float: #1 tissue
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
	vent=vent_
	#var K3: float=0.00267
	var alpha_n2 :float=0.000061
	#step_mono()
	#_on_add_plot_sobol()
	sobol_step()
	#print (str(time))
	#print (str(pp_N2_ti_t0))
	
	return time
	#return (K3/(alpha_n2*Vt)*(pp_N2_c_t0-pp_N2_ti_t0))#tissue
	#return (1/(vc*alpha_n2)*(q*alpha_n2*pp_N2_a_t0-(alpha_n2*q+K3_N2_mono)*pp_N2_c_t0+K3_N2_mono*pp_N2_ti_t0))#capilaire
	
	#x1 + x2/10.0 + x3/2
	#return sin(x1) + 7.0 * pow(sin(x2), 2) + 0.1 * pow(x3, 4) * sin(x1)
	
	## fonction step pour 1 seul tissue
func sobol_step() :
	#if toto < 100:
		#print ("init="+str(pp_N2_ti_t0))
	var half_pressure : float = 75112.41 *1.5 #TODO a changer par (pression init + pression final)/2 
	while pp_N2_ti_t0 < half_pressure:
		step_mono()
			#if toto ==1579:# and time>= 4.3 and time<6:
				#print ("time =" + str(time))
				#print (pp_N2_ti_t0)
		#print ("end ="+str(pp_N2_ti_t0))
#

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
	
	#vent = 8.1 # debit ventilatoire 
	#vaw = 1.5 #volume des voix aérienne
	#valg = 1.0 # volume du gaz alvéolaire
	#valb = 0.5 # volume de sang alvéolaire
	#q= 4.209 # debit cardiaque
	#va = 1.7 #volume artériel
	#vv = 3.0 #volume veineux
	patm = 101325.0 # presion ambiante
	fn2 = 0.79 #fraction d azote dans le gaz respiré 
	
	alpha_n2 = 0.0000619 #coef solubilite azote
	ph2o = 6246.0 # presstion partiel de vapeur d eau
	#K1 = 0.00267 # coef de difusion respiratoire
	#K2 = 0.00748 # coef de difusion alveolo capilaire
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
	
	#K3 = 0.000267
	#Vt = 70
	#vc = 0.5


#l=1579 l=1845 l=1853 l=1863 l=1947 l=2077 l=2278 l=2287 l=2314 l=2890
