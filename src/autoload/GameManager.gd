extends Node

# Автоподгружаемый скрипт для управления игровым состоянием

var current_faction = ""
var player_level = 1
var player_experience = 0

func _ready():
	print("GameManager инициализирован")

func select_faction(faction_name):
	current_faction = faction_name
	print("Выбрана фракция: ", faction_name)

func add_experience(amount):
	player_experience += amount
	print("Получено опыта: ", amount)
	check_level_up()

func check_level_up():
	var experience_needed = player_level * 100
	if player_experience >= experience_needed:
		player_level += 1
		player_experience -= experience_needed
		print("Повышение уровня! Новый уровень: ", player_level)