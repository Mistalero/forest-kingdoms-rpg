extends Node

# Менеджер локализации для Forest Kingdoms RPG

# Словарь с переводами
var translations = {}

# Текущий язык
var current_language = "en"

# Список поддерживаемых языков
var supported_languages = ["ru", "en", "zh"]

# Вызывается при инициализации узла
func _ready():
	# Загружаем переводы из CSV-файла
	load_translations()
	
	# Устанавливаем язык по умолчанию (английский)
	set_language("en")

# Загрузка переводов из CSV-файла
func load_translations():
	var file = FileAccess.open("res://locale/translations.csv", FileAccess.READ)
	if file:
		# Читаем заголовки столбцов
		var headers = _read_csv_line(file)
		
		# Читаем строки с переводами
		while not file.eof_reached():
			var line = file.get_line()
			if line != "" and not line.begins_with("#"): # Пропускаем пустые строки и комментарии
				var parts = _read_csv_line(file, line)
				if parts.size() > 0:
					var id = parts[0]
					translations[id] = {}
					
					# Сохраняем переводы для каждого языка
					for i in range(1, min(parts.size(), headers.size())):
						var lang = headers[i]
						translations[id][lang] = parts[i]
		
		file.close()
	else:
		print("Не удалось открыть файл локализации")

# Вспомогательная функция для чтения строки CSV с учетом кавычек
func _read_csv_line(file, line = ""):
	if line == "":
		line = file.get_line()
	
	var parts = []
	var current_part = ""
	var in_quotes = false
	
	for i in range(line.length()):
		var char = line[i]
		if char == '"':
			in_quotes = !in_quotes
		elif char == ',' and not in_quotes:
			parts.append(current_part)
			current_part = ""
		else:
			current_part += char
	
	parts.append(current_part)
	return parts

# Установка текущего языка
func set_language(lang):
	if lang in supported_languages:
		current_language = lang
	else:
		print("Язык не поддерживается: ", lang)

# Получение переведенной строки по идентификатору
func get_string(id):
	if translations.has(id) and translations[id].has(current_language):
		return translations[id][current_language]
	else:
		print("Перевод не найден для идентификатора: ", id)
		return id

# Получение списка поддерживаемых языков
func get_supported_languages():
	return supported_languages