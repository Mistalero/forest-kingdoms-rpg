extends Node

# Скрипт для процедурной генерации предметов и снаряжения

# Типы предметов
var item_types = ["weapon", "armor", "potion", "scroll", "artifact", "resource", "tool"]

# Подтипы предметов
var weapon_types = ["sword", "axe", "bow", "staff", "dagger", "hammer", "spear"]
var armor_types = ["helmet", "chestplate", "leggings", "boots", "gloves", "shield"]
var potion_types = ["health", "mana", "strength", "dexterity", "intelligence", "invisibility"]
var resource_types = ["ore", "herb", "gem", "leather", "wood", "cloth"]

# Качество предметов
var quality_levels = ["common", "uncommon", "rare", "epic", "legendary"]

# Префиксы и суффиксы для генерации названий
var prefixes = {
	"common": ["", "", ""],
	"uncommon": ["Good", "Solid", "Sturdy"],
	"rare": ["Fine", "Superior", "Excellent"],
	"epic": ["Mighty", "Glorious", "Mystic"],
	"legendary": ["Divine", "Eternal", "Celestial"]
}

var suffixes = {
	"weapon": {
		"common": ["", "", ""],
		"uncommon": ["of Strength", "of Precision", ""],
		"rare": ["of Power", "of Accuracy", "of Speed"],
		"epic": ["of Destruction", "of Annihilation", "of the Elements"],
		"legendary": ["of the Gods", "of Legends", "of Eternity"]
	},
	"armor": {
		"common": ["", "", ""],
		"uncommon": ["of Protection", "of Defense", ""],
		"rare": ["of Resistance", "of Durability", "of Fortitude"],
		"epic": ["of Invincibility", "of Immortality", "of the Guardian"],
		"legendary": ["of the Gods", "of Legends", "of Eternity"]
	},
	"potion": {
		"common": ["", "", ""],
		"uncommon": ["of Minor", "of Lesser", ""],
		"rare": ["of Greater", "of Major", "of Significant"],
		"epic": ["of Supreme", "of Ultimate", "of Extreme"],
		"legendary": ["of Divine", "of Eternal", "of Celestial"]
	}
}

func _ready():
	pass

# Генерация предмета на основе типа и уровня
func generate_item(item_type, level=1):
	var item_data = {
		"name": "",
		"type": item_type,
		"subtype": "",
		"quality": "",
		"level": level,
		"stats": {},
		"effects": [],
		"value": 0
	}
	
	# Определение подтипа предмета
	item_data.subtype = get_subtype(item_type)
	
	# Определение качества предмета
	item_data.quality = quality_levels[randi() % quality_levels.size()]
	
	# Генерация названия предмета
	item_data.name = generate_item_name(item_type, item_data.subtype, item_data.quality)
	
	# Генерация характеристик предмета
	item_data.stats = generate_item_stats(item_type, item_data.subtype, item_data.quality, level)
	
	# Генерация эффектов предмета
	item_data.effects = generate_item_effects(item_type, item_data.subtype, item_data.quality, level)
	
	# Расчет стоимости предмета
	item_data.value = calculate_item_value(item_type, item_data.quality, level)
	
	return item_data

# Получение подтипа предмета
func get_subtype(item_type):
	match item_type:
		"weapon":
			return weapon_types[randi() % weapon_types.size()]
		"armor":
			return armor_types[randi() % armor_types.size()]
		"potion":
			return potion_types[randi() % potion_types.size()]
		"resource":
			return resource_types[randi() % resource_types.size()]
		_:
			return ""

# Генерация названия предмета
func generate_item_name(item_type, subtype, quality):
	var prefix = ""
	var suffix = ""
	
	# Выбор префикса на основе качества
	if prefixes.has(quality):
		var prefix_options = prefixes[quality]
		prefix = prefix_options[randi() % prefix_options.size()]
	
	# Выбор суффикса на основе типа и качества
	if suffixes.has(item_type) and suffixes[item_type].has(quality):
		var suffix_options = suffixes[item_type][quality]
		suffix = suffix_options[randi() % suffix_options.size()]
	
	# Формирование названия
	var name_parts = []
	if prefix != "":
		name_parts.append(prefix)
	
	name_parts.append(subtype.capitalize())
	
	if suffix != "":
		name_parts.append(suffix)
	
	return " ".join(name_parts)

# Генерация характеристик предмета
func generate_item_stats(item_type, subtype, quality, level):
	var stats = {}
	
	# Базовые характеристики в зависимости от типа предмета
	match item_type:
		"weapon":
			stats["damage"] = randi_range(5, 10) * level
			stats["speed"] = randf_range(0.8, 1.2)
			
			# Модификаторы по подтипу
			match subtype:
				"sword":
					stats["damage"] = int(stats["damage"] * 1.1)
				"axe":
					stats["damage"] = int(stats["damage"] * 1.2)
					stats["speed"] = stats["speed"] * 0.8
				"bow":
					stats["damage"] = int(stats["damage"] * 0.9)
					stats["speed"] = stats["speed"] * 1.2
				"staff":
					stats["damage"] = int(stats["damage"] * 0.8)
					stats["mana_bonus"] = randi_range(3, 7) * level
				"dagger":
					stats["damage"] = int(stats["damage"] * 0.7)
					stats["speed"] = stats["speed"] * 1.5
				"hammer":
					stats["damage"] = int(stats["damage"] * 1.3)
					stats["speed"] = stats["speed"] * 0.6
				"spear":
					stats["damage"] = int(stats["damage"] * 1.0)
					stats["range"] = 1.5
		
		"armor":
			stats["defense"] = randi_range(3, 8) * level
			stats["durability"] = randi_range(50, 100)
			
			# Модификаторы по подтипу
			match subtype:
				"helmet":
					stats["defense"] = int(stats["defense"] * 0.6)
				"chestplate":
					stats["defense"] = int(stats["defense"] * 1.2)
				"leggings":
					stats["defense"] = int(stats["defense"] * 0.9)
				"boots":
					stats["defense"] = int(stats["defense"] * 0.7)
					stats["movement_bonus"] = randf_range(0.05, 0.15)
				"gloves":
					stats["defense"] = int(stats["defense"] * 0.5)
					stats["dexterity_bonus"] = randi_range(1, 3)
				"shield":
					stats["defense"] = int(stats["defense"] * 1.0)
					stats["block_chance"] = randf_range(0.1, 0.3)
		
		"potion":
			stats["effect_strength"] = randi_range(10, 30) * level
			stats["duration"] = randi_range(30, 120)
			
			# Модификаторы по подтипу
			match subtype:
				"health":
					stats["heal_amount"] = stats["effect_strength"]
				"mana":
					stats["mana_restore"] = stats["effect_strength"]
				"strength", "dexterity", "intelligence":
					stats["stat_bonus"] = stats["effect_strength"] / 10
				"invisibility":
					stats["invisibility_duration"] = stats["duration"]
	
	# Модификаторы по качеству
	var quality_multiplier = 1.0
	match quality:
		"uncommon":
			quality_multiplier = 1.2
		"rare":
			quality_multiplier = 1.5
		"epic":
			quality_multiplier = 2.0
		"legendary":
			quality_multiplier = 3.0
	
	# Применение модификатора качества к числовым характеристикам
	for stat in stats.keys():
		if stats[stat] is int:
			stats[stat] = int(stats[stat] * quality_multiplier)
		elif stats[stat] is float:
			stats[stat] = stats[stat] * quality_multiplier
	
	return stats

# Генерация эффектов предмета
func generate_item_effects(item_type, subtype, quality, level):
	var effects = []
	
	# Специальные эффекты в зависимости от качества
	match quality:
		"rare":
			if randf() < 0.3:
				effects.append("occasional_bonus")
		"epic":
			if randf() < 0.5:
				effects.append("passive_ability")
			if randf() < 0.3:
				effects.append("on_hit_effect")
		"legendary":
			if randf() < 0.7:
				effects.append("unique_ability")
			if randf() < 0.5:
				effects.append("aura_effect")
			if randf() < 0.3:
				effects.append("transformation")
	
	# Эффекты по типу предмета
	match item_type:
		"weapon":
			if randf() < 0.2:
				effects.append("elemental_damage")
			if randf() < 0.1:
				effects.append("life_steal")
		"armor":
			if randf() < 0.2:
				effects.append("resistance")
			if randf() < 0.1:
				effects.append("regeneration")
		"potion":
			if randf() < 0.1:
				effects.append("additional_effect")
	
	return effects

# Расчет стоимости предмета
func calculate_item_value(item_type, quality, level):
	var base_value = 0
	
	# Базовая стоимость по типу предмета
	match item_type:
		"weapon":
			base_value = 50
		"armor":
			base_value = 75
		"potion":
			base_value = 25
		"scroll":
			base_value = 100
		"artifact":
			base_value = 500
		"resource":
			base_value = 10
		"tool":
			base_value = 30
	
	# Модификатор по качеству
	var quality_multiplier = 1.0
	match quality:
		"uncommon":
			quality_multiplier = 1.5
		"rare":
			quality_multiplier = 3.0
		"epic":
			quality_multiplier = 7.0
		"legendary":
			quality_multiplier = 15.0
	
	# Модификатор по уровню
	var level_multiplier = 1.0 + (level - 1) * 0.2
	
	return int(base_value * quality_multiplier * level_multiplier)

# Генерация случайного предмета
func generate_random_item(level=1):
	var item_type = item_types[randi() % item_types.size()]
	return generate_item(item_type, level)

# Генерация набора предметов
func generate_item_set(count, level=1):
	var items = []
	
	for i in range(count):
		var item = generate_random_item(level)
		items.append(item)
	
	return items