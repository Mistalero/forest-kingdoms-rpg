extends Node

# Скрипт для процедурной генерации NPC и существ

# Базовые данные для генерации
var first_names = {
	"elves": ["Aelar", "Baelen", "Caelen", "Daeren", "Elandra", "Faelar", "Gaelen", "Haeral", "Iaelen", "Jaelar"],
	"palace_guard": ["Marcus", "Lucius", "Gaius", "Octavius", "Flavius", "Julius", "Maximus", "Severus", "Valerius", "Antonius"],
	"villain": ["Malakar", "Vorath", "Drazik", "Nexor", "Zarak", "Morvain", "Thulak", "Xerion", "Korvus", "Draven"]
}

var last_names = {
	"elves": ["Moonwhisper", "Starbreeze", "Greenleaf", "Nightwalker", "Dawnstrider", "Shadowbane", "Lightbringer", "Windrider", "Earthshaker", "Fireheart"],
	"palace_guard": ["Valerius", "Antonius", "Flavius", "Julius", "Maximus", "Severus", "Octavius", "Gaius", "Lucius", "Marcus"],
	"villain": ["Darkheart", "Shadowbane", "Nightshade", "Bloodmoon", "Skullcrusher", "Doombringer", "Deathbringer", "Soulreaper", "Bonecrusher", "Fleshrender"]
}

var species = ["human", "elf", "dwarf", "orc", "halfling"]
var professions = ["warrior", "mage", "rogue", "merchant", "farmer", "blacksmith", "alchemist", "priest", "guard", "bandit"]
var personalities = ["friendly", "neutral", "hostile", "shy", "outgoing", "wise", "foolish", "brave", "cowardly", "greedy"]

func _ready():
	pass

# Генерация NPC на основе фракции
func generate_npc(faction, level=1):
	var npc_data = {
		"name": "",
		"faction": faction,
		"species": "",
		"profession": "",
		"personality": "",
		"level": level,
		"stats": {},
		"inventory": [],
		"dialogue": []
	}
	
	# Генерация имени на основе фракции
	if first_names.has(faction) and last_names.has(faction):
		var first_name = first_names[faction][randi() % first_names[faction].size()]
		var last_name = last_names[faction][randi() % last_names[faction].size()]
		npc_data.name = first_name + " " + last_name
	else:
		# Если фракция не найдена, генерируем случайное имя
		var first_name_list = []
		for key in first_names.keys():
			first_name_list.append_array(first_names[key])
		var last_name_list = []
		for key in last_names.keys():
			last_name_list.append_array(last_names[key])
		
		var first_name = first_name_list[randi() % first_name_list.size()]
		var last_name = last_name_list[randi() % last_name_list.size()]
		npc_data.name = first_name + " " + last_name
	
	# Генерация вида
	npc_data.species = species[randi() % species.size()]
	
	# Генерация профессии
	npc_data.profession = professions[randi() % professions.size()]
	
	# Генерация личности
	npc_data.personality = personalities[randi() % personalities.size()]
	
	# Генерация характеристик
	npc_data.stats = generate_stats(npc_data.profession, level)
	
	# Генерация инвентаря
	npc_data.inventory = generate_inventory(npc_data.profession, level)
	
	# Генерация диалогов
	npc_data.dialogue = generate_dialogue(npc_data.profession, npc_data.personality)
	
	return npc_data

# Генерация характеристик NPC
func generate_stats(profession, level):
	var stats = {
		"strength": 0,
		"dexterity": 0,
		"intelligence": 0,
		"constitution": 0,
		"charisma": 0,
		"wisdom": 0
	}
	
	# Базовые значения характеристик
	var base_stats = {
		"strength": randi_range(5, 10),
		"dexterity": randi_range(5, 10),
		"intelligence": randi_range(5, 10),
		"constitution": randi_range(5, 10),
		"charisma": randi_range(5, 10),
		"wisdom": randi_range(5, 10)
	}
	
	# Модификаторы по профессии
	match profession:
		"warrior":
			base_stats.strength += 5
			base_stats.constitution += 3
		"mage":
			base_stats.intelligence += 5
			base_stats.wisdom += 3
		"rogue":
			base_stats.dexterity += 5
			base_stats.charisma += 3
		"merchant":
			base_stats.charisma += 5
			base_stats.intelligence += 2
		"priest":
			base_stats.wisdom += 5
			base_stats.charisma += 3
		"guard":
			base_stats.strength += 3
			base_stats.constitution += 3
			base_stats.dexterity += 2
		"bandit":
			base_stats.dexterity += 4
			base_stats.strength += 2
			base_stats.charisma -= 2
	
	# Увеличение характеристик с уровнем
	for stat in base_stats.keys():
		stats[stat] = base_stats[stat] + (level - 1) * 2
	
	return stats

# Генерация инвентаря NPC
func generate_inventory(profession, level):
	var inventory = []
	
	# Базовые предметы для всех NPC
	inventory.append("health_potion")
	
	# Предметы по профессии
	match profession:
		"warrior":
			inventory.append("sword")
			inventory.append("shield")
			inventory.append("armor")
		"mage":
			inventory.append("staff")
			inventory.append("spellbook")
			if level >= 3:
				inventory.append("mana_potion")
		"rogue":
			inventory.append("dagger")
			inventory.append("lockpick")
			if level >= 2:
				inventory.append("smoke_bomb")
		"merchant":
			for i in range(randi_range(5, 15)):
				inventory.append("random_item")
		"priest":
			inventory.append("holy_symbol")
			inventory.append("healing_potion")
			if level >= 3:
				inventory.append("divine_scroll")
		"guard":
			inventory.append("sword")
			inventory.append("armor")
			if level >= 2:
				inventory.append("shield")
		"bandit":
			inventory.append("dagger")
			if randf() < 0.3:
				inventory.append("stolen_goods")
	
	# Дополнительные предметы в зависимости от уровня
	for i in range(level - 1):
		if randf() < 0.3:
			inventory.append("random_loot")
	
	return inventory

# Генерация диалогов NPC
func generate_dialogue(profession, personality):
	var dialogue = []
	
	# Базовые фразы
	dialogue.append("Приветствую, путник.")
	dialogue.append("Что привело тебя сюда?")
	
	# Фразы по профессии
	match profession:
		"merchant":
			dialogue.append("У меня есть много интересных товаров.")
			dialogue.append("Цены на редкие предметы растут!")
		"guard":
			dialogue.append("Будь осторожен в этих краях.")
			dialogue.append("Здесь недавно замечали подозрительных личностей.")
		"priest":
			dialogue.append("Свет да будет с тобой.")
			dialogue.append("Молитва может исцелить даже самые глубокие раны.")
		"bandit":
			dialogue.append("Отдавай все свои деньги!")
			dialogue.append("Здесь ты не пройдешь без пошлины.")
	
	# Фразы по личности
	match personality:
		"friendly":
			dialogue.append("Рад видеть тебя!")
			dialogue.append("Если тебе что-то понадобится, обращайся.")
		"hostile":
			dialogue.append("Я не доверяю незнакомцам.")
			dialogue.append("Лучше держись подальше.")
		"wise":
			dialogue.append("Мудрость приходит с опытом.")
			dialogue.append("Иногда лучше прислушаться к своему сердцу.")
		"greedy":
			dialogue.append("Золото решает многое в этом мире.")
			dialogue.append("У меня есть кое-что особенное... за правильную цену.")
	
	return dialogue

# Генерация группы NPC
func generate_npc_group(faction, count, avg_level=1):
	var group = []
	
	for i in range(count):
		# Уровень каждого NPC может немного отличаться от среднего
		var level = avg_level + randi_range(-1, 2)
		if level < 1:
			level = 1
		
		var npc = generate_npc(faction, level)
		group.append(npc)
	
	return group