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
		var estimate_sec = (float(total_names) * timer_duration) / float(final_score)
		msg = "At this speed, it would take you\n"
		msg += format_duration(estimate_sec)
		msg += "\nto type all the names of the victims."
		
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
