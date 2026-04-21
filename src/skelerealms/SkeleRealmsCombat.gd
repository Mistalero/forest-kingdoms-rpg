class_name SkeleRealmsCombat
extends Node

## SkeleRealms Combat System
## Боевая система на основе скелетной архитектуры

@export var skeleton_core: SkeleRealmsCore

# Типы атак
enum AttackType {
	SLASH,
	STAB,
	BLUNT,
	CRUSH,
	PIERCE,
	BITE,
	CLAW
}

# Зоны поражения
enum HitZone {
	HEAD,
	NECK,
	TORSO_FRONT,
	TORSO_BACK,
	LEFT_SHOULDER,
	RIGHT_SHOULDER,
	LEFT_UPPER_ARM,
	RIGHT_UPPER_ARM,
	LEFT_FOREARM,
	RIGHT_FOREARM,
	LEFT_HAND,
	RIGHT_HAND,
	PELVIS,
	LEFT_THIGH,
	RIGHT_THIGH,
	LEFT_LOWER_LEG,
	RIGHT_LOWER_LEG,
	LEFT_FOOT,
	RIGHT_FOOT
}

# Модификаторы урона для разных зон
var zone_damage_multipliers = {
	HitZone.HEAD: 2.0,
	HitZone.NECK: 2.5,
	HitZone.TORSO_FRONT: 1.2,
	HitZone.TORSO_BACK: 1.0,
	HitZone.LEFT_SHOULDER: 0.8,
	HitZone.RIGHT_SHOULDER: 0.8,
	HitZone.LEFT_UPPER_ARM: 0.9,
	HitZone.RIGHT_UPPER_ARM: 0.9,
	HitZone.LEFT_FOREARM: 0.7,
	HitZone.RIGHT_FOREARM: 0.7,
	HitZone.LEFT_HAND: 0.6,
	HitZone.RIGHT_HAND: 0.6,
	HitZone.PELVIS: 1.3,
	HitZone.LEFT_THIGH: 1.1,
	HitZone.RIGHT_THIGH: 1.1,
	HitZone.LEFT_LOWER_LEG: 0.8,
	HitZone.RIGHT_LOWER_LEG: 0.8,
	HitZone.LEFT_FOOT: 0.5,
	HitZone.RIGHT_FOOT: 0.5
}

# Соответствие зон костям
var zone_to_bone_map = {
	HitZone.HEAD: [SkeleRealmsCore.BoneID.SKULL],
	HitZone.NECK: [SkeleRealmsCore.BoneID.CERVICAL_SPINE],
	HitZone.TORSO_FRONT: [SkeleRealmsCore.BoneID.STERNUM, SkeleRealmsCore.BoneID.RIB_CAGE],
	HitZone.TORSO_BACK: [SkeleRealmsCore.BoneID.THORACIC_SPINE, SkeleRealmsCore.BoneID.LUMBAR_SPINE],
	HitZone.LEFT_SHOULDER: [SkeleRealmsCore.BoneID.LEFT_CLAVICLE, SkeleRealmsCore.BoneID.LEFT_SCAPULA],
	HitZone.RIGHT_SHOULDER: [SkeleRealmsCore.BoneID.RIGHT_CLAVICLE, SkeleRealmsCore.BoneID.RIGHT_SCAPULA],
	HitZone.LEFT_UPPER_ARM: [SkeleRealmsCore.BoneID.LEFT_HUMERUS],
	HitZone.RIGHT_UPPER_ARM: [SkeleRealmsCore.BoneID.RIGHT_HUMERUS],
	HitZone.LEFT_FOREARM: [SkeleRealmsCore.BoneID.LEFT_RADIUS, SkeleRealmsCore.BoneID.LEFT_ULNA],
	HitZone.RIGHT_FOREARM: [SkeleRealmsCore.BoneID.RIGHT_RADIUS, SkeleRealmsCore.BoneID.RIGHT_ULNA],
	HitZone.LEFT_HAND: [SkeleRealmsCore.BoneID.LEFT_HAND, SkeleRealmsCore.BoneID.LEFT_FINGERS],
	HitZone.RIGHT_HAND: [SkeleRealmsCore.BoneID.RIGHT_HAND, SkeleRealmsCore.BoneID.RIGHT_FINGERS],
	HitZone.PELVIS: [SkeleRealmsCore.BoneID.PELVIS, SkeleRealmsCore.BoneID.SACRUM],
	HitZone.LEFT_THIGH: [SkeleRealmsCore.BoneID.LEFT_FEMUR],
	HitZone.RIGHT_THIGH: [SkeleRealmsCore.BoneID.RIGHT_FEMUR],
	HitZone.LEFT_LOWER_LEG: [SkeleRealmsCore.BoneID.LEFT_TIBIA, SkeleRealmsCore.BoneID.LEFT_FIBULA],
	HitZone.RIGHT_LOWER_LEG: [SkeleRealmsCore.BoneID.RIGHT_TIBIA, SkeleRealmsCore.BoneID.RIGHT_FIBULA],
	HitZone.LEFT_FOOT: [SkeleRealmsCore.BoneID.LEFT_FOOT, SkeleRealmsCore.BoneID.LEFT_TOES],
	HitZone.RIGHT_FOOT: [SkeleRealmsCore.BoneID.RIGHT_FOOT, SkeleRealmsCore.BoneID.RIGHT_TOES]
}

# Модификаторы урона для типов атак
var attack_type_modifiers = {
	AttackType.SLASH: {"bone": 1.3, "joint": 1.1},
	AttackType.STAB: {"bone": 1.5, "joint": 1.4},
	AttackType.BLUNT: {"bone": 1.0, "joint": 1.5},
	AttackType.CRUSH: {"bone": 2.0, "joint": 1.8},
	AttackType.PIERCE: {"bone": 1.4, "joint": 1.3},
	AttackType.BITE: {"bone": 1.2, "joint": 1.2},
	AttackType.CLAW: {"bone": 1.1, "joint": 1.0}
}

func _ready():
	if not skeleton_core:
		skeleton_core = get_node_or_null("/root/SkeleRealmsCore")

func perform_attack(target_skeleton: SkeleRealmsCore, hit_zone: HitZone, 
	attack_type: AttackType, base_damage: float, accuracy: float = 1.0) -> Dictionary:
	"""Выполнение атаки по цели"""
	
	var result = {
		"success": false,
		"damage_dealt": 0.0,
		"bones_damaged": [],
		"joints_affected": [],
		"limb_severed": false,
		"critical_hit": false,
		"missed": false
	}
	
	# Проверка попадания
	var hit_chance = accuracy * get_zone_accuracy_modifier(hit_zone)
	if randf() > hit_chance:
		result.missed = true
		return result
	
	# Получение модификаторов
	var zone_multiplier = zone_damage_multipliers.get(hit_zone, 1.0)
	var attack_modifiers = attack_type_modifiers.get(attack_type, {"bone": 1.0, "joint": 1.0})
	
	# Расчет финального урона
	var final_damage = base_damage * zone_multiplier
	result.critical_hit = zone_multiplier >= 2.0
	
	# Получение костей в зоне поражения
	var affected_bones = zone_to_bone_map.get(hit_zone, [])
	
	for bone_id in affected_bones:
		var damage = final_damage * attack_modifiers.bone
		# Добавление некоторой вариативности
		damage *= randf_range(0.8, 1.2)
		
		target_skeleton.damage_bone(bone_id, damage, get_damage_type_string(attack_type))
		result.bones_damaged.append(bone_id)
		result.damage_dealt += damage
	
	result.success = true
	return result

func get_zone_accuracy_modifier(zone: HitZone) -> float:
	"""Модификатор точности для разных зон"""
	match zone:
		HitZone.HEAD:
			return 0.7  # Трудно попасть
		HitZone.NECK:
			return 0.6
		HitZone.TORSO_FRONT, HitZone.TORSO_BACK:
			return 1.0  # Стандартная точность
		HitZone.LEFT_SHOULDER, HitZone.RIGHT_SHOULDER:
			return 0.9
		HitZone.LEFT_UPPER_ARM, HitZone.RIGHT_UPPER_ARM:
			return 0.95
		HitZone.LEFT_FOREARM, HitZone.RIGHT_FOREARM:
			return 0.85
		HitZone.LEFT_HAND, HitZone.RIGHT_HAND:
			return 0.75
		HitZone.PELVIS:
			return 0.9
		HitZone.LEFT_THIGH, HitZone.RIGHT_THIGH:
			return 0.95
		HitZone.LEFT_LOWER_LEG, HitZone.RIGHT_LOWER_LEG:
			return 0.85
		HitZone.LEFT_FOOT, HitZone.RIGHT_FOOT:
			return 0.7
	return 1.0

func get_damage_type_string(attack_type: AttackType) -> String:
	"""Преобразование типа атаки в строку для системы повреждений"""
	match attack_type:
		AttackType.SLASH:
			return "sharp"
		AttackType.STAB, AttackType.PIERCE:
			return "piercing"
		AttackType.BLUNT:
			return "blunt"
		AttackType.CRUSH:
			return "crushing"
		AttackType.BITE, AttackType.CLAW:
			return "sharp"
	return "blunt"

func calculate_mobility_penalty(skeleton: SkeleRealmsCore) -> float:
	"""Расчет штрафа к мобильности на основе повреждений скелета"""
	var penalty = 0.0
	
	# Проверка ног
	for limb_id in [2, 3]:  # Левая и правая нога
		var limb = skeleton.get_limb(limb_id)
		if limb:
			if limb.is_severed:
				penalty += 0.5
			else:
				var functionality = limb.calculate_functionality()
				penalty += (100 - functionality) / 200
	
	# Проверка таза и позвоночника
	var pelvis_bone = skeleton.get_bone(SkeleRealmsCore.BoneID.PELVIS)
	if pelvis_bone and pelvis_bone.is_broken:
		penalty += 0.3
	
	for spine_bone in [SkeleRealmsCore.BoneID.LUMBAR_SPINE, 
					   SkeleRealmsCore.BoneID.THORACIC_SPINE,
					   SkeleRealmsCore.BoneID.SACRUM]:
		var bone = skeleton.get_bone(spine_bone)
		if bone and bone.is_broken:
			penalty += 0.15
	
	return min(penalty, 1.0)

func calculate_attack_penalty(skeleton: SkeleRealmsCore) -> float:
	"""Расчет штрафа к атаке на основе повреждений скелета"""
	var penalty = 0.0
	
	# Проверка рук
	for limb_id in [0, 1]:  # Левая и правая рука
		var limb = skeleton.get_limb(limb_id)
		if limb:
			if limb.is_severed:
				penalty += 0.5
			else:
				var functionality = limb.calculate_functionality()
				penalty += (100 - functionality) / 200
	
	# Проверка плеч и ключиц
	for shoulder_bone in [SkeleRealmsCore.BoneID.LEFT_CLAVICLE,
						  SkeleRealmsCore.BoneID.RIGHT_CLAVICLE,
						  SkeleRealmsCore.BoneID.LEFT_SCAPULA,
						  SkeleRealmsCore.BoneID.RIGHT_SCAPULA]:
		var bone = skeleton.get_bone(shoulder_bone)
		if bone and bone.is_broken:
			penalty += 0.15
	
	return min(penalty, 1.0)

func get_combat_status(skeleton: SkeleRealmsCore) -> Dictionary:
	"""Получение боевого статуса персонажа"""
	return {
		"mobility_penalty": calculate_mobility_penalty(skeleton),
		"attack_penalty": calculate_attack_penalty(skeleton),
		"can_fight": can_continue_fighting(skeleton),
		"can_move": can_move(skeleton),
		"critical_injuries": get_critical_injuries(skeleton)
	}

func can_continue_fighting(skeleton: SkeleRealmsCore) -> bool:
	"""Проверка возможности продолжать бой"""
	# Критические повреждения головы или шеи
	var skull = skeleton.get_bone(SkeleRealmsCore.BoneID.SKULL)
	var neck = skeleton.get_bone(SkeleRealmsCore.BoneID.CERVICAL_SPINE)
	
	if skull and skull.is_destroyed:
		return false
	if neck and neck.is_destroyed:
		return false
	
	# Потеря обеих рук
	var left_arm = skeleton.get_limb(0)
	var right_arm = skeleton.get_limb(1)
	
	if left_arm and left_arm.is_severed and right_arm and right_arm.is_severed:
		return false
	
	return true

func can_move(skeleton: SkeleRealmsCore) -> bool:
	"""Проверка возможности передвижения"""
	var left_leg = skeleton.get_limb(2)
	var right_leg = skeleton.get_limb(3)
	
	# Если обе ноги отсечены, передвижение невозможно
	if left_leg and left_leg.is_severed and right_leg and right_leg.is_severed:
		return false
	
	# Если таз разрушен
	var pelvis = skeleton.get_bone(SkeleRealmsCore.BoneID.PELVIS)
	if pelvis and pelvis.is_destroyed:
		return false
	
	return true

func get_critical_injuries(skeleton: SkeleRealmsCore) -> Array:
	"""Получение списка критических повреждений"""
	var critical = []
	
	# Проверка критических костей
	var critical_bones = [
		SkeleRealmsCore.BoneID.SKULL,
		SkeleRealmsCore.BoneID.CERVICAL_SPINE,
		SkeleRealmsCore.BoneID.THORACIC_SPINE,
		SkeleRealmsCore.BoneID.HEART_REGION # Можно добавить если есть
	]
	
	for bone_id in critical_bones:
		var bone = skeleton.get_bone(bone_id)
		if bone and bone.is_destroyed:
			critical.append("destroyed_bone_%d" % bone_id)
	
	# Проверка отсеченных конечностей
	for limb_id in skeleton.limbs:
		var limb = skeleton.get_limb(limb_id)
		if limb and limb.is_severed:
			critical.append("severed_limb_%d" % limb_id)
	
	return critical

func apply_healing(skeleton: SkeleRealmsCore, heal_amount: float, 
				   target_bone_id: int = -1) -> float:
	"""Применение лечения к скелету"""
	var healed = 0.0
	
	if target_bone_id >= 0:
		# Лечение конкретной кости
		var bone = skeleton.get_bone(target_bone_id)
		if bone and bone.is_broken and not bone.is_destroyed:
			var old_health = bone.health
			bone.repair(heal_amount)
			healed = bone.health - old_health
	else:
		# Распределенное лечение
		var remaining_heal = heal_amount
		for bone_id in skeleton.bones:
			var bone = skeleton.get_bone(bone_id)
			if bone and bone.is_broken and not bone.is_destroyed and remaining_heal > 0:
				var old_health = bone.health
				bone.repair(remaining_heal)
				var actual_heal = bone.health - old_health
				healed += actual_heal
				remaining_heal -= actual_heal
	
	return healed
