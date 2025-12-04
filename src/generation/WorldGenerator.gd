extends Node

# Основной скрипт для координации процедурной генерации мира

# Импорт скриптов генерации
var landscape_generator
var building_generator
var npc_generator
var quest_generator
var item_generator

# Параметры мира
var world_seed = 0
var world_size = Vector2(100, 100)

# Режим низкой производительности
var low_performance_mode = false

func _ready():
	# Инициализация генераторов
	initialize_generators()
	
	# Генерация начального мира
	generate_world()

# Инициализация всех генераторов
func initialize_generators():
	landscape_generator = preload("res://src/generation/LandscapeGenerator.gd").new()
	building_generator = preload("res://src/generation/BuildingGenerator.gd").new()
	npc_generator = preload("res://src/generation/NPCGenerator.gd").new()
	quest_generator = preload("res://src/generation/QuestGenerator.gd").new()
	item_generator = preload("res://src/generation/ItemGenerator.gd").new()

# Установка режима низкой производительности
func set_low_performance_mode(enabled: bool):
	low_performance_mode = enabled
	if landscape_generator != null:
		landscape_generator.set_low_performance_mode(enabled)
	
	print("Режим низкой производительности для генерации мира: ", enabled)

# Генерация всего мира
func generate_world():
	print("Начало генерации мира...")
	
	# Генерация ландшафта
	var heightmap = landscape_generator.generate_heightmap()
	var biomes = landscape_generator.generate_biomes(heightmap)
	var vegetation = landscape_generator.generate_vegetation(biomes)
	
	print("Ландшафт сгенерирован")
	
	# Генерация зданий для каждой фракции
	var factions = ["elves", "palace_guard", "villain"]
	var faction_buildings = {}
	
	for faction in factions:
		if low_performance_mode:
			# Уменьшаем количество зданий для слабых систем
			faction_buildings[faction] = building_generator.generate_city_layout(faction, Vector2(10, 10))
		else:
			faction_buildings[faction] = building_generator.generate_city_layout(faction, Vector2(20, 20))
	
	print("Здания сгенерированы")
	
	# Генерация NPC
	var faction_npcs = {}
	
	for faction in factions:
		if low_performance_mode:
			# Уменьшаем количество NPC для слабых систем
			faction_npcs[faction] = npc_generator.generate_npc_group(faction, randi_range(5, 10), randi_range(1, 3))
		else:
			faction_npcs[faction] = npc_generator.generate_npc_group(faction, randi_range(10, 20), randi_range(1, 5))
	
	print("NPC сгенерированы")
	
	# Генерация квестов
	var faction_quests = {}
	
	for faction in factions:
		faction_quests[faction] = []
		var quest_count = low_performance_mode ? 3 : 5
		for i in range(quest_count):
			var quest = quest_generator.generate_random_quest(faction, randi_range(1, 5))
			faction_quests[faction].append(quest)
	
	print("Квесты сгенерированы")
	
	# Генерация предметов
	var item_count = low_performance_mode ? randi_range(20, 50) : randi_range(50, 100)
	var world_items = item_generator.generate_item_set(item_count, randi_range(1, 10))
	
	print("Предметы сгенерированы")
	
	# Сохранение сгенерированных данных
	save_world_data({
		"heightmap": heightmap,
		"biomes": biomes,
		"vegetation": vegetation,
		"buildings": faction_buildings,
		"npcs": faction_npcs,
		"quests": faction_quests,
		"items": world_items
	})
	
	print("Мир успешно сгенерирован!")

# Генерация отдельной игровой зоны
func generate_zone(zone_name, faction, size):
	print("Генерация зоны: " + zone_name)
	
	var zone_data = {
		"name": zone_name,
		"faction": faction,
		"size": size,
		"landscape": {},
		"buildings": [],
		"npcs": [],
		"quests": [],
		"items": []
	}
	
	# Генерация ландшафта для зоны
	landscape_generator.width = size.x
	landscape_generator.height = size.y
	var heightmap = landscape_generator.generate_heightmap()
	var biomes = landscape_generator.generate_biomes(heightmap)
	var vegetation = landscape_generator.generate_vegetation(biomes)
	
	zone_data.landscape = {
		"heightmap": heightmap,
		"biomes": biomes,
		"vegetation": vegetation
	}
	
	# Генерация зданий
	zone_data.buildings = building_generator.generate_city_layout(faction, size)
	
	# Генерация NPC
	var npc_count = low_performance_mode ? randi_range(3, 8) : randi_range(5, 15)
	zone_data.npcs = npc_generator.generate_npc_group(faction, npc_count, randi_range(1, 5))
	
	# Генерация квестов
	var quest_count = low_performance_mode ? randi_range(2, 5) : randi_range(3, 8)
	for i in range(quest_count):
		var quest = quest_generator.generate_random_quest(faction, randi_range(1, 5))
		zone_data.quests.append(quest)
	
	# Генерация предметов
	var item_count = low_performance_mode ? randi_range(5, 15) : randi_range(10, 30)
	zone_data.items = item_generator.generate_item_set(item_count, randi_range(1, 10))
	
	return zone_data

# Генерация контента для уже существующего мира (например, при переходе в новую зону)
func generate_dynamic_content(zone_name, player_level):
	print("Генерация динамического контента для зоны: " + zone_name)
	
	var content = {
		"npcs": [],
		"quests": [],
		"items": [],
		"enemies": []
	}
	
	# Генерация случайных NPC
	var npc_count = low_performance_mode ? randi_range(1, 3) : randi_range(1, 5)
	for i in range(npc_count):
		var faction = ["elves", "palace_guard", "villain"][randi() % 3]
		var level_range = low_performance_mode ? randi_range(player_level - 1, player_level) : randi_range(player_level - 1, player_level + 2)
		var npc = npc_generator.generate_npc(faction, level_range)
		content.npcs.append(npc)
	
	# Генерация случайных квестов
	var quest_count = low_performance_mode ? randi_range(0, 2) : randi_range(0, 3)
	for i in range(quest_count):
		var faction = ["elves", "palace_guard", "villain"][randi() % 3]
		var quest = quest_generator.generate_random_quest(faction, player_level)
		content.quests.append(quest)
	
	# Генерация случайных предметов
	var item_count = low_performance_mode ? randi_range(3, 10) : randi_range(5, 15)
	content.items = item_generator.generate_item_set(item_count, player_level)
	
	# Генерация случайных врагов
	var enemy_count = low_performance_mode ? randi_range(0, 3) : randi_range(0, 5)
	for i in range(enemy_count):
		var enemy = npc_generator.generate_npc("bandit", randi_range(player_level, player_level + 3))
		content.enemies.append(enemy)
	
	return content

# Сохранение данных мира
func save_world_data(data):
	# В реальной реализации здесь будет код сохранения данных в файл
	# или в систему сохранений игры
	print("Сохранение данных мира...")
	
	# Для демонстрации просто выводим информацию о размере данных
	var data_size = 0
	for key in data.keys():
		# Упрощенный подсчет размера данных
		data_size += str(data[key]).length()
	
	print("Размер сохраненных данных: " + str(data_size) + " символов")

# Загрузка данных мира
func load_world_data():
	# В реальной реализации здесь будет код загрузки данных из файла
	# или из системы сохранений игры
	print("Загрузка данных мира...")
	return null