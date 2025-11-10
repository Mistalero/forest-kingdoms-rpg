extends Node

# Скрипт для процедурной генерации зданий и сооружений

# Параметры генерации зданий
var building_types = ["house", "shop", "tower", "barracks", "temple"]
var faction_styles = {
	"elves": {"material": "wood", "color": "green", "decoration": "nature"},
	"palace_guard": {"material": "stone", "color": "gray", "decoration": "formal"},
	"villain": {"material": "dark_stone", "color": "black", "decoration": "ominous"}
}

func _ready():
	pass

# Генерация здания на основе типа и фракции
func generate_building(building_type, faction, position):
	var building_data = {
		"type": building_type,
		"faction": faction,
		"position": position,
		"size": Vector3(1, 1, 1),
		"material": "",
		"color": "",
		"decoration": "",
		"rooms": []
	}
	
	# Применение стиля фракции
	if faction_styles.has(faction):
		var style = faction_styles[faction]
		building_data.material = style.material
		building_data.color = style.color
		building_data.decoration = style.decoration
	
	# Определение размера в зависимости от типа здания
	match building_type:
		"house":
			building_data.size = Vector3(randf_range(2, 4), randf_range(2, 3), randf_range(2, 4))
		"shop":
			building_data.size = Vector3(randf_range(3, 5), randf_range(2, 3), randf_range(3, 5))
		"tower":
			building_data.size = Vector3(randf_range(2, 3), randf_range(5, 10), randf_range(2, 3))
		"barracks":
			building_data.size = Vector3(randf_range(5, 8), randf_range(3, 5), randf_range(5, 8))
		"temple":
			building_data.size = Vector3(randf_range(6, 10), randf_range(4, 6), randf_range(6, 10))
	
	# Генерация комнат внутри здания
	building_data.rooms = generate_rooms(building_type, building_data.size)
	
	return building_data

# Генерация комнат внутри здания
func generate_rooms(building_type, building_size):
	var rooms = []
	var room_count = 0
	
	# Определение количества комнат в зависимости от типа здания
	match building_type:
		"house":
			room_count = randi_range(3, 6)
		"shop":
			room_count = randi_range(2, 4)
		"tower":
			room_count = randi_range(5, 10)
		"barracks":
			room_count = randi_range(8, 15)
		"temple":
			room_count = randi_range(6, 12)
	
	# Генерация каждой комнаты
	for i in range(room_count):
		var room = {
			"id": i,
			"type": "",
			"size": Vector3(1, 1, 1),
			"position": Vector3(0, 0, 0),
			"purpose": ""
		}
		
		# Определение типа комнаты на основе здания
		var room_types = []
		match building_type:
			"house":
				room_types = ["bedroom", "kitchen", "living_room", "bathroom", "storage"]
			"shop":
				room_types = ["sales_floor", "storage", "office", "workshop"]
			"tower":
				room_types = ["bedroom", "library", "observatory", "laboratory", "storage"]
			"barracks":
				room_types = ["dormitory", "mess_hall", "armory", "training_room", "office"]
			"temple":
				room_types = ["sanctuary", "altar_room", "library", "dormitory", "storage"]
		
		room.type = room_types[randi() % room_types.size()]
		room.size = Vector3(
			randf_range(1, building_size.x * 0.8),
			randf_range(1, building_size.y * 0.8),
			randf_range(1, building_size.z * 0.8)
		)
		room.position = Vector3(
			randf_range(0, building_size.x - room.size.x),
			randf_range(0, building_size.y - room.size.y),
			randf_range(0, building_size.z - room.size.z)
		)
		
		# Определение назначения комнаты
		match room.type:
			"bedroom":
				room.purpose = "rest"
			"kitchen", "mess_hall":
				room.purpose = "food"
			"library", "laboratory", "workshop":
				room.purpose = "work"
			"sanctuary", "altar_room":
				room.purpose = "worship"
			"training_room":
				room.purpose = "training"
			"storage":
				room.purpose = "storage"
			"sales_floor", "office":
				room.purpose = "business"
			"observatory":
				room.purpose = "observation"
			"living_room":
				room.purpose = "relaxation"
			"bathroom":
				room.purpose = "hygiene"
			"dormitory":
				room.purpose = "rest"
			"armory":
				room.purpose = "storage"
		
		rooms.append(room)
	
	return rooms

# Генерация случайного городского квартала
func generate_city_block(faction, position):
	var block_data = {
		"position": position,
		"faction": faction,
		"buildings": []
	}
	
	# Определение количества зданий в квартале
	var building_count = randi_range(5, 15)
	
	# Генерация зданий
	for i in range(building_count):
		var building_type = building_types[randi() % building_types.size()]
		var building_position = Vector3(
			position.x + randf_range(-20, 20),
			position.y,
			position.z + randf_range(-20, 20)
		)
		
		var building = generate_building(building_type, faction, building_position)
		block_data.buildings.append(building)
	
	return block_data