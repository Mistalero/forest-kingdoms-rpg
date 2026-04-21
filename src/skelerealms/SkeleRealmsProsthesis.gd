class_name SkeleRealmsProsthesis
extends Node

## SkeleRealms Prosthesis System
## Система протезирования и восстановления конечностей

# Типы протезов
enum ProsthesisType {
	NONE,
	BASIC_WOODEN,
	BASIC_IRON,
	ADVANCED_MECHANICAL,
	MAGICAL_ELVEN,
	PALACE_TECHNOLOGY,
	VILLAIN_CYBORG
}

# Названия протезов
var prosthesis_names = {
	ProsthesisType.NONE: "None",
	ProsthesisType.BASIC_WOODEN: "Basic Wooden Limb",
	ProsthesisType.BASIC_IRON: "Basic Iron Limb",
	ProsthesisType.ADVANCED_MECHANICAL: "Advanced Mechanical Limb",
	ProsthesisType.MAGICAL_ELVEN: "Magical Elven Prosthesis",
	ProsthesisType.PALACE_TECHNOLOGY: "Palace Technology Implant",
	ProsthesisType.VILLAIN_CYBORG: "Villain Cyborg Enhancement"
}

# Характеристики протезов
var prosthesis_stats = {
	ProsthesisType.NONE: {"functionality": 0, "durability": 0, "weight": 0},
	ProsthesisType.BASIC_WOODEN: {"functionality": 50, "durability": 60, "weight": 8},
	ProsthesisType.BASIC_IRON: {"functionality": 60, "durability": 90, "weight": 15},
	ProsthesisType.ADVANCED_MECHANICAL: {"functionality": 75, "durability": 100, "weight": 12},
	ProsthesisType.MAGICAL_ELVEN: {"functionality": 85, "durability": 80, "weight": 5},
	ProsthesisType.PALACE_TECHNOLOGY: {"functionality": 90, "durability": 120, "weight": 10},
	ProsthesisType.VILLAIN_CYBORG: {"functionality": 95, "durability": 150, "weight": 18}
}

# Требования к фракциям
var faction_requirements = {
	ProsthesisType.BASIC_WOODEN: [],
	ProsthesisType.BASIC_IRON: [],
	ProsthesisType.ADVANCED_MECHANICAL: ["engineer"],
	ProsthesisType.MAGICAL_ELVEN: ["elf_faction"],
	ProsthesisType.PALACE_TECHNOLOGY: ["palace_guard"],
	ProsthesisType.VILLAIN_CYBORG: ["villain_faction"]
}

# Стоимость протезов
var prosthesis_costs = {
	ProsthesisType.BASIC_WOODEN: 50,
	ProsthesisType.BASIC_IRON: 150,
	ProsthesisType.ADVANCED_MECHANICAL: 500,
	ProsthesisType.MAGICAL_ELVEN: 800,
	ProsthesisType.PALACE_TECHNOLOGY: 1000,
	ProsthesisType.VILLAIN_CYBORG: 1200
}

# Сигналы
signal prosthesis_installed(limb_id: int, type: int)
signal prosthesis_removed(limb_id: int)
signal prosthesis_damaged(limb_id: int, damage: float)
signal prosthesis_destroyed(limb_id: int)

# Установленные протезы
var installed_prostheses: Dictionary = {}

func _ready():
	pass

func install_prosthesis(skeleton_core, limb_id: int, prosthesis_type: int, 
						player_factions: Array = []) -> bool:
	"""Установка протеза на конечность"""
	
	var limb = skeleton_core.get_limb(limb_id)
	if not limb:
		return false
	
	# Проверка что конечность отсечена
	if not limb.is_severed:
		push_warning("Cannot install prosthesis on non-severed limb")
		return false
	
	# Проверка требований фракции
	var required_factions = faction_requirements.get(prosthesis_type, [])
	var has_required_faction = true
	for faction in required_factions:
		if faction not in player_factions:
			has_required_faction = false
			break
	
	if not has_required_faction:
		push_warning("Missing required faction for prosthesis type: %d" % prosthesis_type)
		return false
	
	# Установка протеза
	var success = skeleton_core.attach_prosthesis(limb_id, prosthesis_names[prosthesis_type])
	
	if success:
		installed_prostheses[limb_id] = {
			"type": prosthesis_type,
			"health": prosthesis_stats[prosthesis_type].durability,
			"max_health": prosthesis_stats[prosthesis_type].durability,
			"installation_date": Time.get_unix_time_from_system()
		}
		
		# Обновление функциональности с учетом типа протеза
		limb.functionality = prosthesis_stats[prosthesis_type].functionality
		
		emit_signal("prosthesis_installed", limb_id, prosthesis_type)
	
	return success

func remove_prosthesis(skeleton_core, limb_id: int) -> bool:
	"""Снятие протеза"""
	
	var limb = skeleton_core.get_limb(limb_id)
	if not limb or not limb.has_prosthesis:
		return false
	
	limb.has_prosthesis = false
	limb.prosthesis_type = ""
	limb.functionality = 0
	
	installed_prostheses.erase(limb_id)
	
	emit_signal("prosthesis_removed", limb_id)
	
	return true

func damage_prosthesis(skeleton_core, limb_id: int, damage: float) -> bool:
	"""Повреждение протеза"""
	
	var prosthesis = installed_prostheses.get(limb_id)
	if not prosthesis:
		return false
	
	prosthesis.health -= damage
	
	if prosthesis.health <= 0:
		# Протез разрушен
		var limb = skeleton_core.get_limb(limb_id)
		if limb:
			limb.has_prosthesis = false
			limb.prosthesis_type = ""
			limb.functionality = 0
		
		installed_prostheses.erase(limb_id)
		emit_signal("prosthesis_destroyed", limb_id)
	else:
		# Снижение функциональности при повреждении
		var limb = skeleton_core.get_limb(limb_id)
		if limb:
			var health_ratio = prosthesis.health / prosthesis.max_health
			var base_func = prosthesis_stats[prosthesis.type].functionality
			limb.functionality = base_func * health_ratio
		
		emit_signal("prosthesis_damaged", limb_id, damage)
	
	return true

func repair_prosthesis(skeleton_core, limb_id: int, repair_amount: float) -> float:
	"""Ремонт протеза"""
	
	var prosthesis = installed_prostheses.get(limb_id)
	if not prosthesis:
		return 0.0
	
	var old_health = prosthesis.health
	prosthesis.health = min(prosthesis.health + repair_amount, prosthesis.max_health)
	
	var actual_repair = prosthesis.health - old_health
	
	# Восстановление функциональности
	var limb = skeleton_core.get_limb(limb_id)
	if limb:
		var health_ratio = prosthesis.health / prosthesis.max_health
		var base_func = prosthesis_stats[prosthesis.type].functionality
		limb.functionality = base_func * health_ratio
	
	return actual_repair

func get_prosthesis_status(limb_id: int) -> Dictionary:
	"""Получение статуса протеза"""
	
	var prosthesis = installed_prostheses.get(limb_id)
	if not prosthesis:
		return {"installed": false}
	
	return {
		"installed": true,
		"type": prosthesis.type,
		"type_name": prosthesis_names[prosthesis.type],
		"health": prosthesis.health,
		"max_health": prosthesis.max_health,
		"functionality": prosthesis_stats[prosthesis.type].functionality,
		"weight": prosthesis_stats[prosthesis.type].weight,
		"installation_date": prosthesis.installation_date,
		"cost": prosthesis_costs[prosthesis.type]
	}

func get_available_prostheses(player_factions: Array = []) -> Array:
	"""Получение доступных для игрока протезов"""
	
	var available = []
	
	for ptype in prosthesis_names:
		if ptype == ProsthesisType.NONE:
			continue
		
		var required_factions = faction_requirements.get(ptype, [])
		var can_use = true
		
		for faction in required_factions:
			if faction not in player_factions:
				can_use = false
				break
		
		if can_use:
			available.append({
				"type": ptype,
				"name": prosthesis_names[ptype],
				"stats": prosthesis_stats[ptype],
				"cost": prosthesis_costs[ptype],
				"required_factions": required_factions
			})
	
	return available

func upgrade_prosthesis(skeleton_core, limb_id: int, new_type: int, 
						player_factions: Array = []) -> bool:
	"""Улучшение существующего протеза"""
	
	var prosthesis = installed_prostheses.get(limb_id)
	if not prosthesis:
		return false
	
	# Проверка что новый тип лучше текущего
	if new_type <= prosthesis.type:
		push_warning("New prosthesis type must be better than current")
		return false
	
	# Проверка требований фракции
	var required_factions = faction_requirements.get(new_type, [])
	var has_required_faction = true
	for faction in required_factions:
		if faction not in player_factions:
			has_required_faction = false
			break
	
	if not has_required_faction:
		return false
	
	# Удаление старого протеза и установка нового
	remove_prosthesis(skeleton_core, limb_id)
	return install_prosthesis(skeleton_core, limb_id, new_type, player_factions)

func get_total_weight(skeleton_core) -> float:
	"""Подсчет общего веса всех протезов"""
	
	var total_weight = 0.0
	
	for limb_id in installed_prostheses:
		var prosthesis = installed_prostheses[limb_id]
		total_weight += prosthesis_stats[prosthesis.type].weight
	
	return total_weight

func export_prostheses_data() -> Dictionary:
	"""Экспорт данных о протезах для сохранения"""
	
	var data = {}
	for limb_id in installed_prostheses:
		var prosthesis = installed_prostheses[limb_id]
		data["limb_%d" % limb_id] = {
			"type": prosthesis.type,
			"health": prosthesis.health,
			"max_health": prosthesis.max_health,
			"installation_date": prosthesis.installation_date
		}
	
	return data

func import_prostheses_data(skeleton_core, data: Dictionary):
	"""Импорт данных о протезах из сохранения"""
	
	for key in data:
		if key.begins_with("limb_"):
			var limb_id = int(key.split("_")[1])
			var prosthesis_data = data[key]
			
			var limb = skeleton_core.get_limb(limb_id)
			if limb:
				# Восстановление протеза на конечности
				limb.has_prosthesis = true
				limb.prosthesis_type = prosthesis_names[prosthesis_data.type]
				limb.functionality = prosthesis_stats[prosthesis_data.type].functionality
				
				# Восстановление данных о протезе
				installed_prostheses[limb_id] = {
					"type": prosthesis_data.type,
					"health": prosthesis_data.health,
					"max_health": prosthesis_data.max_health,
					"installation_date": prosthesis_data.installation_date
				}
