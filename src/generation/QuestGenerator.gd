extends Node

# Скрипт для процедурной генерации квестов

# Типы квестов
var quest_types = ["delivery", "elimination", "exploration", "collection", "escort", "rescue"]

# Шаблоны квестов
var quest_templates = {
	"delivery": {
		"title": "Доставка для {npc}",
		"description": "{npc} просит доставить {item} в {location}.",
		"objectives": ["Доставить {item} в {location}"],
		"rewards": ["gold", "experience"]
	},
	"elimination": {
		"title": "Уничтожение {target}",
		"description": "{npc} просит избавиться от {target} в {location}.",
		"objectives": ["Убить {target}"],
		"rewards": ["gold", "loot", "experience"]
	},
	"exploration": {
		"title": "Исследование {location}",
		"description": "{npc} просит исследовать {location} и доложить о находках.",
		"objectives": ["Исследовать {location}", "Найти {item}"],
		"rewards": ["experience", "map"]
	},
	"collection": {
		"title": "Сбор {item}",
		"description": "{npc} нуждается в {count} единицах {item}.",
		"objectives": ["Собрать {count} {item}"],
		"rewards": ["gold", "experience", "recipe"]
	},
	"escort": {
		"title": "Сопровождение {npc}",
		"description": "{npc} просит сопроводить его в {location}.",
		"objectives": ["Сопроводить {npc} в {location}", "Защитить {npc} от врагов"],
		"rewards": ["gold", "experience", "favor"]
	},
	"rescue": {
		"title": "Спасение {target}",
		"description": "{npc} просит спасти {target} из {location}.",
		"objectives": ["Найти {target}", "Спасти {target}"],
		"rewards": ["gold", "experience", "ally"]
	}
}

# Параметры для генерации
var locations = ["Лес Эльфов", "Дворцовый город", "Подземелья", "Запретный храм", "Городская тюрьма", "Старая башня"]
var items = ["лекарственные травы", "магические кристаллы", "древние свитки", "редкие руды", "алхимические ингредиенты"]
var targets = ["волков", "_BANDITS", "скелетов", "пауков", "гоблинов", "демонов"]

func _ready():
	pass

# Генерация квеста на основе типа
func generate_quest(quest_type, faction, level=1):
	# Проверка, существует ли шаблон для данного типа квеста
	if not quest_templates.has(quest_type):
		return null
	
	var template = quest_templates[quest_type]
	var quest_data = {
		"title": "",
		"description": "",
		"objectives": [],
		"rewards": [],
		"faction": faction,
		"level": level,
		"npc": "",
		"location": "",
		"item": "",
		"target": "",
		"count": 0
	}
	
	# Генерация параметров квеста
	quest_data.npc = generate_npc_name(faction)
	quest_data.location = locations[randi() % locations.size()]
	quest_data.item = items[randi() % items.size()]
	quest_data.target = targets[randi() % targets.size()]
	quest_data.count = randi_range(3, 10) * level
	
	# Заполнение шаблона квеста
	quest_data.title = template.title.format(quest_data)
	quest_data.description = template.description.format(quest_data)
	
	# Заполнение целей квеста
	for objective in template.objectives:
		quest_data.objectives.append(objective.format(quest_data))
	
	# Генерация наград
	quest_data.rewards = generate_rewards(quest_type, level)
	
	return quest_data

# Генерация имени NPC для квеста
func generate_npc_name(faction):
	var first_names = {
		"elves": ["Aelar", "Baelen", "Caelen", "Daeren", "Elandra"],
		"palace_guard": ["Marcus", "Lucius", "Gaius", "Octavius", "Flavius"],
		"villain": ["Malakar", "Vorath", "Drazik", "Nexor", "Zarak"]
	}
	
	var last_names = {
		"elves": ["Moonwhisper", "Starbreeze", "Greenleaf", "Nightwalker", "Dawnstrider"],
		"palace_guard": ["Valerius", "Antonius", "Flavius", "Julius", "Maximus"],
		"villain": ["Darkheart", "Shadowbane", "Nightshade", "Bloodmoon", "Skullcrusher"]
	}
	
	if first_names.has(faction) and last_names.has(faction):
		var first_name = first_names[faction][randi() % first_names[faction].size()]
		var last_name = last_names[faction][randi() % last_names[faction].size()]
		return first_name + " " + last_name
	else:
		return "Неизвестный"
	
# Генерация наград за квест
func generate_rewards(quest_type, level):
	var rewards = []
	var base_gold = 10 * level
	var base_experience = 50 * level
	
	# Базовые награды
	rewards.append(str(base_gold) + " золота")
	rewards.append(str(base_experience) + " опыта")
	
	# Дополнительные награды в зависимости от типа квеста
	match quest_type:
		"delivery":
			if randf() < 0.3:
				rewards.append("случайный предмет")
		"elimination":
			rewards.append("добыча с врагов")
			if randf() < 0.5:
				rewards.append("редкий предмет")
		"exploration":
			rewards.append("карта местности")
			if randf() < 0.4:
				rewards.append("скрытый сундук")
		"collection":
			rewards.append("рецепт крафта")
			if randf() < 0.3:
				rewards.append("уникальный ингредиент")
		"escort":
			rewards.append("благосклонность NPC")
			if randf() < 0.2:
				rewards.append("постоянный союзник")
		"rescue":
			rewards.append("новый союзник")
			if randf() < 0.4:
				rewards.append("ценная информация")
	
	return rewards

# Генерация цепочки квестов
func generate_quest_chain(faction, chain_length=3, start_level=1):
	var chain = []
	var current_level = start_level
	var previous_location = ""
	
	for i in range(chain_length):
		# Выбор типа квеста
		var quest_type = quest_types[randi() % quest_types.size()]
		
		# Генерация квеста
		var quest = generate_quest(quest_type, faction, current_level)
		
		# Связывание квестов в цепочку
		if i > 0:
			# Добавление ссылки на предыдущий квест
			quest.description += " Это продолжение предыдущего задания."
		
		chain.append(quest)
		
		# Увеличение уровня для следующего квеста
		current_level += 1
		
		# Случайное изменение локации
		if randf() < 0.3:
			previous_location = quest.location
	
	return chain

# Генерация случайного квеста
func generate_random_quest(faction, level=1):
	var quest_type = quest_types[randi() % quest_types.size()]
	return generate_quest(quest_type, faction, level)