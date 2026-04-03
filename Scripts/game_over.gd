extends Control

# Remplacez par les noms exacts de vos Labels dans la scène GameOver
@onready var stats_label = $StatsLabel

# Variables qui seront injectées par la scène Game AVANT le _ready()
var final_score: int = 0
var total_names: int = 0
var timer_duration: float = 0.0

func _ready():
	var msg = ""
	
	if final_score == 0:
		msg = "You didn't type any names!"
	else:
		var estimate_sec = (75227 * timer_duration) / float(final_score)
		msg = "At this speed, it would take you\n"
		msg += format_duration(estimate_sec)
		msg += "\nto type all the names of the victims"
		msg += "\nof the Israel Defence Force and Hamas "
		msg += "\nsince October 7 2023."
		
	stats_label.text = msg

# On gère l'appui sur "R" ici directement
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		# Recharge complètement la scène de jeu principale, c'est beaucoup plus propre !
		get_tree().reload_current_scene()

func format_duration(seconds_float: float) -> String:
	var sec = int(round(seconds_float))
	var days = sec / 86400
	sec = sec % 86400
	var hours = sec / 3600
	sec = sec % 3600
	var mins = sec / 60
	sec = sec % 60
	
	return str(days) + " days " + str(hours) + " hours " + str(mins) + " minutes " + str(sec) + " seconds"


func _on_button_pressed() -> void:
	pass # Replace with function body.
	
func _on_learn_more_button_pressed():
	OS.shell_open("https://en.wikipedia.org/wiki/Casualties_of_the_Gaza_war")	
