# TextQuestSystem.gd
# Класс для текстовой системы квестов в MUD режиме

extends Node

# Отображение списка квестов
func display_quests():
	# Здесь должна быть логика получения списка квестов игрока
	# и отображения их текстового представления
	
	print("Ваши квесты:")
	
	# Пример списка квестов
	var quests = [
		{
			"id": 1,
			"title": "Поиск артефакта",
			"description": "Найдите древний артефакт в руинах храма",
			"status": "в процессе",
			"progress": "2/3 частей найдено"
		},
		{
			"id": 2,
			"title": "Помощь стражникам",
			"description": "Помогите стражникам очистить лес от монстров",
			"status": "новый",
			"progress": "0/5 монстров уничтожено"
		}
	]
	
	if quests.size() == 0:
		print("  У вас нет активных квестов.")
	else:
		for i in range(quests.size()):
			var quest = quests[i]
			print("  " + str(i+1) + ". " + quest.title + " (" + quest.status + ")")
			print("     " + quest.description)
			print("     Прогресс: " + quest.progress)
			print("")
	
	print("")

# Отображение деталей квеста
func display_quest_details(quest_id: int):
	# Здесь должна быть логика получения деталей квеста
	# и отображения их текстового представления
	
	# Пример деталей квеста
	var quest = {
		"id": quest_id,
		"title": "Поиск артефакта",
		"description": "Найдите древний артефакт в руинах храма",
		"status": "в процессе",
		"progress": "2/3 частей найдено",
		"objectives": [
			"Найти первую часть артефакта в главном зале храма",
			"Найти вторую часть артефакта в подземельях храма",
			"Найти третью часть артефакта в сокровищнице храма"
		],
		"rewards": [
			"100 золотых монет",
			"Магический посох",
			"1000 опыта"
		]
	}
	
	print("Квест: " + quest.title)
	print("Статус: " + quest.status)
	print("Описание: " + quest.description)
	print("Прогресс: " + quest.progress)
	print("")
	print("Цели:")
	for i in range(quest.objectives.size()):
		print("  " + str(i+1) + ". " + quest.objectives[i])
	print("")
	print("Награды:")
	for i in range(quest.rewards.size()):
		print("  " + str(i+1) + ". " + quest.rewards[i])
	print("")

# Обновление прогресса квеста
func update_quest_progress(quest_id: int, progress: String):
	# Здесь должна быть логика обновления прогресса квеста
	
	print("Прогресс квеста обновлен: " + progress)
	
	# Здесь должна быть логика проверки завершения квеста
	# и выдачи наград при необходимости

# Завершение квеста
func complete_quest(quest_id: int):
	# Здесь должна быть логика завершения квеста
	# и выдачи наград игроку
	
	print("Квест завершен!")
	
	# Здесь должна быть логика выдачи наград
	# Например, добавление предметов в инвентарь, начисление опыта и т.д.