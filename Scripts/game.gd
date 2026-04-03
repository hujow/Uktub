extends Control

const GAME_OVER_SCENE = preload("res://Scenes/game_over.tscn")

@onready var name_label = $CenterText/NameLabel
@onready var info_label = $CenterText/InfoLabel
@onready var score_label = $TopHUD/ScoreLabel
@onready var timer_bar = $TimerBar
@onready var input_field = $InputField
@onready var game_timer = $GameTimer
@onready var pause_timer = $PauseTimer



var names_list = []
var current_data = {}
var score = 0
var game_over = false

func _ready():
	load_names_from_csv("res://Data/names.csv")
	score_label.text = "Score: 0"
	info_label.text = ""
	
	input_field.text_submitted.connect(_on_input_field_text_submitted)
	game_timer.timeout.connect(_on_game_timer_timeout)
	pause_timer.timeout.connect(_on_pause_timer_timeout)
	
	timer_bar.max_value = game_timer.wait_time
	timer_bar.value = game_timer.wait_time
	
	pick_next_name()
	game_timer.start()
	input_field.grab_focus()

func _process(_delta):	
	timer_bar.value = game_timer.time_left

func load_names_from_csv(path: String):
	if not FileAccess.file_exists(path):
		print("Erreur: Fichier CSV introuvable !")
		name_label.text = "Error: CSV not found"
		return
		
	var file = FileAccess.open(path, FileAccess.READ)
	
	# On saute la première ligne d'en-tête
	file.get_csv_line() 
	
	while not file.eof_reached():
		var line = file.get_csv_line(",") 
		
		if line.size() >= 3 and line[0] != "":
			# Création sécurisée du dictionnaire pour éviter les erreurs de parseur
			var new_entry = {}
			new_entry["name"] = line[0].strip_edges()
			new_entry["age"] = line[1].strip_edges()
			new_entry["sex"] = line[2].strip_edges()
			
			names_list.append(new_entry)
			
	file.close()

func classify(age_str: String, sex_str: String) -> String:
	if age_str == "" or sex_str == "": 
		return "unknown"
		
	var age = age_str.to_int()
	var sex = sex_str.to_lower()
	
	if age < 2:
		return "baby"
		
	if age < 18:
		if sex == "m":
			return "boy"
		elif sex == "f":
			return "girl"
		else:
			return "unknown"
			
	if sex == "m":
		return "man"
	elif sex == "f":
		return "woman"
	else:
		return "unknown"
		
func get_random_color() -> Color:
	var r = randf_range(0.2, 0.8)
	var g = randf_range(0.2, 0.8)
	var b = randf_range(0.2, 0.8)
	return Color(r, g, b)

func pick_next_name():
	if names_list.size() == 0:
		name_label.text = "(Out of names!)"
		return
		
	var random_index = randi() % names_list.size()
	current_data = names_list[random_index]
	
	name_label.text = current_data["name"]
	info_label.text = ""
	
	input_field.text = ""
	input_field.editable = true
	input_field.call_deferred("grab_focus")
	RenderingServer.set_default_clear_color(get_random_color())
	

func _on_input_field_text_submitted(submitted_text: String):
	var typed = submitted_text.strip_edges().to_lower()
	var target = current_data["name"].to_lower()
	
	if typed == target and target != "":
		success()
	else:
			input_field.text = ""
			input_field.grab_focus()

func success():
	score += 1
	score_label.text = "Score: " + str(score)
	
	var age_label = current_data["age"]
	if age_label == "": 
		age_label = "unknown"
	
	var sex_label = classify(current_data["age"], current_data["sex"])
	
	info_label.text = age_label + "   " + sex_label
	
	input_field.editable = false
	pause_timer.start()

func _on_pause_timer_timeout():
	pick_next_name()

func _on_game_timer_timeout():
	# 1. Masquer les éléments de l'UI du jeu en cours
	input_field.editable = false
	input_field.hide()
	$TopHUD.hide()
	$CenterText.hide()
	if "timer_bar" in self:
		$TimerBar.hide()
	
	# 2. Instancier la scène GameOver
	var game_over_instance = GAME_OVER_SCENE.instantiate()
	
	# 3. Transmettre les valeurs de la partie
	game_over_instance.final_score = score
	game_over_instance.total_names = names_list.size()
	game_over_instance.timer_duration = game_timer.wait_time
	
	# 4. Ajouter la scène GameOver à l'écran
	# Le _ready() de game_over_instance sera appelé à ce moment précis
	add_child(game_over_instance)

func format_duration(seconds_float: float) -> String:
	var sec = int(round(seconds_float))
	
	var days = sec / 86400
	sec = sec % 86400
	
	var hours = sec / 3600
	sec = sec % 3600
	
	var mins = sec / 60
	sec = sec % 60
	
	return str(days) + " days " + str(hours) + " hours " + str(mins) + " minutes " + str(sec) + " seconds"
	
func _input(event):
	# Si le jeu est terminé et qu'on appuie sur la touche R
	if game_over and event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			restart_game()

func restart_game():
	game_over = false
	score = 0
	score_label.text = "Score: 0"
	
	# On réaffiche et on vide le champ de texte
	input_field.show()
	input_field.editable = true
	input_field.text = ""
	
	# On relance le chronomètre (et la jauge si vous l'avez ajoutée précédemment)
	game_timer.start()
	if "timer_bar" in self:
		timer_bar.value = game_timer.wait_time
		
	pick_next_name()
