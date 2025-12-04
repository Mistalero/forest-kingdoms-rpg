extends Node

# Скрипт для процедурной генерации ландшафта
# Использует шум Перлина для создания рельефа

# Параметры генерации
var seed_value = 0
var width = 100
var height = 100
var scale = 0.1
var octaves = 4
var persistence = 0.5
var lacunarity = 2.0

# Режим низкой производительности
var low_performance_mode = false

func _ready():
	# Инициализация генератора случайных чисел
	randomize()
	seed_value = randi()

# Установка режима низкой производительности
func set_low_performance_mode(enabled: bool):
	low_performance_mode = enabled
	if low_performance_mode:
		# Уменьшаем сложность генерации для слабых систем
		width = 50
		height = 50
		octaves = 2
		scale = 0.05
		print("Включен режим низкой производительности для генерации ландшафта")
	else:
		# Восстанавливаем нормальные параметры
		width = 100
		height = 100
		octaves = 4
		scale = 0.1
		print("Выключен режим низкой производительности для генерации ландшафта")

# Генерация высотной карты с использованием шума Перлина
func generate_heightmap():
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
func noise(x, y):
	# Это упрощенная реализация для демонстрации
	# В реальном проекте использовать FastNoiseLite
	return sin(x) * cos(y) * 0.5 + 0.5

# Генерация биомов на основе высоты
func generate_biomes(heightmap):
	var biomes = []
	
	for x in range(width):
		var row = []
		for y in range(height):
			var height_value = heightmap[x][y]
			
			# Определение биома на основе высоты
			if height_value < 0.2:
				row.append("water")
			elif height_value < 0.3:
				row.append("beach")
			elif height_value < 0.5:
				row.append("plains")
			elif height_value < 0.7:
				row.append("forest")
			elif height_value < 0.9:
				row.append("mountains")
			else:
				row.append("snowy_mountains")
		
		biomes.append(row)
	
	return biomes

# Генерация растительности для каждого биома
func generate_vegetation(biomes):
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
						if randf() < 0.1:  # Меньше растительности
							plants.append("tree")
					"plains":
						if randf() < 0.3:  # Меньше растительности
							plants.append("grass")
					"mountains":
						if randf() < 0.05:  # Меньше растительности
							plants.append("rock")
			else:
				# Нормальная генерация
				match biome:
					"forest":
						# В лесу генерируем деревья и кустарники
						if randf() < 0.3:
							plants.append("tree")
						if randf() < 0.5:
							plants.append("bush")
					"plains":
						# На равнинах генерируем траву и цветы
						if randf() < 0.7:
							plants.append("grass")
						if randf() < 0.2:
							plants.append("flower")
					"mountains":
						# В горах генерируем камни и редкую растительность
						if randf() < 0.1:
							plants.append("rock")
						if randf() < 0.1:
							plants.append("mountain_plant")
			
			row.append(plants)
		
		vegetation.append(row)
	
	return vegetation