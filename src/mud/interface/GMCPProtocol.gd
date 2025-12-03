# GMCPProtocol.gd
# Реализация Generic MUD Communication Protocol (GMCP)

extends Node

# Поддерживаемые GMCP модули
var supported_modules = {
	"Core": ["Hello", "Goodbye", "Supports.Set", "Ping"],
	"Char": ["Name", "Status", "StatusVars", "Vitals", "Stats", "MaxStats", "Items", "Skills", "Quests"],
	"Room": ["Info", "Players", "AddPlayer", "RemovePlayer"],
	"Comm": ["Channel", "Tell"],
	"Group": ["Info", "Members"],
	"External": ["Discord.Info", "Discord.Hello"]
}

# Инициализация GMCP
func _init():
	pass

# Отправка GMCP данных клиенту
func send_gmcp_data(module: String, data):
	# В реальной реализации здесь будет код для отправки GMCP данных клиенту
	# Формат: IAC SB GMCP module JSON_data IAC SE
	print("GMCP: " + module + " " + JSON.print(data))

# Отправка поддерживаемых модулей
func send_supported_modules():
	var modules_list = []
	for module in supported_modules.keys():
		for sub_module in supported_modules[module]:
			modules_list.append(module + "." + sub_module)
	
	send_gmcp_data("Core.Supports.Set", modules_list)

# Отправка информации о персонаже
func send_character_info(character_data: Dictionary):
	send_gmcp_data("Char.Name", {
		"name": character_data.get("name", ""),
		"fullname": character_data.get("fullname", ""),
		"gender": character_data.get("gender", "")
	})
	
	send_gmcp_data("Char.Status", {
		"hp": character_data.get("hp", 0),
		"maxhp": character_data.get("maxhp", 0),
		"mp": character_data.get("mp", 0),
		"maxmp": character_data.get("maxmp", 0),
		"sp": character_data.get("sp", 0),
		"maxsp": character_data.get("maxsp", 0),
		"xp": character_data.get("xp", 0),
		"gold": character_data.get("gold", 0),
		"level": character_data.get("level", 1)
	})

# Отправка информации о комнате
func send_room_info(room_data: Dictionary):
	send_gmcp_data("Room.Info", {
		"num": room_data.get("id", 0),
		"name": room_data.get("name", ""),
		"area": room_data.get("area", ""),
		"environment": room_data.get("environment", ""),
		"coordinates": room_data.get("coordinates", {}),
		"players": room_data.get("players", []),
		"mobs": room_data.get("mobs", []),
		"items": room_data.get("items", [])
	})

# Отправка информации о предметах персонажа
func send_character_items(items_data: Dictionary):
	send_gmcp_data("Char.Items", items_data)

# Отправка информации о навыках персонажа
func send_character_skills(skills_data: Dictionary):
	send_gmcp_data("Char.Skills", skills_data)

# Отправка информации о квестах персонажа
func send_character_quests(quests_data: Dictionary):
	send_gmcp_data("Char.Quests", quests_data)

# Обработка GMCP команды от клиента
func handle_gmcp_command(module: String, data):
	match module:
		"Core.Hello":
			# Отправка приветственной информации
			send_gmcp_data("Core.Hello", {
				"client": "Forest Kingdoms RPG MUD Server",
				"version": "1.0.0"
			})
			# Отправка поддерживаемых модулей
			send_supported_modules()
		"Core.Ping":
			# Отправка ответа на пинг
			send_gmcp_data("Core.Ping", {})
		"Char.Vitals":
			# Отправка информации о жизненных показателях
			# В реальной реализации здесь будет код для отправки актуальных данных
			pass
		"Char.Items.Inv":
			# Отправка информации об инвентаре
			# В реальной реализации здесь будет код для отправки актуальных данных
			pass