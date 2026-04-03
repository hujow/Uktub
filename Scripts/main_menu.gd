extends Control

var game_scene_path = "res://Scenes/Game.tscn"

# @onready permet de récupérer le nœud texte une fois que la scène est chargée.
@onready var prompt_label = $VBoxContainer/PromptLabel

func _ready():
	DisplayServer.window_set_title("Tadhakkar!")

func _input(event):
	if event is InputEventKey and event.pressed:
		start_game()

func start_game():
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_timer_timeout():
	if prompt_label.modulate.a == 1.0:
		prompt_label.modulate.a = 0.0
	else:
		prompt_label.modulate.a = 1.0
