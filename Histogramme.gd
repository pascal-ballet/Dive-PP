# Histogramme.gd attaché à un Node2D
extends Node2D

var resultat = []

func _ready():
	update()  # Rafraîchir l'affichage

func _draw():
	var bar_width = 20
	var spacing = 5
	var base_y = 300

	for i in range(resultat.size()):
		var height = resultat[i] * 10
		var x = i * (bar_width + spacing)
		draw_rect(Rect2(x, base_y - height, bar_width, height), Color(0.8, 0.4, 0.1))
