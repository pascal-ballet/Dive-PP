extends MarginContainer

# ***********************
# Variables modifiables
# ***********************

var vent: 	float = 8.1 # debit ventilatoire 
var vaw: 	float = 1.5 #volume des voix aérienne
var valg: 	float = 1.0 # volume du gaz alvéolaire
var valb: 	float = 0.5 # volume de sang alvéolaire
var q: 		float = 4.209 # debit cardiaque
var va: 	float = 1.7 #volume artériel
var vv: 	float = 3.0 #volume veineux
var patm: 	float = 101325.0 # presion ambiante
var fn2: 	float = 0.79 #fraction d azote dans le gaz respiré
var diving_time = [1,null,null,null,null,null,null,null,null,null]
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
var vc:float 		= 0.5# colume capilaire
var Vt:float		= 70 # Tissue Volume
#var Q: float =4.2#debit sanguin
const kn2 :float 		= 0.0000619# coef solubiliter azote
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




func capilar_blood_mono():
	var delta = (1/(vc*alpha_n2)*(q*alpha_n2*pp_N2_a_t0-(alpha_n2*q+K3)*pp_N2_c_t0+K3*pp_N2_ti_t0))*dt
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
var my_plotti : PlotItem = null
	
func single_simu(params:Array, curve:bool) -> float:
	Vt 		= params[0] 
	vc 		= params[1] 
	valg 	= params[2]
	valb 	= params[3] 
	va 		= params[4] 
	vv 		= params[5] 
	vaw 	= params[6] 
	q 		= params[7] 
	K1 		= params[8] 
	K2 		= params[9] 
	K3 		= params[10]

	# Parametres stables mais a re-initialiser
	_reset_mono()

	if curve == true:
		# Créer un nouveau plot avec un label unique et une couleur dynamique
		var grey:int = int(randf()*0.5 + 0.5)
		my_plotti = %Graph2D.add_plot_item(  
				"Plot %d" % [%Graph2D.count()],
				[Color(grey, grey, grey)][%Graph2D.count() % 1],
				[1.0, 1.0, 1.0].pick_random()
				)
	
	var x: float = 0.0  # Initialize the x value
	var y: float = 0.0  # Initialize the y value
	
	var duration:float  = 120
	var max_points:float = duration / dt
	var time_dist:int = int(floor(max_points / 1360.0))
	var half_pressure : float = 75112.41 * 1.5 #TODO a changer par (pression init + pression final)/2 
	while pp_N2_ti_t0 < half_pressure:
	#while time < duration:
		one_step_mono() # Simulation of one step
		if curve == true and iteration % time_dist == 0: #recupere 1 valeur toute les time_dist 
			x = time  # Increment x 
			y = pp_N2_ti_t0  # increment  y 
			# Add the point (x, y) to the plot
			my_plotti.add_point(Vector2(x, y))
		#_reset_valuesCourbe()
	#print("Plot updated with points!")
	return time


## fonction step pour 1 seul tissue
func one_simulation_with_sobol() :
	# display_parameters()
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

# Fonction de reset quand stop est pressé
func reset_values_when_Sobol(): 
	reset_parameters()	
	vent = 8.1
	vaw = 1.5
	valg = 1.0
	valb = 0.5
	q = 4.2
	va = 1.7
	vv = 3.0
	patm = 101325.0
	diving_time = [1,null,null,null,null,null,null,null,null,null]
	diving_deep = [10,null,null,null,null,null,null,null,null,null]
	Vt = %Vt.value
	vc = 0.5
	K1 = 0.00267 # coef de difusion respiratoire
	K2 = 0.00748 # coef de difusion alveolo capilaire
	K3 =0.00267
	

func _reset_mono():
	reset_parameters()

	diving_stage = 1
	iteration = 0
		
	pp_N2_ti_t0 = 75112.41
	pp_N2_ti_t1 = 0.0
	
	pp_N2_c_t0 = 75112.41
	pp_N2_c_t1 = 0.0


func reset_parameters():
	time = 0.0

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

#endregion



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
var start_time:int = 0
var end_time:int   = 0
var histo:Array    = []
var M:int = 1 # Nombre d'expériences de Sobol (utile pour créer la gaussienne des résultats pour plusieurs Sobol)
var num_sobol_experience:int = 0
var  N:int = 100 # Nombre d'echantillon

enum PlayMode {STOP, SINGLE, SOBOL, MULTIPLE}

var play_mode:PlayMode = PlayMode.STOP

func _process(delta: float) -> void:
	if play_mode == PlayMode.MULTIPLE:
		if num_sobol_experience < M:
			_on_one_sobol_experimentation()
			num_sobol_experience += 1
			%ProgressBarMono.value = num_sobol_experience
		else:
			play_mode = PlayMode.STOP
			
	if play_mode == PlayMode.SOBOL:
		one_sobol_experimentation()

func _on_single_simulation() -> void:
	play_mode = PlayMode.SINGLE
	single_simu([Vt,vc,valg,valb,va,vv,vaw,q,K1,K2,K3,vent], true)
	play_mode = PlayMode.STOP

func _on_multiple_sobol_experimentation() ->void:
	M = %M.value
	play_mode = PlayMode.MULTIPLE
	%ProgressBarMono.max_value = M
	%ProgressBarMono.value = 1

	# while num_sobol_experience < M:
	# 	_on_one_sobol_experimentation()
	# 	num_sobol_experience += 1

func _on_one_sobol_experimentation() -> void:
	N = %N.value
	play_mode = PlayMode.SOBOL
	%ProgressBarMono.max_value = 6
	%ProgressBarMono.value = 1
	one_sobol_stage = 0






var one_sobol_stage:int = 0
var rng   := RandomNumberGenerator.new()
var YAB0 : Array[float] = [];  var YAB1 : Array[float] = [];  var YAB2 : Array[float] = []; var YAB3 : Array[float] = [];var YAB4 : Array[float] = []; var YAB5 : Array[float] = []; var YAB6 : Array[float] = []; var YAB7 : Array[float] = []; var YAB8 : Array[float] = []; var YAB9 : Array[float] = []; var YAB10 : Array[float] = []; var YAB11 : Array[float] = []
var all_Y : Array[float]
var YA : Array[float] = []
var YB : Array[float] = []
var S : Array[float]
var ST : Array[float]
var VY
func one_sobol_experimentation() -> void:
	var div = %Div.value

	#display_parameters()
	%ProgressBarMono.value = one_sobol_stage + 1
	
	if one_sobol_stage == 0:
		# Initialisation de l'histogramme
		for i in range(div):
			histo.append(0)
		
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
		
		ax1.resize(N); ax2.resize(N); ax3.resize(N); ax4.resize(N); ax5.resize(N); ax6.resize(N); ax7.resize(N); ax8.resize(N); ax9.resize(N); ax10.resize(N); ax11.resize(N); ax12.resize(N)
		bx1.resize(N); bx2.resize(N); bx3.resize(N); bx4.resize(N); bx5.resize(N); bx6.resize(N); bx7.resize(N); bx8.resize(N); bx9.resize(N); bx10.resize(N); bx11.resize(N); bx12.resize(N)
		
		print("Array creation at " + str(Time.get_ticks_msec() ) )

		for l in range(N):#variation de 20% (+/- 10%)
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
			single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ], false)
			single_simu([ bx1[l], bx2[l], bx3[l], bx4[l], bx5[l], bx6[l], bx7[l], bx8[l], bx9[l], bx10[l], bx11[l], bx12[l] ], false)
		print("1 - " + str(Time.get_ticks_msec() ) )
		one_sobol_stage = 2
		return
		
		
	if one_sobol_stage == 2:

		# ─────────────────────────────────────────────────────────────
		# 2) Évaluations du modèle  f(A)  et  f(B)
		# ─────────────────────────────────────────────────────────────
		YA.resize(N)
		YB.resize(N)

		print("2 - " + str(Time.get_ticks_msec() ) )

		for l in range(N):
			#print ("l="+str(l))
			#toto = l
			YA[l] = single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ], false)
			
			if YA[l]>= 10 and YA[l]<=20:
				var p:int = int(((YA[l]-10)*10))
				histo[p]+=1
				
			YB[l] = single_simu([ bx1[l], bx2[l], bx3[l], bx4[l], bx5[l], bx6[l], bx7[l], bx8[l], bx9[l], bx10[l], bx11[l], bx12[l] ], false)
			if YB[l]>= 10 and YB[l]<=20:
				var p:int = int(((YB[l]-10)*10))
				histo[p]+=1
				

		print("3 - " + str(Time.get_ticks_msec() ) )
		one_sobol_stage = 3
		return


	if one_sobol_stage == 3:

		# ─────────────────────────────────────────────────────────────
		# 3) Matrices mixtes  A_Bi  (pick & freeze) 
		# La méthode vise à évaluer l'influence de chaque variable d’entrée sur la sortie du modèle, en ne changeant qu’une variable à la fois (on la "pick") tandis que les autres restent fixes (on les "freeze").
		# ─────────────────────────────────────────────────────────────
		#var YAB0 : Array[float] = [];  var YAB1 : Array[float] = [];  var YAB2 : Array[float] = []; var YAB3 : Array[float] = [];var YAB4 : Array[float] = []; var YAB5 : Array[float] = []; var YAB6 : Array[float] = []; var YAB7 : Array[float] = []; var YAB8 : Array[float] = []; var YAB9 : Array[float] = []; var YAB10 : Array[float] = []; var YAB11 : Array[float] = []
		YAB0.resize(N);    YAB1.resize(N);    YAB2.resize(N)	;YAB3.resize(N);	YAB4.resize(N);	YAB5.resize(N);	YAB6.resize(N);	YAB7.resize(N);	YAB8.resize(N);	YAB9.resize(N);	YAB10.resize(N);	YAB11.resize(N)
		print("4 - " + str(Time.get_ticks_msec() ) )


		for l in range(N):
			## i = 0 : on prend x1 de B, les autres de A
			#YAB0[l] = set_model_parameters_for_sobol(bx1[l], ax2[l], ax3[l])
			## i = 1 : on prend x2 de B, les autres de A
			#YAB1[l] = set_model_parameters_for_sobol(ax1[l], bx2[l], ax3[l])
			## i = 2 : on prend x3 de B, les autres de A
			#YAB2[l] = set_model_parameters_for_sobol(ax1[l], ax2[l], bx3[l])
			YAB0[l] = single_simu([ bx1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ], false)
			YAB1[l] = single_simu([ ax1[l], bx2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ], false)
			YAB2[l] = single_simu([ ax1[l], ax2[l], bx3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ], false)
			YAB3[l] = single_simu([ ax1[l], ax2[l], ax3[l], bx4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ], false)
			YAB4[l] = single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], bx5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ], false)
			YAB5[l] = single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], bx6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ], false)
			YAB6[l] = single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], bx7[l], ax8[l], ax9[l], ax10[l], ax11[l], ax12[l] ], false)
			YAB7[l] = single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], bx8[l], ax9[l], ax10[l], ax11[l], ax12[l] ], false)
			YAB8[l] = single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], bx9[l], ax10[l], ax11[l], ax12[l] ], false)
			YAB9[l] = single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], bx10[l], ax11[l], ax12[l] ], false)
			YAB10[l]= single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], bx11[l], ax12[l] ], false)
			YAB11[l]= single_simu([ ax1[l], ax2[l], ax3[l], ax4[l], ax5[l], ax6[l], ax7[l], ax8[l], ax9[l], ax10[l], ax11[l], bx12[l] ], false)
		print("5 - " + str(Time.get_ticks_msec() ) )
		one_sobol_stage = 4
		return

	if one_sobol_stage == 4:
		# ─────────────────────────────────────────────────────────────
		# 4) Variance totale de la sortie
		# ─────────────────────────────────────────────────────────────
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
		S  = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
		ST = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

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
		display_text += "vent (12)   :   %.4f                          |   %.4f\n" % [S[11], ST[11]]
		print(histo)
		creer_dossier_si_absent(save_folder)
		var chemin = get_chemin_fichier(M)

		var sobol_node=%SobolResults
		sobol_node.bbcode_enabled = true
		sobol_node.bbcode_text = display_text

		#capture_screenshot()
		
		#sauvegarder_resultats_json(chemin, histo)
		histo=[]

		reset_values_when_Sobol()
		# capture_screenshot()
		# Sᵢ : Indice de Sobol de premier ordre
		# Part de la variance de la sortie due uniquement à la variable xᵢ prise seule.

		# Sₜᵢ : Indice de Sobol total
		# Part de la variance due à xᵢ et à toutes ses interactions avec les autres variables.

		one_sobol_stage = 0
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
	print("***************************************************************************************")
	print("M =", M)
	print("N =", N)
	print("num_sobol_experience =", num_sobol_experience)
	print("vent =", vent)
	print("vaw =", vaw)
	print("valg =", valg)
	print("valb =", valb)
	print("q =", q)
	print("va =", va)
	print("vv =", vv)
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
	print("vc =", vc)

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


func _on_remove_all_plots_pressed() -> void:
	$TabContainer/Graph/Graph2D.remove_all()
	print("press remove !")
	

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
	return save_folder + "histo" + str(index) + ".json"	
	
func creer_dossier_si_absent(chemin: String) -> void:
	if not DirAccess.dir_exists_absolute(chemin):
		var dir = DirAccess.open(".")
		if dir != null:
			dir.make_dir_recursive(chemin)
	
#endregion


	

# ────────────────────────────────────────────────────────────────────
# Fonctions utilitaires
# ────────────────────────────────────────────────────────────────────

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
	
	##TODO lse parametre a faire varier 
		##var V debi ventilatoire
		##Q debit qaurdiaque
		##K1 K2 K3
		##tous les volume 7 
		##
	


#l=1579 l=1845 l=1853 l=1863 l=1947 l=2077 l=2278 l=2287 l=2314 l=2890
