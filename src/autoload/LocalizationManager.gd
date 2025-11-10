extends Node

# Менеджер локализации для Forest Kingdoms RPG

# Словарь с переводами
var translations = {}

# Текущий язык
var current_language = "en"

# Список поддерживаемых языков
var supported_languages = ["ru", "en", "zh"]

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
		var headers = file.get_line().split(",")
		
		# Читаем строки с переводами
		while not file.eof_reached():
			var line = file.get_line()
			if line != "":
				var parts = line.split(",")
				var id = parts[0]
				translations[id] = {}
				
				# Сохраняем переводы для каждого языка
				for i in range(1, min(parts.size(), headers.size())):
					var lang = headers[i]
					translations[id][lang] = parts[i]
		
		file.close()

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