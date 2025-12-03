# P2PMUDAdapter.gd
# Адаптер для интеграции MUD режима с децентрализованной P2P архитектурой

extends Node

# Ссылка на P2P фреймворк
var p2p_framework = null

# Ссылка на MUD режим
var mud_mode = null

# CRDT для игрового состояния
var game_state_crdt = null

# CRDT для позиции игрока
var player_position_crdt = null

# CRDT для инвентаря игрока
var player_inventory_crdt = null

# CRDT для квестов игрока
var player_quests_crdt = null

# Инициализация адаптера
func initialize(mud_instance) -> bool:
	mud_mode = mud_instance
	
	# Получение экземпляра P2P фреймворка
	p2p_framework = P2PFramework.get_instance()
	
	if p2p_framework == null:
		push_error("P2P framework not initialized")
		return false
	
	# Подключение к сигналам P2P фреймворка
	connect_to_p2p_signals()
	
	# Создание CRDT для игрового состояния
	create_game_state_crdts()
	
	# Запуск P2P фреймворка если он еще не запущен
	if not p2p_framework.is_running:
		p2p_framework.start()
	
	print("P2P MUD Adapter initialized successfully")
	return true

# Подключение к сигналам P2P фреймворка
func connect_to_p2p_signals():
	p2p_framework.connect("peer_connected", Callable(self, "_on_peer_connected"))
	p2p_framework.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))
	p2p_framework.connect("message_received", Callable(self, "_on_message_received"))
	p2p_framework.connect("error_occurred", Callable(self, "_on_error_occurred"))

# Создание CRDT для игрового состояния
func create_game_state_crdts():
	# Создание CRDT для игрового состояния
	game_state_crdt = p2p_framework.create_game_state_crdt("game-state", "LWWRegister", {
		"current_area": "main_menu",
		"game_time": 0,
		"world_state": {}
	})
	
	# Создание CRDT для позиции игрока
	player_position_crdt = p2p_framework.create_game_state_crdt("player-position", "LWWRegister", {
		"x": 0,
		"y": 0,
		"z": 0,
		"area": "main_menu"
	})
	
	# Создание CRDT для инвентаря игрока
	player_inventory_crdt = p2p_framework.create_game_state_crdt("player-inventory", "ORSet", [])
	
	# Создание CRDT для квестов игрока
	player_quests_crdt = p2p_framework.create_game_state_crdt("player-quests", "ORSet", [])
	
	print("Game state CRDTs created")

# Обновление игрового состояния
func update_game_state(state_data):
	if game_state_crdt != null:
		game_state_crdt.set(state_data)
		print("Game state updated: ", state_data)

# Обновление позиции игрока
func update_player_position(position_data):
	if player_position_crdt != null:
		player_position_crdt.set(position_data)
		print("Player position updated: ", position_data)

# Добавление предмета в инвентарь игрока
func add_item_to_inventory(item):
	if player_inventory_crdt != null:
		# Для ORSet нужно использовать соответствующий метод
		# В реальной реализации здесь будет код для добавления элемента в ORSet
		print("Item added to inventory: ", item)

# Добавление квеста игроку
func add_quest_to_player(quest):
	if player_quests_crdt != null:
		# Для ORSet нужно использовать соответствующий метод
		# В реальной реализации здесь будет код для добавления элемента в ORSet
		print("Quest added to player: ", quest)

# Отправка сообщения другому игроку
func send_message_to_player(peer_id: int, message_type: String, message_data: Dictionary):
	if p2p_framework != null:
		p2p_framework.send_message(peer_id, message_type, message_data)
		print("Message sent to player ", peer_id, ": ", message_type, " - ", message_data)

# Создание игровой сессии
func create_game_session(session_name: String, max_players: int) -> int:
	if p2p_framework != null:
		var session_id = p2p_framework.create_session(session_name, max_players)
		if session_id != -1:
			print("Game session created: ", session_name, " (ID: ", session_id, ")")
			return session_id
		else:
			push_error("Failed to create game session")
	
	return -1

# Подключение к игровой сессии
func join_game_session(session_id: int):
	if p2p_framework != null:
		p2p_framework.join_session(session_id)
		print("Joining game session: ", session_id)

# Получение списка доступных сессий
func get_available_sessions() -> Array:
	if p2p_framework != null:
		return p2p_framework.get_available_sessions()
	
	return []

# Обработчики сигналов P2P
func _on_peer_connected(peer_id: int):
	print("New peer connected: ", peer_id)
	
	# Отправка приветственного сообщения новому игроку
	var welcome_data = {
		"message": "Welcome to Forest Kingdoms RPG!",
		"server_info": {
			"name": "Forest Kingdoms RPG P2P Node",
			"version": "1.0.0"
		}
	}
	
	send_message_to_player(peer_id, "welcome", welcome_data)

func _on_peer_disconnected(peer_id: int):
	print("Peer disconnected: ", peer_id)

func _on_message_received(message_data: Dictionary):
	print("Received message: ", message_data)
	
	# Обработка сообщения в зависимости от типа
	match message_data.type:
		"chat":
			handle_chat_message(message_data)
		"move":
			handle_move_message(message_data)
		"action":
			handle_action_message(message_data)
		"request_state":
			handle_state_request(message_data)
		_:
			print("Unknown message type: ", message_data.type)

func _on_error_occurred(error_code: int, error_message: String):
	printerr("P2P error occurred: ", error_code, " - ", error_message)

# Обработчики сообщений
func handle_chat_message(message_data: Dictionary):
	var chat_data = message_data.data
	print("[CHAT] ", chat_data.sender, ": ", chat_data.text)
	
	# Отображение сообщения в MUD интерфейсе
	if mud_mode != null and mud_mode.text_interface != null:
		mud_mode.text_interface.display_text("[CHAT] " + chat_data.sender + ": " + chat_data.text)

func handle_move_message(message_data: Dictionary):
	var move_data = message_data.data
	print("Player moved: ", move_data)
	
	# Обновление позиции игрока
	update_player_position(move_data)

func handle_action_message(message_data: Dictionary):
	var action_data = message_data.data
	print("Player action: ", action_data)
	
	# Обработка действия игрока
	process_player_action(action_data)

func handle_state_request(message_data: Dictionary):
	print("State request from peer: ", message_data.sender)
	
	# Отправка текущего состояния игры
	if game_state_crdt != null:
		var state_data = game_state_crdt.get()
		send_message_to_player(message_data.sender, "state_update", state_data)

# Обработка действия игрока
func process_player_action(action_data: Dictionary):
	match action_data.action:
		"take_item":
			handle_take_item(action_data)
		"drop_item":
			handle_drop_item(action_data)
		"attack":
			handle_attack(action_data)
		"cast_spell":
			handle_cast_spell(action_data)
		_:
			print("Unknown player action: ", action_data.action)

# Обработка взятия предмета
func handle_take_item(action_data: Dictionary):
	print("Player took item: ", action_data.item)
	
	# Добавление предмета в инвентарь
	add_item_to_inventory(action_data.item)
	
	# Обновление интерфейса MUD
	if mud_mode != null and mud_mode.text_interface != null:
		mud_mode.text_interface.display_success("Вы взяли " + action_data.item)

# Обработка выбрасывания предмета
func handle_drop_item(action_data: Dictionary):
	print("Player dropped item: ", action_data.item)
	
	# Удаление предмета из инвентаря
	# В реальной реализации здесь будет код для удаления элемента из ORSet
	
	# Обновление интерфейса MUD
	if mud_mode != null and mud_mode.text_interface != null:
		mud_mode.text_interface.display_text("Вы выбросили " + action_data.item)

# Обработка атаки
func handle_attack(action_data: Dictionary):
	print("Player attacked: ", action_data.target)
	
	# Обновление интерфейса MUD
	if mud_mode != null and mud_mode.text_interface != null:
		mud_mode.text_interface.display_text("Вы атаковали " + action_data.target)

# Обработка заклинания
func handle_cast_spell(action_data: Dictionary):
	print("Player cast spell: ", action_data.spell)
	
	# Обновление интерфейса MUD
	if mud_mode != null and mud_mode.text_interface != null:
		mud_mode.text_interface.display_text("Вы произнесли заклинание " + action_data.spell)

# Отправка игрового состояния через GMCP
func send_game_state_via_gmcp():
	if mud_mode != null and mud_mode.gmcp_protocol != null:
		# Отправка информации о персонаже
		if game_state_crdt != null:
			var game_state = game_state_crdt.get()
			mud_mode.gmcp_protocol.send_character_info({
				"name": "Player",
				"fullname": "Forest Kingdoms RPG Player",
				"gender": "unknown",
				"hp": 100,
				"maxhp": 100,
				"mp": 50,
				"maxmp": 50,
				"sp": 30,
				"maxsp": 30,
				"xp": 0,
				"gold": 0,
				"level": 1
			})
		
		# Отправка информации о комнате
		mud_mode.gmcp_protocol.send_room_info({
			"id": 1,
			"name": "Главное меню",
			"area": "Forest Kingdoms RPG",
			"environment": "indoor",
			"coordinates": {"x": 0, "y": 0, "z": 0},
			"players": [],
			"mobs": [],
			"items": []
		})