# TextWorldRenderer.gd
# Класс для текстового представления игрового мира в MUD режиме

extends Node

# Отображение текущей локации
func render_current_location():
	# Здесь должна быть логика получения текущей локации игрока
	# и отображения её текстового описания
	
	var location_name = "Лесная тропа"
	var location_description = "Вы находитесь на узкой тропе, ведущей через густой лес. Солнечный свет едва пробивается сквозь листву."
	var visible_objects = ["старый меч", "труп ворона"]
	var visible_npcs = ["лесной стражник"]
	var exits = ["север", "юг"]
	
	# Отображение информации о локации
	print(location_name)
	print(location_description)
	print("")
	
	# Отображение видимых объектов
	if visible_objects.size() > 0:
		print("Видны: " + ", ".join(visible_objects))
	
	# Отображение видимых NPC
	if visible_npcs.size() > 0:
		print("NPC: " + ", ".join(visible_npcs))
	
	# Отображение доступных выходов
	if exits.size() > 0:
		print("Выходы: " + ", ".join(exits))
	
	print("")

# Отображение объекта
func render_object(object_name: String):
	# Здесь должна быть логика получения информации об объекте
	# и отображения её текстового описания
	
	print("Осмотр " + object_name + ":")
	print("Это обычный предмет.")
	print("")

# Отображение NPC
func render_npc(npc_name: String):
	# Здесь должна быть логика получения информации о NPC
	# и отображения её текстового описания
	
	print("Осмотр " + npc_name + ":")
	print("Это обычный NPC.")
	print("")

# Отображение карты окрестностей
func render_map():
	# Здесь должна быть логика генерации текстового представления карты
	
	print("Карта окрестностей:")
	print("  [Лесной храм] - [Городские ворота]")
	print("         |                |")
	print("  [Лесная тропа] - [Дворцовая площадь]")
	print("         |                |")
	print("  [Руины замка] - [Торговая улица]")
	print("")