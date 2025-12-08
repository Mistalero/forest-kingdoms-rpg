extends Node

# Скрипт для процедурной генерации ландшафта
# Использует шум Перлина для создания рельефа

# Константы для параметров генерации
const DEFAULT_WIDTH = 100
const DEFAULT_HEIGHT = 100
const DEFAULT_SCALE = 0.1
const DEFAULT_OCTAVES = 4
const DEFAULT_PERSISTENCE = 0.5
const DEFAULT_LACUNARITY = 2.0

# Константы для режима низкой производительности
const LOW_PERF_WIDTH = 50
const LOW_PERF_HEIGHT = 50
const LOW_PERF_OCTAVES = 2
const LOW_PERF_SCALE = 0.05

# Константы для биомов
const BIOME_WATER_THRESHOLD = 0.2
const BIOME_BEACH_THRESHOLD = 0.3
const BIOME_PLAINS_THRESHOLD = 0.5
const BIOME_FOREST_THRESHOLD = 0.7
const BIOME_MOUNTAINS_THRESHOLD = 0.9

# Константы для растительности в режиме низкой производительности
const LOW_PERF_FOREST_DENSITY = 0.1
const LOW_PERF_PLAINS_DENSITY = 0.3
const LOW_PERF_MOUNTAINS_DENSITY = 0.05

# Константы для растительности в нормальном режиме
const NORMAL_FOREST_TREE_DENSITY = 0.3
const NORMAL_FOREST_BUSH_DENSITY = 0.5
const NORMAL_PLAINS_GRASS_DENSITY = 0.7
const NORMAL_PLAINS_FLOWER_DENSITY = 0.2
const NORMAL_MOUNTAINS_ROCK_DENSITY = 0.1
const NORMAL_MOUNTAINS_PLANT_DENSITY = 0.1

# Параметры генерации
var seed_value = 0
var width = DEFAULT_WIDTH
var height = DEFAULT_HEIGHT
var scale = DEFAULT_SCALE
var octaves = DEFAULT_OCTAVES
var persistence = DEFAULT_PERSISTENCE
var lacunarity = DEFAULT_LACUNARITY

# Режим низкой производительности
var low_performance_mode = false

# Вызывается при инициализации узла
func _ready():
	# Инициализация генератора случайных чисел
	randomize()
	seed_value = randi()

# Установка режима низкой производительности
# enabled: флаг включения режима низкой производительности
func set_low_performance_mode(enabled: bool):
	low_performance_mode = enabled
	if low_performance_mode:
		# Уменьшаем сложность генерации для слабых систем
		width = LOW_PERF_WIDTH
		height = LOW_PERF_HEIGHT
		octaves = LOW_PERF_OCTAVES
		scale = LOW_PERF_SCALE
		print("Включен режим низкой производительности для генерации ландшафта")
	else:
		# Восстанавливаем нормальные параметры
		width = DEFAULT_WIDTH
		height = DEFAULT_HEIGHT
		octaves = DEFAULT_OCTAVES
		scale = DEFAULT_SCALE
		print("Выключен режим низкой производительности для генерации ландшафта")

# Генерация высотной карты с использованием шума Перлина
func generate_heightmap():
	# Проверка корректности параметров
	if width <= 0 or height <= 0:
		print("Ошибка: недопустимые размеры карты")
		return []
	
	var heightmap = []
	
	# Создание 2D массива для хранения высот
	for x in range(width):
		var row = []
		for y in range(height):
			if low_performance_mode:
				# Упрощенный алгоритм для слабых систем
				var simple_value = (sin(x * 0.1) * cos(y * 0.1) * 0.5 + 0.5)
				row.append(simple_value)
			else:
				var amplitude = 1.0
				var frequency = 1.0
				var noise_height = 0.0
				
				# Генерация шума с несколькими октавами
				for i in range(octaves):
					var sample_x = (x + seed_value) * scale * frequency
					var sample_y = (y + seed_value) * scale * frequency
					
					# Используем встроенный шум Godot
					var perlin_value = noise(sample_x, sample_y)
					noise_height += perlin_value * amplitude
					
					amplitude *= persistence
					frequency *= lacunarity
				
				row.append(noise_height)
		heightmap.append(row)
	
	return heightmap

# Упрощенная реализация шума (в реальной реализации использовать FastNoiseLite)
# x: координата X
# y: координата Y
func noise(x, y):
	# Это упрощенная реализация для демонстрации
	# В реальном проекте использовать FastNoiseLite
	return sin(x) * cos(y) * 0.5 + 0.5

# Генерация биомов на основе высоты
# heightmap: высотная карта для определения биомов
func generate_biomes(heightmap):
	# Проверка входных данных
	if heightmap.size() == 0:
		print("Ошибка: пустая высотная карта")
		return []
	
	var biomes = []
	
	for x in range(width):
		var row = []
		for y in range(height):
			var height_value = heightmap[x][y]
			
			# Определение биома на основе высоты
			if height_value < BIOME_WATER_THRESHOLD:
				row.append("water")
			elif height_value < BIOME_BEACH_THRESHOLD:
				row.append("beach")
			elif height_value < BIOME_PLAINS_THRESHOLD:
				row.append("plains")
			elif height_value < BIOME_FOREST_THRESHOLD:
				row.append("forest")
			elif height_value < BIOME_MOUNTAINS_THRESHOLD:
				row.append("mountains")
			else:
				row.append("snowy_mountains")
		
		biomes.append(row)
	
	return biomes

# Генерация растительности для каждого биома
# biomes: карта биомов
func generate_vegetation(biomes):
	# Проверка входных данных
	if biomes.size() == 0:
		print("Ошибка: пустая карта биомов")
		return []
	
	var vegetation = []
	
	for x in range(width):
		var row = []
		for y in range(height):
			var biome = biomes[x][y]
			var plants = []
			
			# Генерация растительности в зависимости от биома
			if low_performance_mode:
				# Упрощенная генерация для слабых систем
				match biome:
					"forest":
						if randf() < LOW_PERF_FOREST_DENSITY:  # Меньше растительности
							plants.append("tree")
					"plains":
						if randf() < LOW_PERF_PLAINS_DENSITY:  # Меньше растительности
							plants.append("grass")
					"mountains":
						if randf() < LOW_PERF_MOUNTAINS_DENSITY:  # Меньше растительности
							plants.append("rock")
			else:
				# Нормальная генерация
				match biome:
					"forest":
						# В лесу генерируем деревья и кустарники
						if randf() < NORMAL_FOREST_TREE_DENSITY:
							plants.append("tree")
						if randf() < NORMAL_FOREST_BUSH_DENSITY:
							plants.append("bush")
					"plains":
						# На равнинах генерируем траву и цветы
						if randf() < NORMAL_PLAINS_GRASS_DENSITY:
							plants.append("grass")
						if randf() < NORMAL_PLAINS_FLOWER_DENSITY:
							plants.append("flower")
					"mountains":
						# В горах генерируем камни и редкую растительность
						if randf() < NORMAL_MOUNTAINS_ROCK_DENSITY:
							plants.append("rock")
						if randf() < NORMAL_MOUNTAINS_PLANT_DENSITY:
							plants.append("mountain_plant")
			
			row.append(plants)
		
		vegetation.append(row)
	
	return vegetation