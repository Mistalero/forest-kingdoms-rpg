# P2PMUDExample.gd
# Пример использования P2P MUD адаптера

extends Node

# Ссылка на MUD режим
var mud_mode = null

# Ссылка на P2P адаптер
var p2p_adapter = null

func _ready():
	# Инициализация примера
	initialize_example()

# Инициализация примера
func initialize_example():
	print("Initializing P2P MUD Example...")
	
	# Создание экземпляра MUD режима
	mud_mode = preload("res://src/mud/MUDMode.gd").new()
	
	# Инициализация компонентов MUD режима
	mud_mode._initialize_components()
	mud_mode._initialize_protocols()
	
	# Инициализация P2P адаптера
	p2p_adapter = preload("res://src/mud/P2PMUDAdapter.gd").new()
	
	if p2p_adapter.initialize(mud_mode):
		print("P2P MUD Adapter initialized successfully")
		
		# Демонстрация функциональности
		run_demo()
	else:
		push_error("Failed to initialize P2P MUD Adapter")

# Запуск демонстрации
func run_demo():
	print("Running P2P MUD Demo...")
	
	# Демонстрация обновления игрового состояния
	demo_game_state_update()
	
	# Демонстрация обновления позиции игрока
	demo_player_position_update()
	
	# Демонстрация работы с инвентарем
	demo_inventory_operations()
	
	# Демонстрация работы с квестами
	demo_quest_operations()
	
	# Демонстрация создания игровой сессии
	demo_session_creation()

# Демонстрация обновления игрового состояния
func demo_game_state_update():
	print("Demonstrating game state update...")
	
	if p2p_adapter != null:
		var game_state = {
			"current_area": "forest",
			"game_time": 1200,
			"world_state": {
				"weather": "sunny",
				"season": "spring"
			}
		}
		
		p2p_adapter.update_game_state(game_state)
		print("Game state updated")

# Демонстрация обновления позиции игрока
func demo_player_position_update():
	print("Demonstrating player position update...")
	
	if p2p_adapter != null:
		var position = {
			"x": 100,
			"y": 50,
			"z": 0,
			"area": "forest"
		}
		
		p2p_adapter.update_player_position(position)
		print("Player position updated")

# Демонстрация работы с инвентарем
func demo_inventory_operations():
	print("Demonstrating inventory operations...")
	
	if p2p_adapter != null:
		# Добавление предметов в инвентарь
		p2p_adapter.add_item_to_inventory("sword")
		p2p_adapter.add_item_to_inventory("shield")
		p2p_adapter.add_item_to_inventory("potion")
		
		print("Items added to inventory")

# Демонстрация работы с квестами
func demo_quest_operations():
	print("Demonstrating quest operations...")
	
	if p2p_adapter != null:
		# Добавление квестов игроку
		p2p_adapter.add_quest_to_player("Find the lost artifact")
		p2p_adapter.add_quest_to_player("Defeat the forest monster")
		
		print("Quests added to player")

# Демонстрация создания игровой сессии
func demo_session_creation():
	print("Demonstrating session creation...")
	
	if p2p_adapter != null:
		# Создание игровой сессии
		var session_id = p2p_adapter.create_game_session("Forest Adventure", 4)
		
		if session_id != -1:
			print("Game session created with ID: ", session_id)
			
			# Получение списка доступных сессий
			var sessions = p2p_adapter.get_available_sessions()
			print("Available sessions: ", sessions.size())
			
			# Подключение к сессии
			p2p_adapter.join_game_session(session_id)
			print("Joined game session")
		else:
			push_error("Failed to create game session")