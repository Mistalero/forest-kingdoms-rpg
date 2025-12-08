extends Node3D

# Основной скрипт игры Forest Kingdoms RPG

# Вызывается при загрузке сцены
func _ready():
	_display_startup_messages()
	
# Вызывается каждый кадр
func _process(delta):
	pass

# Отображает стартовые сообщения игры
func _display_startup_messages():
	print(LocalizationManager.get_string("GAME_LOADED"))
	print(LocalizationManager.get_string("CHOOSE_FACTION"))
	print(LocalizationManager.get_string("FOREST_ELVES"))
	print(LocalizationManager.get_string("PALACE_GUARD"))
	print(LocalizationManager.get_string("VILLAINS"))
	
	# Пример использования мемных элементов
	print(LocalizationManager.get_string("MEME_EXAMPLE_1"))
	print(LocalizationManager.get_string("MEME_EXAMPLE_2"))
	print(LocalizationManager.get_string("MEME_EXAMPLE_3"))