extends Node3D

# Основной скрипт игры Forest Kingdoms RPG

func _ready():
	print(LocalizationManager.get_string("GAME_LOADED"))
	print(LocalizationManager.get_string("CHOOSE_FACTION"))
	print(LocalizationManager.get_string("FOREST_ELVES"))
	print(LocalizationManager.get_string("PALACE_GUARD"))
	print(LocalizationManager.get_string("VILLAINS"))

func _process(delta):
	pass