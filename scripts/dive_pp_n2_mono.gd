extends Control


# T1/2 => 18 min (avant)
# aujourd'hui => 40 à 60 min

# ***********************
# Variables modifiables
# ***********************

var vent: 	float = 8.1 # debit ventilatoire 
var Vaw: 	float = 1.5 #volume des voix aérienne
var Valg: 	float = 1.0 # volume du gaz alvéolaire
var Valb: 	float = 0.5 # volume de sang alvéolaire
var Q: 		float = 4.209 # debit cardiaque
var Va: 	float = 1.7 #volume artériel
var Vv: 	float = 3.0 #volume veineux
var patm: 	float = 101325.0 # presion ambiante
var fn2: 	float = 0.79 #fraction d azote dans le gaz respiré
var diving_time = [1, null,null,null,null,null,null,null,null,null]
var diving_deep = [10,null,null,null,null,null,null,null,null,null]

######################################################################################################################################
# LISTE DES VARIABLES QU'ON VEUT POUVOIR MODIFIER ? Q et volume pour chaque + dt
# DESCENDRE RAPIDEMENT
######################################################################################################################################

# ***********************
# Paramètres du modèle
# ***********************

const alpha_n2:float= 0.0000619 #coef solubilite azote
const ph2o:float 	= 6246.0 # presstion partiel de vapeur d eau
var K1:float 		= 0.00267 # coef de difusion respiratoire
var K2:float 		= 0.00748 # coef de difusion alveolo capilaire
var K3:float 		= 0.00267
const R:float 		= 8.314 # constante des gaz parfait
const T:float 		= 310.0 # Temperature en K
var tmp_t:float 	= 0.0
var tmp_s:float 	= 0.0
var time:float 		= 0.0
var dtINI:float 	= 0.0009  #variable global de dt permet de changer tout les dt "0.0002 euler" "0.0004 rk4""0.0009 rk6" "RK8 0.0009"
var dt:float 		= dtINI
var diving_stage:int= 1  #iterateur pour le calcule du profil de plongé
var iteration:int 	= 0 # pas de simulation en cours
var Vc:float 		= 0.5# colume capilaire
var Vt:float		= 70 # Tissue Volume
const kn2 :float 		= 0.0000619# coef solubiliter azote

# Pressions partielles
var pp_N2_c_t0 : float 	= 75112.41 # pression partiel initiale capilaire
var pp_N2_c_t1 : float	= 0 #pression partiel courante capilaire
var pp_N2_ti_t0: float 	= 75112.41 # pression partiel initiale tissus
var pp_N2_ti_t1: float 	= 0 # pression partiel courante tissus

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
#       MODELE
# ***********************
#region Model
#profil de plonge
func pressure_atm():
	if(diving_time[0] != null && diving_deep[0] != null):
		if(time <= diving_time[0] + dt):
			var r1 = diving_time[0] / dt
			var r2 = diving_deep[0] / r1
			patm = patm + r2 * 10100
			tmp_t = diving_time[0]
			tmp_s = diving_deep[0]
	while (diving_stage < diving_time.size() && (diving_time[diving_stage] == null || diving_deep[diving_stage] == null)): diving_stage += 1 
	if (diving_stage < diving_time.size() && diving_time[diving_stage] != null && diving_deep[diving_stage] != null):
		if (time > tmp_t && time <= diving_time[diving_stage] + dt):
			var r1 = (diving_time[diving_stage] - tmp_t) / dt
			var r2 = (diving_deep[diving_stage] - tmp_s) / r1
			patm = patm + r2 * 10100
	if(diving_stage < diving_time.size() && time > diving_time[diving_stage]):
		tmp_t = diving_time[diving_stage]
		tmp_s = diving_deep[diving_stage]
		diving_stage = diving_stage + 1

## Compute the partial pressure of air
func air():
	pp_N2_air = (patm-ph2o)*fn2
	
	
## Compute the partial pressure of aw
#methode euler
func airways():
	var delta = ((vent/Vaw*pp_N2_air)-(vent+K1*R*T)/Vaw*pp_N2_aw_t0+(K1*R*T)/Vaw*pp_N2_alv_t0)*dt
	pp_N2_aw_t1 = pp_N2_aw_t0 + delta

#methode runge kutta 4

# Fonction dérivée définie globalement
func f_airways(pp_N2_aw):
	return ((vent / Vaw * pp_N2_air) - (vent + K1 * R * T) / Vaw * pp_N2_aw + (K1 * R * T) / Vaw * pp_N2_alv_t0)

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
	var delta = (-R*T/Valg*(K1+K2)*pp_N2_alv_t0+R*T/Valg*(K1*pp_N2_aw_t0+K2*pp_N2_alb_t0))*dt
	pp_N2_alv_t1 = pp_N2_alv_t0 + delta
	
#methode runge kutta 4
# Fonction dérivée définie globalement
func f_alveolar(pp_N2_alv):
	return (-R * T / Valg * (K1 + K2) * pp_N2_alv + R * T / Valg * (K1 * pp_N2_aw_t0 + K2 * pp_N2_alb_t0))

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
	var delta = (1/(Valb*alpha_n2)*(K2*pp_N2_alv_t0-pp_N2_alb_t0*(K2+alpha_n2*Q)+alpha_n2*Q*pp_N2_v_t0))*dt
	pp_N2_alb_t1 = pp_N2_alb_t0 + delta

##methode tunge kutta 4
# Fonction dérivée définie globalement
func f_alveolar_blood(pp_N2_alb):
		return (1 / (Valb * alpha_n2) * (K2 * pp_N2_alv_t0 - pp_N2_alb * (K2 + alpha_n2 * Q) + alpha_n2 * Q * pp_N2_v_t0))

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
	var delta = (Q/Va*(pp_N2_alb_t0-pp_N2_a_t0))*dt
	pp_N2_a_t1 = pp_N2_a_t0 + delta
	
##methode runge kutta 4

# Fonction dérivée définie globalement
func f_arterial_blood(pp_N2_a):
		return (Q / Va * (pp_N2_alb_t0 - pp_N2_a))

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
	var delta =Q/Vv*(pp_N2_c_t0 - pp_N2_v_t0)*dt
	pp_N2_v_t1 = pp_N2_v_t0 + delta




func capilar_blood_mono():
	var delta = (1/(Vc*alpha_n2)*(Q*alpha_n2*pp_N2_a_t0-(alpha_n2*Q+K3)*pp_N2_c_t0+K3*pp_N2_ti_t0))*dt
	#print("delta_cap_CE = ",delta)
	pp_N2_c_t1 = pp_N2_c_t0 + delta
	
## Compute the partial pressure of c methode euler



# methode euler



## Compute the partial pressure of ti
##methode euler

func tissue_mono():
	var delta =(K3/(alpha_n2*Vt)*(pp_N2_c_t0-pp_N2_ti_t0))*dt
	pp_N2_ti_t1 = pp_N2_ti_t0 + delta
	

#endregion

# ****************************
#     SIMULATIONS DU MODEL
# ****************************
#region Simulations

# Diagram
var my_plot : PlotItem = null
	
func single_simu(params:Array) -> float:
	
	reset_parameters_total()
	
	Vt 		= params[0] 
	Vc 		= params[1] 
	Valg 	= params[2]
	Valb 	= params[3] 
	Va 		= params[4] 
	Vv 		= params[5] 
	Vaw 	= params[6] 
	Q 		= params[7] 
	K1 		= params[8] 
	K2 		= params[9] 
	K3 		= params[10]
	vent	= params[11]

	# Parametres stables mais a re-initialiser
	#_reset_mono()

	#if graph_mode == GraphMode.SATURATION:
		# Créer un nouveau plot avec un label unique et une couleur dynamique
		# var grey:int = int(randf()*0.5 + 0.5)
		# my_plot = %Graph2D.add_plot_item(  
		# 		"Plot %d" % [%Graph2D.count()],
		# 		[Color(grey, grey, grey)][%Graph2D.count() % 1],
		# 		[1.0, 1.0, 1.0].pick_random()
		# 		)
	
	# var x: float = 0.0  # Initialize the x value
	# var y: float = 0.0  # Initialize the y value
	
	var duration:float  = 120
	var max_points:float = duration / dt
	var time_dist:int = int(floor(max_points / 1360.0))
	var half_pressure : float = 75112.41 * 1.5 #TODO a changer par (pression init + pression final)/2

	var stop_criteria:bool = false

	while stop_criteria == false: #pp_N2_ti_t0 < half_pressure:
		one_step_mono() # Simulation of one step
		if graph_mode == GraphMode.SATURATION:
			if iteration % time_dist == 0: #recupere 1 valeur toute les time_dist 
				sat_curve.append(Vector2(time,pp_N2_ti_t0))
			if time >= duration:
				stop_criteria = true

		if graph_mode == GraphMode.HISTOGRAM:
			if pp_N2_ti_t0 >= half_pressure:
				stop_criteria = true

	# Record the result into the Histogramm
	if graph_mode == GraphMode.HISTOGRAM:
		var div = %Div.value
		# if time >= 10 and time <= 20:
		var p:int = int(floor(time*div/duration))
		histo_curve[p]+=1
		if histo_curve[p] > histo_max:
			histo_max = histo_curve[p]


	return time


## fonction step pour 1 seul tissue
func one_simulation_with_sobol() :
	display_parameters()
	#if toto < 100:
		#print ("init="+str(pp_N2_ti_t0))
	var half_pressure : float = 75112.41 * 1.5 #TODO a changer par (pression init + pression final)/2 
	while pp_N2_ti_t0 < half_pressure:
		one_step_mono()
#

func one_step_mono() :
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
	
#endregion

# ****************************
#     Reset des parametres
# ****************************
#region ResetParameters

func reset_parameters_total():
	time = 0.0

	#### ex reset_mono()
	diving_stage = 1
	iteration = 0
		
	pp_N2_ti_t0 = 75112.41
	pp_N2_ti_t1 = 0.0
	
	pp_N2_c_t0 = 75112.41
	pp_N2_c_t1 = 0.0

	####


	#### ex reset_parameters()
	fn2 = 0.79 #fraction d azote dans le gaz respiré 

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

	dt = dtINI
	####

	#### ex reset_values_when_Sobol()
	# Parametres Morphologiques
	Vt 			= %Vt.value
	Vc 			= %Vc.value
	Valg 		= %Valg.value
	Valb 		= %Valb.value
	Va 			= %Va.value
	Vv 			= %Vv.value
	Vaw 		= %Vaw.value
	# Parametres Physiologiques
	Q 			= %Q.value
	K1 			= %K1.value # coef de diffusion respiratoire
	K2 			= %K2.value # coef de diffusion alveolo capilaire
	K3 			= %K3.value
	vent 		= %Vent.value

	patm 		= 101325.0
	diving_time = [1,null,null,null,null,null,null,null,null,null]
	diving_deep = [10,null,null,null,null,null,null,null,null,null]
	####


# Fonction de reset quand stop est pressé
# func reset_values_when_Sobol(): 
# 	reset_parameters()	
# 	vent = 8.1
# 	Vaw = 1.5
# 	Valg = 1.0
# 	Valb = 0.5
# 	Q = 4.2
# 	Va = 1.7
# 	Vv = 3.0
# 	patm = 101325.0
# 	diving_time = [1,null,null,null,null,null,null,null,null,null]
# 	diving_deep = [10,null,null,null,null,null,null,null,null,null]
# 	Vt = %Vt.value
# 	Vc = 0.5
# 	K1 = 0.00267 # coef de diffusion respiratoire
# 	K2 = 0.00748 # coef de diffusion alveolo capilaire
# 	K3 =0.00267
	

# func _reset_mono():
# 	reset_parameters()

# 	diving_stage = 1
# 	iteration = 0
		
# 	pp_N2_ti_t0 = 75112.41
# 	pp_N2_ti_t1 = 0.0
	
# 	pp_N2_c_t0 = 75112.41
# 	pp_N2_c_t1 = 0.0


# func reset_parameters():
# 	time = 0.0

# 	fn2 = 0.79 #fraction d azote dans le gaz respiré 

# 	patm = 101325.0

# 	pp_N2_air = 0.0

# 	pp_N2_aw_t0 = 75112.41
# 	pp_N2_aw_t1 = 0.0

# 	pp_N2_alv_t0 = 75112.41
# 	pp_N2_alv_t1 = 0.0
	
# 	pp_N2_alb_t0 = 75112.41
# 	pp_N2_alb_t1 = 0.0
	
# 	pp_N2_v_t0 = 75112.41
# 	pp_N2_v_t1 = 0.0
	
# 	pp_N2_a_t0 = 75112.41
# 	pp_N2_a_t1 = 0.0

# 	tmp_t = 0.0
# 	tmp_s = 0.0

# 	dt = dtINI

#endregion


enum PlayMode  {STOP, SINGLE, SOBOL, MULTIPLE}
enum GraphMode {NONE, SATURATION, HISTOGRAM}

###############################################################
#Analyse de sobol 1 tissue
###############################################################
#region Sobol

var ax1  : Array[float] = [];  var bx1 : Array[float]  = []
var ax2  : Array[float] = [];  var bx2 : Array[float]  = []
var ax3  : Array[float] = [];  var bx3 : Array[float]  = []
var ax4  : Array[float] = [];  var bx4 : Array[float]  = []
var ax5  : Array[float] = [];  var bx5 : Array[float]  = []
var ax6  : Array[float] = [];  var bx6 : Array[float]  = []
var ax7  : Array[float] = [];  var bx7 : Array[float]  = []
var ax8  : Array[float] = [];  var bx8 : Array[float]  = []
var ax9  : Array[float] = [];  var bx9 : Array[float]  = []
var ax10 : Array[float] = [];  var bx10 : Array[float] = []
var ax11 : Array[float] = [];  var bx11 : Array[float] = []
var ax12 : Array[float] = [];  var bx12 : Array[float] = []
var start_time:int   = 0
var end_time:int     = 0
var sat_curve:Array  = []
var histo_curve:Array= []
var sat_max 		 = 75112.41 * 3
var histo_max:float= 0
var M:int = 1 # Nombre d'expériences de Sobol (utile pour connaitre la dispertion des indices de Sobol)
var num_sobol_experience:int = 0
var N:int = 100 # Nombre d'echantillon


var play_mode:PlayMode 		= PlayMode.STOP
var graph_mode:GraphMode 	= GraphMode.HISTOGRAM


# ************************
# MAIN SIMULATION FUNCTION
# ************************
func _process(_delta: float) -> void:
	if play_mode == PlayMode.MULTIPLE:
		if num_sobol_experience < M:
			_on_one_sobol_experimentation()
			num_sobol_experience += 1
			%ProgressBarMono.value = num_sobol_experience
		else:
			play_mode = PlayMode.STOP
			
	if play_mode == PlayMode.SOBOL:
		one_sobol_experimentation()
# ************************



# Only ONE simulation with the current parameters
func _on_single_simulation() -> void:
	play_mode 	= PlayMode.SINGLE
	graph_mode 	= GraphMode.SATURATION
	sat_curve 	= []
	display_parameters()

	single_simu( [ %Vt.value, %Vc.value , %Valg.value , %Valb.value , %Va.value ,%Vv.value , %Vaw.value ,
				   %Q.value , %K1.value , %K2.value , %K3.value , %Vent.value ])
	play_mode = PlayMode.STOP
	display_saturation()

func _on_one_sobol_experimentation() -> void:
	N = %N.value
	play_mode 	= PlayMode.SOBOL
	graph_mode	= GraphMode.HISTOGRAM

	#%ProgressBarMono.max_value = 6
	#%ProgressBarMono.value = 1
	one_sobol_stage = 0

func _on_multiple_sobol_experimentation() ->void:
	M = %M.value
	play_mode = PlayMode.MULTIPLE
	graph_mode = GraphMode.NONE




var one_sobol_stage:int = 0
var l:int = 0 # Current Sobol Sample in Computation (between 0 and N-1)
var DEBUG:int = 0 #0 no debug, 1 display all parameters values, 2 display time in ms and progress bar value
var rng   := RandomNumberGenerator.new()
var YAB0 : Array[float] = [];  var YAB1 : Array[float] = [];  var YAB2 : Array[float] = []; var YAB3 : Array[float] = [];var YAB4 : Array[float] = []; var YAB5 : Array[float] = []; var YAB6 : Array[float] = []; var YAB7 : Array[float] = []; var YAB8 : Array[float] = []; var YAB9 : Array[float] = []; var YAB10 : Array[float] = []; var YAB11 : Array[float] = []
var all_Y : Array[float]
var YA : Array[float] = []
var YB : Array[float] = []
var S : Array[float]
var ST : Array[float]
var VY
func one_sobol_experimentation() -> void:
	var div = %Div.value # Nb of divisions in the histogram

	if DEBUG == 1:
		if one_sobol_stage == 0:
			print("***************************************************************************************")
		else:
			print()
		print(">>>>> one_sobol_stage = " + str(one_sobol_stage) + " <<<<<<")
	display_parameters()

	var pgr_b:float = ( (l+0.0)/N+(one_sobol_stage/6.0) ) * 50.0    #(one_sobol_stage + l) / (6.0 + N)
	if DEBUG == 2:
		print("pgr_b = " + str(pgr_b))
	%ProgressBarMono.value = pgr_b
	
	if one_sobol_stage == 0:
		l = 0
		# Initialisation de l'histogramme
		for i in range(div):
			histo_curve.append(0)
		
		start_time = Time.get_ticks_msec()
		print("Sobol Analysis start at " + str(start_time)+" in ms" )

		rng = RandomNumberGenerator.new()
		
		rng.randomize()   # graine aléatoire basée sur l’horloge
		#rng.seed = 1                             # reproductibilité
		one_sobol_stage = 1
		return

	if one_sobol_stage == 1:
		# ─────────────────────────────────────────────────────────────
		# 1) Génération des échantillons  A  et  B  (séparés par variable)
		# ─────────────────────────────────────────────────────────────
		%LblStage.text = "Generating Sobol samples (N = " + str(N) + ")"

		ax1.resize(N); ax2.resize(N); ax3.resize(N); ax4.resize(N); ax5.resize(N); ax6.resize(N); ax7.resize(N); ax8.resize(N); ax9.resize(N); ax10.resize(N); ax11.resize(N); ax12.resize(N)
		bx1.resize(N); bx2.resize(N); bx3.resize(N); bx4.resize(N); bx5.resize(N); bx6.resize(N); bx7.resize(N); bx8.resize(N); bx9.resize(N); bx10.resize(N); bx11.resize(N); bx12.resize(N)
		
		print("Array creation at " + str(Time.get_ticks_msec() ) )

		var d_Vt	:float	= Vt 	* %Vt_d.value 	/ 100.0
		var d_Vc	:float	= Vc 	* %Vc_d.value 	/ 100.0
		var d_Valg	:float 	= Valg 	* %Valg_d.value / 100.0
		var d_Valb	:float 	= Valb 	* %Valb_d.value / 100.0
		var d_Va	:float	= Va 	* %Va.value 	/ 100.0
		var d_Vv	:float	= Vv 	* %Vv.value 	/ 100.0
		var d_Vaw	:float	= Vaw 	* %Vaw.value 	/ 100.0
		var d_Q		:float	= Q 	* %Q.value 		/ 100.0
		var d_K1	:float	= K1 	* %K1.value 	/ 100.0
		var d_K2	:float	= K2 	* %K2.value 	/ 100.0
		var d_K3	:float	= K3 	* %K3.value 	/ 100.0
		var d_vent	:float	= vent 	* %Vent.value 	/ 100.0

		for ll in range(N):#variation (+/- %)
			ax1[ll]  = Vt 	+ rng.randf_range(-d_Vt, d_Vt);   	bx1[ll] = Vt 	+ rng.randf_range(-d_Vt, d_Vt)
			ax2[ll]  = Vc 	+ rng.randf_range(-d_Vc, d_Vc); 	bx2[ll] = Vc 	+ rng.randf_range(-d_Vc, d_Vc)
			ax3[ll]  = Valg + rng.randf_range(-d_Valg, d_Valg);	bx3[ll] = Valg 	+ rng.randf_range(-d_Valg, d_Valg)
			ax4[ll]  = Valb + rng.randf_range(-d_Valb, d_Valb);	bx4[ll] = Valb 	+ rng.randf_range(-d_Valb, d_Valb)
			ax5[ll]  = Va 	+ rng.randf_range(-d_Va, d_Va);    	bx5[ll]  = Va 	+ rng.randf_range(-d_Va, d_Va)
			ax6[ll]  = Vv 	+ rng.randf_range(-d_Vv, d_Vv);    	bx6[ll]  = Vv 	+ rng.randf_range(-d_Vv, d_Vv)
			ax7[ll]  = Vaw 	+ rng.randf_range(-d_Vaw, d_Vaw);  	bx7[ll]  = Vaw 	+ rng.randf_range(-d_Vaw, d_Vaw)
			ax8[ll]  = Q 	+ rng.randf_range(-d_Q, d_Q);    	bx8[ll]  = Q 	+ rng.randf_range(-d_Q, d_Q)
			ax9[ll]  = K1 	+ rng.randf_range(-d_K1, d_K1); 	bx9[ll]  = K1 	+ rng.randf_range(-d_K1, d_K1)
			ax10[ll] = K2 	+ rng.randf_range(-d_K2, d_K2);		bx10[ll] = K2 	+ rng.randf_range(-d_K2, d_K2)
			ax11[ll] = K3 	+ rng.randf_range(-d_K3, d_K3);		bx11[ll] = K3 	+ rng.randf_range(-d_K3, d_K3)
			ax12[ll] = vent + rng.randf_range(-d_vent, d_vent);	bx12[ll] = vent + rng.randf_range(-d_vent, d_vent)
			# TODO: I removed both single_simu() below, but not sure. Must be verified. Here their resutls are not used so, I delete them. But...
			#single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ], false)
			#single_simu([ bx1[l], bx2[l], bx3[l], bx4[l], bx5[l], bx6[l], bx7[l], bx8[l], bx9[l], bx10[l], bx11[l], bx12[l] ], false)

		print("1 - " + str(Time.get_ticks_msec() ) )
		one_sobol_stage = 2
		return
		
		
	if one_sobol_stage == 2:
		%LblStage.text = "2 - Simulating all samples (N = " + str(N) + ")"

		# ─────────────────────────────────────────────────────────────
		# 2) Évaluations du modèle  f(A)  et  f(B)
		# ─────────────────────────────────────────────────────────────
		YA.resize(N)
		YB.resize(N)

		print("2 - " + str(Time.get_ticks_msec() ) )

		for ll in range(N):
			#print ("ll="+str(ll))
			#toto = ll
			YA[ll] = single_simu([ ax1[ll], ax2[ll], ax3[ll], ax4[ll], ax5[ll], ax6[ll], ax7[ll], ax8[ll], ax9[ll], ax10[ll], ax11[ll], ax12[ll] ])
			YB[ll] = single_simu([ bx1[ll], bx2[ll], bx3[ll], bx4[ll], bx5[ll], bx6[ll], bx7[ll], bx8[ll], bx9[ll], bx10[ll], bx11[ll], bx12[ll] ])				

		if graph_mode == GraphMode.HISTOGRAM:
			display_histogram()

		print("3 - " + str(Time.get_ticks_msec() ) )
		one_sobol_stage = 3
		return


	if one_sobol_stage == 3:
		# ─────────────────────────────────────────────────────────────
		# 3) Matrices mixtes  A_Bi  (pick & freeze) 
		# La méthode vise à évaluer l'influence de chaque variable d’entrée sur la sortie du modèle, en ne changeant qu’une variable à la fois (on la "pick") tandis que les autres restent fixes (on les "freeze").
		# ─────────────────────────────────────────────────────────────
		%LblStage.text = "Computing output parameter of 1/2 saturation time, for all samples  (12xN = " + str(12*N) + ")"

		#var YAB0 : Array[float] = [];  var YAB1 : Array[float] = [];  var YAB2 : Array[float] = []; var YAB3 : Array[float] = [];var YAB4 : Array[float] = []; var YAB5 : Array[float] = []; var YAB6 : Array[float] = []; var YAB7 : Array[float] = []; var YAB8 : Array[float] = []; var YAB9 : Array[float] = []; var YAB10 : Array[float] = []; var YAB11 : Array[float] = []
		YAB0.resize(N);    YAB1.resize(N);    YAB2.resize(N)	;YAB3.resize(N);	YAB4.resize(N);	YAB5.resize(N);	YAB6.resize(N);	YAB7.resize(N);	YAB8.resize(N);	YAB9.resize(N);	YAB10.resize(N);	YAB11.resize(N)
		print("4 - " + str(Time.get_ticks_msec() ) )


		#for l in range(N):
			## i = 0 : on prend x1 de B, les autres de A
			#YAB0[l] = set_model_parameters_for_sobol(bx1[l], ax2[l], ax3[l])
			## i = 1 : on prend x2 de B, les autres de A
			#YAB1[l] = set_model_parameters_for_sobol(ax1[l], bx2[l], ax3[l])
			## i = 2 : on prend x3 de B, les autres de A
			#YAB2[l] = set_model_parameters_for_sobol(ax1[l], ax2[l], bx3[l])
		YAB0[l] = single_simu([ bx1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ])
		YAB1[l] = single_simu([ ax1[l], bx2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ])
		YAB2[l] = single_simu([ ax1[l], ax2[l], bx3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ])
		YAB3[l] = single_simu([ ax1[l], ax2[l], ax3[l], bx4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ])
		YAB4[l] = single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], bx5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ])
		YAB5[l] = single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], bx6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ])
		YAB6[l] = single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], bx7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ])
		YAB7[l] = single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], bx8[l], ax9[l], ax10[l], ax11[l], ax12[l] ])
		YAB8[l] = single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], bx9[l], ax10[l], ax11[l], ax12[l] ])
		YAB9[l] = single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], bx10[l], ax11[l], ax12[l] ])
		YAB10[l]= single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], bx11[l], ax12[l] ])
		YAB11[l]= single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], bx12[l] ])

		l = l + 1
		if l >= N:
			if graph_mode == GraphMode.HISTOGRAM:
				display_histogram()
			print("5 - " + str(Time.get_ticks_msec() ) )
			one_sobol_stage = 4
		return

	if one_sobol_stage == 4:
		# ─────────────────────────────────────────────────────────────
		# 4) Variance totale de la sortie
		# ─────────────────────────────────────────────────────────────
		%LblStage.text = "Computing Variance between all outups"

		all_Y = YA.duplicate()
		all_Y.append_array(YB)
		VY = variance(all_Y)

		print("6 - " + str(Time.get_ticks_msec() ) )
		one_sobol_stage = 5
		return

	if one_sobol_stage == 5:
		# ─────────────────────────────────────────────────────────────
		# 5) Indices de Sobol  S_i  et  S_Ti
		# ─────────────────────────────────────────────────────────────
		%LblStage.text = "Normalizing Sobol values for each 12 parameters"

		S  = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
		ST = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

		var acc_S0 := 0.0; var acc_S1 := 0.0; var acc_S2 := 0.0; var acc_S3 := 0.0; var acc_S4 := 0.0; var acc_S5 := 0.0; var acc_S6 := 0.0; var acc_S7 := 0.0; var acc_S8 := 0.0; var acc_S9 := 0.0; var acc_S10 := 0.0; var acc_S11 := 0.0
		var acc_ST0 := 0.0; var acc_ST1 := 0.0; var acc_ST2 := 0.0; var acc_ST3 := 0.0; var acc_ST4 := 0.0; var acc_ST5 := 0.0; var acc_ST6 := 0.0; var acc_ST7 := 0.0; var acc_ST8 := 0.0; var acc_ST9 := 0.0; var acc_ST10 := 0.0; var acc_ST11 := 0.0

		for ll in range(N):
			acc_S0  += YB[ll] * (YAB0[ll] - YA[ll])
			acc_S1  += YB[ll] * (YAB1[ll] - YA[ll])
			acc_S2  += YB[ll] * (YAB2[ll] - YA[ll])
			acc_S3  += YB[ll] * (YAB3[ll] - YA[ll])
			acc_S4  += YB[ll] * (YAB4[ll] - YA[ll])
			acc_S5  += YB[ll] * (YAB5[ll] - YA[ll])
			acc_S6  += YB[ll] * (YAB6[ll] - YA[ll])
			acc_S7  += YB[ll] * (YAB7[ll] - YA[ll])
			acc_S8  += YB[ll] * (YAB8[ll] - YA[ll])
			acc_S9  += YB[ll] * (YAB9[ll] - YA[ll])
			acc_S10  += YB[ll] * (YAB10[ll] - YA[ll])
			acc_S11  += YB[ll] * (YAB11[ll] - YA[ll])


			var d0 := YA[ll] - YAB0[ll];  acc_ST0 += d0 * d0
			var d1 := YA[ll] - YAB1[ll];  acc_ST1 += d1 * d1
			var d2 := YA[ll] - YAB2[ll];  acc_ST2 += d2 * d2
			var d3 := YA[ll] - YAB3[ll];  acc_ST3 += d3 * d3
			var d4 := YA[ll] - YAB4[ll];  acc_ST4 += d4 * d4
			var d5 := YA[ll] - YAB5[ll];  acc_ST5 += d5 * d5
			var d6 := YA[ll] - YAB6[ll];  acc_ST6 += d6 * d6
			var d7 := YA[ll] - YAB7[ll];  acc_ST7 += d7 * d7
			var d8 := YA[ll] - YAB8[ll];  acc_ST8 += d8 * d8
			var d9 := YA[ll] - YAB9[ll];  acc_ST9 += d9 * d9
			var d10 := YA[ll] - YAB10[ll];  acc_ST10 += d10 * d10
			var d11 := YA[ll] - YAB11[ll];  acc_ST11 += d11 * d11

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
		var total_seconds:int = duration_ms / 1000
		var hours = int(total_seconds / 3600)
		var minutes = int((total_seconds % 3600) / 60)
		var seconds = int(total_seconds % 60)

		print("Sobol Analysis duration: %02dh %02dmin %02ds" % [hours, minutes, seconds])
		one_sobol_stage = 6
		return

	if one_sobol_stage == 6:

		# ─────────────────────────────────────────────────────────────
		# 6) Affichage
		# ─────────────────────────────────────────────────────────────
		#var names := ["x₁", "x₂", "x₃"]
		#print("\nIndices de Sobol — fonction de my_model_parameters_for_sobol (N =", N, ")")
		#print("────────────────────────────────────────────────────────")
		#for i in range(d):
			#print("%s :  Sᵢ = %.4f   |   Sₜᵢ = %.4f" % [names[i], S[i], ST[i]])
		var display_text := "[color=#003366]" 
		display_text +="		Indices de Sobol — fonction de my_model_parameters_for_sobol (N = %d)\n" % N
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
		display_text += "vent (12)   :   %.4f                           |   %.4f\n" % [S[11], ST[11]]
		if DEBUG == 1:
			print(histo_curve)
		creer_dossier_si_absent(save_folder)
		var chemin = get_chemin_fichier(M)

		var sobol_node=%SobolResults
		sobol_node.bbcode_enabled = true
		sobol_node.bbcode_text = display_text

		#capture_screenshot()
		
		#sauvegarder_resultats_json(chemin, histo_curve)
		histo_curve 		= []
		histo_max 	= 0

		# capture_screenshot()
		# Sᵢ : Indice de Sobol de premier ordre
		# Part de la variance de la sortie due uniquement à la variable xᵢ prise seule.

		# Sₜᵢ : Indice de Sobol total
		# Part de la variance due à xᵢ et à toutes ses interactions avec les autres variables.

		one_sobol_stage = 0
		l = 0
		play_mode = PlayMode.STOP
		return

#endregion

# **************************
#    DISPLAY DATA / PLOTS
# **************************
#region display

func display_parameters() :
	if num_sobol_experience > 0 and num_sobol_experience < M-1:
		return

	# Display param values in the UI
	%LblVt.text 	= "= " + str(Vt).pad_decimals(4)
	%LblVc.text 	= "= " + str(Vc).pad_decimals(6)
	%LblValg.text 	= "= " + str(Valg).pad_decimals(5)
	%LblValb.text 	= "= " + str(Valb).pad_decimals(6)
	%LblVa.text 	= "= " + str(Va).pad_decimals(5)
	%LblVv.text 	= "= " + str(Vv).pad_decimals(5)
	%LblVaw.text 	= "= " + str(Vaw).pad_decimals(5)
	%LblQ.text 		= "= " + str(Q).pad_decimals(5)
	%LblK1.text 	= "= " + str(K1).pad_decimals(8)
	%LblK2.text 	= "= " + str(K2).pad_decimals(8)
	%LblK3.text 	= "= " + str(K3).pad_decimals(8)
	%LblVent.text 	= "= " + str(vent).pad_decimals(5)

	# Display param values in the console
	if DEBUG == 1:
		print("***************************************************************************************")
		print("M =", M)
		print("N =", N)
		print("num_sobol_experience =", num_sobol_experience)
		print("vent =", vent)
		print("Vaw =", Vaw)
		print("Valg =", Valg)
		print("Valb =", Valb)
		print("Q =", Q)
		print("Va =", Va)
		print("Vv =", Vv)
		print("patm =", patm)
		print("fn2 =", fn2)
		print("diving_time =", diving_time)
		print("diving_deep =", diving_deep)

		print("alpha_n2 =", alpha_n2)
		print("ph2o =", ph2o)
		print("K1 =", K1)
		print("K2 =", K2)
		print("K3 =", K3)
		print("R =", R)
		print("T =", T)
		print("tmp_t =", tmp_t)
		print("tmp_s =", tmp_s)
		print("time =", time)
		print("dtINI =", dtINI)
		print("dt =", dt)
		print("diving_stage =", diving_stage)
		print("iteration =", iteration)
		print("Vc =", Vc)

		print("kn2 =", kn2)
		print("pp_N2_c_t0 =", pp_N2_c_t0)
		print("pp_N2_c_t1 =", pp_N2_c_t1)
		print("pp_N2_ti_t0 =", pp_N2_ti_t0)
		print("pp_N2_ti_t1 =", pp_N2_ti_t1)
		print("Vt =", Vt)

		print("pp_N2_air =", pp_N2_air)

		print("pp_N2_aw_t0 =", pp_N2_aw_t0)
		print("pp_N2_aw_t1 =", pp_N2_aw_t1)

		print("pp_N2_alv_t0 =", pp_N2_alv_t0)
		print("pp_N2_alv_t1 =", pp_N2_alv_t1)

		print("pp_N2_alb_t0 =", pp_N2_alb_t0)
		print("pp_N2_alb_t1 =", pp_N2_alb_t1)

		print("pp_N2_v_t0 =", pp_N2_v_t0)
		print("pp_N2_v_t1 =", pp_N2_v_t1)

		print("pp_N2_a_t0 =", pp_N2_a_t0)
		print("pp_N2_a_t1 =", pp_N2_a_t1)

func display_histogram() :
	var duration = 120
	var x_min = duration
	var x_max = 0
	for x in histo_curve.size():
		if histo_curve[x] > 0:
			x_min = 0
	histo_curve.reverse()
	for x in histo_curve.size():
		if histo_curve[x] > 0:
			x_max = histo_curve.size() - x
	histo_curve.reverse()

	x_max += 10

	%Graph2D.remove_all()
	my_plot = %Graph2D.add_plot_item("Histogram",Color(0.3, 0.5, 0.7), 1.0)
	%Graph2D.y_max = histo_max
	%Graph2D.x_min = x_min
	%Graph2D.x_max = x_max

	for x in range(%Div.value):
		my_plot.add_point(Vector2(x, histo_curve[x]))

func display_saturation() :
	%Graph2D.remove_all()
	my_plot = %Graph2D.add_plot_item("Saturation",Color(0.0, 0.0, 0.0), 1.0)
	%Graph2D.y_max = sat_max
	for i in sat_curve.size():
		my_plot.add_point(Vector2(sat_curve[i].x, sat_curve[i].y))


func _on_remove_all_plots_pressed() -> void:
	%Graph2D.remove_all()

#endregion

# **********************
# Export des resultats
# **********************
#region ExportData
	##capture d'ecran des resultat
var screenshot_count = 0
var save_folder = "../sobol_results_"+str(N)+"/"# chemin parent relatif 
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

func sauvegarder_resultats_json(chemin_complet: String, donnees: Array) -> void:
	var file = FileAccess.open(chemin_complet, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(donnees, "\t"))  # "\t" = indentation par tabulation
		file.close()
	else:
		push_error("Erreur : Impossible d’ouvrir le fichier : " + chemin_complet)
func get_chemin_fichier(index: int) -> String:
	return save_folder + "histo_curve" + str(index) + ".json"	
	
func creer_dossier_si_absent(chemin: String) -> void:
	if not DirAccess.dir_exists_absolute(chemin):
		var dir = DirAccess.open(".")
		if dir != null:
			dir.make_dir_recursive(chemin)
	
#endregion

# **********************
# Fonctions utilitaires
# **********************
#region utiltaires

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
	
#endregion
