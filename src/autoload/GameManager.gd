extends Node

# Автоподгружаемый скрипт для управления игровым состоянием

# Константы
const EXPERIENCE_MULTIPLIER = 100

# Переменные состояния игрока
var current_faction = ""
var player_level = 1
var player_experience = 0

# Вызывается при инициализации узла
func _ready():
	print("GameManager инициализирован")

# Выбор фракции игрока
# faction_name: название фракции
func select_faction(faction_name):
	if faction_name != "":
		current_faction = faction_name
		print("Выбрана фракция: ", faction_name)
	else:
		print("Неверное название фракции")

# Добавление опыта игроку
# amount: количество опыта для добавления
func add_experience(amount):
	if amount > 0:
		player_experience += amount
		print("Получено опыта: ", amount)
		check_level_up()
	else:
		print("Неверное количество опыта")

# Проверка на повышение уровня
func check_level_up():
	var experience_needed = player_level * EXPERIENCE_MULTIPLIER
	if player_experience >= experience_needed:
		player_level += 1
		player_experience -= experience_needed
		print("Повышение уровня! Новый уровень: ", player_level)

# Получение текущей фракции игрока
func get_current_faction():
	return current_faction

# Получение текущего уровня игрока
func get_player_level():
	return player_level

# Получение текущего опыта игрока
func get_player_experience():
	return player_experience

# Получение необходимого количества опыта для следующего уровня
func get_experience_needed():
	return player_level * EXPERIENCE_MULTIPLIER