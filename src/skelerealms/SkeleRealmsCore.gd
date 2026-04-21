class_name SkeleRealmsCore
extends Node

## SkeleRealms Architecture Core
## Детальная скелетная система для Forest Kingdoms RPG

# Сигналы
signal bone_damaged(bone_id: int, damage: float)
signal bone_destroyed(bone_id: int)
signal joint_dislocated(joint_id: int)
signal limb_severed(limb_id: int)
signal prosthesis_attached(limb_id: int, prosthesis_type: String)

# Константы костей
enum BoneID {
	SKULL,
	CERVICAL_SPINE,
	THORACIC_SPINE,
	LUMBAR_SPINE,
	SACRUM,
	RIB_CAGE,
	STERNUM,
	LEFT_CLAVICLE,
	RIGHT_CLAVICLE,
	LEFT_SCAPULA,
	RIGHT_SCAPULA,
	LEFT_HUMERUS,
	RIGHT_HUMERUS,
	LEFT_RADIUS,
	RIGHT_RADIUS,
	LEFT_ULNA,
	RIGHT_ULNA,
	LEFT_HAND,
	RIGHT_HAND,
	PELVIS,
	LEFT_FEMUR,
	RIGHT_FEMUR,
	LEFT_PATELLA,
	RIGHT_PATELLA,
	LEFT_TIBIA,
	RIGHT_TIBIA,
	LEFT_FIBULA,
	RIGHT_FIBULA,
	LEFT_FOOT,
	RIGHT_FOOT,
	LEFT_TOES,
	RIGHT_TOES,
	LEFT_FINGERS,
	RIGHT_FINGERS
}

# Структура кости
class Bone:
	var id: int
	var name: String
	var health: float
	var max_health: float
	var is_broken: bool = false
	var is_destroyed: bool = false
	var connected_joints: Array[int] = []
	var parent_bone: int = -1
	var child_bones: Array[int] = []
	var position: Vector3
	var rotation: Quaternion
	
	func _init(bone_id: int, bone_name: String, hp: float):
		id = bone_id
		name = bone_name
		health = hp
		max_health = hp
	
	func take_damage(amount: float) -> bool:
		health -= amount
		if health <= 0:
			is_broken = true
			if health <= -max_health:
				is_destroyed = true
			return true
		return false
	
	func repair(amount: float):
		health = min(health + amount, max_health)
		if health > 0:
			is_broken = false

# Структура сустава
class Joint:
	var id: int
	var name: String
	var connected_bones: Array[int] = []
	var stability: float = 100.0
	var max_stability: float = 100.0
	var is_dislocated: bool = false
	var range_of_motion: Dictionary = {}
	
	func _init(joint_id: int, joint_name: String, bones: Array[int]):
		id = joint_id
		name = joint_name
		connected_bones = bones
	
	func apply_stress(amount: float):
		stability -= amount
		if stability <= 0 and not is_dislocated:
			is_dislocated = true

# Структура конечности
class Limb:
	var id: int
	var name: String
	var bones: Array[int] = []
	var joints: Array[int] = []
	var is_severed: bool = false
	var has_prosthesis: bool = false
	var prosthesis_type: String = ""
	var functionality: float = 100.0
	
	func _init(limb_id: int, limb_name: String, bone_ids: Array[int], joint_ids: Array[int]):
		id = limb_id
		name = limb_name
		bones = bone_ids
		joints = joint_ids
	
	func calculate_functionality() -> float:
		var total_func = 0.0
		for bone_id in bones:
			var bone = GameManager.get_bone(bone_id)
			if bone:
				if bone.is_destroyed:
					total_func += 0
				elif bone.is_broken:
					total_func += bone.health / bone.max_health * 50
				else:
					total_func += 100
		return total_func / bones.size() if bones.size() > 0 else 0

# Глобальные переменные
var bones: Dictionary = {}
var joints: Dictionary = {}
var limbs: Dictionary = {}
var skeleton_config: Dictionary = {}

func _ready():
	initialize_skeleton()

func initialize_skeleton():
	"""Инициализация скелетной структуры"""
	_init_bones()
	_init_joints()
	_init_limbs()
	_setup_connections()

func _init_bones():
	"""Создание всех костей скелета"""
	bones[BoneID.SKULL] = Bone.new(BoneID.SKULL, "Skull", 100)
	bones[BoneID.CERVICAL_SPINE] = Bone.new(BoneID.CERVICAL_SPINE, "Cervical Spine", 80)
	bones[BoneID.THORACIC_SPINE] = Bone.new(BoneID.THORACIC_SPINE, "Thoracic Spine", 100)
	bones[BoneID.LUMBAR_SPINE] = Bone.new(BoneID.LUMBAR_SPINE, "Lumbar Spine", 90)
	bones[BoneID.SACRUM] = Bone.new(BoneID.SACRUM, "Sacrum", 85)
	bones[BoneID.RIB_CAGE] = Bone.new(BoneID.RIB_CAGE, "Rib Cage", 120)
	bones[BoneID.STERNUM] = Bone.new(BoneID.STERNUM, "Sternum", 70)
	
	# Верхние конечности
	bones[BoneID.LEFT_CLAVICLE] = Bone.new(BoneID.LEFT_CLAVICLE, "Left Clavicle", 60)
	bones[BoneID.RIGHT_CLAVICLE] = Bone.new(BoneID.RIGHT_CLAVICLE, "Right Clavicle", 60)
	bones[BoneID.LEFT_SCAPULA] = Bone.new(BoneID.LEFT_SCAPULA, "Left Scapula", 65)
	bones[BoneID.RIGHT_SCAPULA] = Bone.new(BoneID.RIGHT_SCAPULA, "Right Scapula", 65)
	bones[BoneID.LEFT_HUMERUS] = Bone.new(BoneID.LEFT_HUMERUS, "Left Humerus", 80)
	bones[BoneID.RIGHT_HUMERUS] = Bone.new(BoneID.RIGHT_HUMERUS, "Right Humerus", 80)
	bones[BoneID.LEFT_RADIUS] = Bone.new(BoneID.LEFT_RADIUS, "Left Radius", 70)
	bones[BoneID.RIGHT_RADIUS] = Bone.new(BoneID.RIGHT_RADIUS, "Right Radius", 70)
	bones[BoneID.LEFT_ULNA] = Bone.new(BoneID.LEFT_ULNA, "Left Ulna", 70)
	bones[BoneID.RIGHT_ULNA] = Bone.new(BoneID.RIGHT_ULNA, "Right Ulna", 70)
	bones[BoneID.LEFT_HAND] = Bone.new(BoneID.LEFT_HAND, "Left Hand", 50)
	bones[BoneID.RIGHT_HAND] = Bone.new(BoneID.RIGHT_HAND, "Right Hand", 50)
	
	# Нижние конечности
	bones[BoneID.PELVIS] = Bone.new(BoneID.PELVIS, "Pelvis", 100)
	bones[BoneID.LEFT_FEMUR] = Bone.new(BoneID.LEFT_FEMUR, "Left Femur", 100)
	bones[BoneID.RIGHT_FEMUR] = Bone.new(BoneID.RIGHT_FEMUR, "Right Femur", 100)
	bones[BoneID.LEFT_PATELLA] = Bone.new(BoneID.LEFT_PATELLA, "Left Patella", 40)
	bones[BoneID.RIGHT_PATELLA] = Bone.new(BoneID.RIGHT_PATELLA, "Right Patella", 40)
	bones[BoneID.LEFT_TIBIA] = Bone.new(BoneID.LEFT_TIBIA, "Left Tibia", 90)
	bones[BoneID.RIGHT_TIBIA] = Bone.new(BoneID.RIGHT_TIBIA, "Right Tibia", 90)
	bones[BoneID.LEFT_FIBULA] = Bone.new(BoneID.LEFT_FIBULA, "Left Fibula", 80)
	bones[BoneID.RIGHT_FIBULA] = Bone.new(BoneID.RIGHT_FIBULA, "Right Fibula", 80)
	bones[BoneID.LEFT_FOOT] = Bone.new(BoneID.LEFT_FOOT, "Left Foot", 60)
	bones[BoneID.RIGHT_FOOT] = Bone.new(BoneID.RIGHT_FOOT, "Right Foot", 60)
	
	# Кисти и стопы
	bones[BoneID.LEFT_TOES] = Bone.new(BoneID.LEFT_TOES, "Left Toes", 30)
	bones[BoneID.RIGHT_TOES] = Bone.new(BoneID.RIGHT_TOES, "Right Toes", 30)
	bones[BoneID.LEFT_FINGERS] = Bone.new(BoneID.LEFT_FINGERS, "Left Fingers", 40)
	bones[BoneID.RIGHT_FINGERS] = Bone.new(BoneID.RIGHT_FINGERS, "Right Fingers", 40)

func _init_joints():
	"""Создание всех суставов"""
	joints[0] = Joint.new(0, "Atlanto-occipital", [BoneID.SKULL, BoneID.CERVICAL_SPINE])
	joints[1] = Joint.new(1, "Cervico-thoracic", [BoneID.CERVICAL_SPINE, BoneID.THORACIC_SPINE])
	joints[2] = Joint.new(2, "Thoraco-lumbar", [BoneID.THORACIC_SPINE, BoneID.LUMBAR_SPINE])
	joints[3] = Joint.new(3, "Lumbo-sacral", [BoneID.LUMBAR_SPINE, BoneID.SACRUM])
	
	# Плечевые суставы
	joints[4] = Joint.new(4, "Left Sternoclavicular", [BoneID.STERNUM, BoneID.LEFT_CLAVICLE])
	joints[5] = Joint.new(5, "Right Sternoclavicular", [BoneID.STERNUM, BoneID.RIGHT_CLAVICLE])
	joints[6] = Joint.new(6, "Left Acromioclavicular", [BoneID.LEFT_CLAVICLE, BoneID.LEFT_SCAPULA])
	joints[7] = Joint.new(7, "Right Acromioclavicular", [BoneID.RIGHT_CLAVICLE, BoneID.RIGHT_SCAPULA])
	joints[8] = Joint.new(8, "Left Glenohumeral", [BoneID.LEFT_SCAPULA, BoneID.LEFT_HUMERUS])
	joints[9] = Joint.new(9, "Right Glenohumeral", [BoneID.RIGHT_SCAPULA, BoneID.RIGHT_HUMERUS])
	
	# Локтевые суставы
	joints[10] = Joint.new(10, "Left Elbow", [BoneID.LEFT_HUMERUS, BoneID.LEFT_RADIUS, BoneID.LEFT_ULNA])
	joints[11] = Joint.new(11, "Right Elbow", [BoneID.RIGHT_HUMERUS, BoneID.RIGHT_RADIUS, BoneID.RIGHT_ULNA])
	
	# Запястья
	joints[12] = Joint.new(12, "Left Wrist", [BoneID.LEFT_RADIUS, BoneID.LEFT_ULNA, BoneID.LEFT_HAND])
	joints[13] = Joint.new(13, "Right Wrist", [BoneID.RIGHT_RADIUS, BoneID.RIGHT_ULNA, BoneID.RIGHT_HAND])
	
	# Тазобедренные суставы
	joints[14] = Joint.new(14, "Left Hip", [BoneID.PELVIS, BoneID.LEFT_FEMUR])
	joints[15] = Joint.new(15, "Right Hip", [BoneID.PELVIS, BoneID.RIGHT_FEMUR])
	
	# Коленные суставы
	joints[16] = Joint.new(16, "Left Knee", [BoneID.LEFT_FEMUR, BoneID.LEFT_PATELLA, BoneID.LEFT_TIBIA])
	joints[17] = Joint.new(17, "Right Knee", [BoneID.RIGHT_FEMUR, BoneID.RIGHT_PATELLA, BoneID.RIGHT_TIBIA])
	
	# Голеностопные суставы
	joints[18] = Joint.new(18, "Left Ankle", [BoneID.LEFT_TIBIA, BoneID.LEFT_FIBULA, BoneID.LEFT_FOOT])
	joints[19] = Joint.new(19, "Right Ankle", [BoneID.RIGHT_TIBIA, BoneID.RIGHT_FIBULA, BoneID.RIGHT_FOOT])

func _init_limbs():
	"""Создание структуры конечностей"""
	# Левая рука
	limbs[0] = Limb.new(0, "Left Arm", 
		[BoneID.LEFT_CLAVICLE, BoneID.LEFT_SCAPULA, BoneID.LEFT_HUMERUS, 
		 BoneID.LEFT_RADIUS, BoneID.LEFT_ULNA, BoneID.LEFT_HAND, BoneID.LEFT_FINGERS],
		[4, 6, 8, 10, 12])
	
	# Правая рука
	limbs[1] = Limb.new(1, "Right Arm",
		[BoneID.RIGHT_CLAVICLE, BoneID.RIGHT_SCAPULA, BoneID.RIGHT_HUMERUS,
		 BoneID.RIGHT_RADIUS, BoneID.RIGHT_ULNA, BoneID.RIGHT_HAND, BoneID.RIGHT_FINGERS],
		[5, 7, 9, 11, 13])
	
	# Левая нога
	limbs[2] = Limb.new(2, "Left Leg",
		[BoneID.LEFT_FEMUR, BoneID.LEFT_PATELLA, BoneID.LEFT_TIBIA,
		 BoneID.LEFT_FIBULA, BoneID.LEFT_FOOT, BoneID.LEFT_TOES],
		[14, 16, 18])
	
	# Правая нога
	limbs[3] = Limb.new(3, "Right Leg",
		[BoneID.RIGHT_FEMUR, BoneID.RIGHT_PATELLA, BoneID.RIGHT_TIBIA,
		 BoneID.RIGHT_FIBULA, BoneID.RIGHT_FOOT, BoneID.RIGHT_TOES],
		[15, 17, 19])
	
	# Голова и шея
	limbs[4] = Limb.new(4, "Head",
		[BoneID.SKULL, BoneID.CERVICAL_SPINE],
		[0])
	
	# Торс
	limbs[5] = Limb.new(5, "Torso",
		[BoneID.THORACIC_SPINE, BoneID.LUMBAR_SPINE, BoneID.SACRUM,
		 BoneID.RIB_CAGE, BoneID.STERNUM, BoneID.PELVIS],
		[1, 2, 3])

func _setup_connections():
	"""Настройка связей между костями"""
	# Позвоночник
	bones[BoneID.SKULL].child_bones = [BoneID.CERVICAL_SPINE]
	bones[BoneID.CERVICAL_SPINE].parent_bone = BoneID.SKULL
	bones[BoneID.CERVICAL_SPINE].child_bones = [BoneID.THORACIC_SPINE]
	bones[BoneID.THORACIC_SPINE].parent_bone = BoneID.CERVICAL_SPINE
	bones[BoneID.THORACIC_SPINE].child_bones = [BoneID.LUMBAR_SPINE]
	bones[BoneID.LUMBAR_SPINE].parent_bone = BoneID.THORACIC_SPINE
	bones[BoneID.LUMBAR_SPINE].child_bones = [BoneID.SACRUM]
	bones[BoneID.SACRUM].parent_bone = BoneID.LUMBAR_SPINE
	bones[BoneID.SACRUM].child_bones = [BoneID.PELVIS]
	bones[BoneID.PELVIS].parent_bone = BoneID.SACRUM

func get_bone(bone_id: int) -> Bone:
	return bones.get(bone_id)

func get_joint(joint_id: int) -> Joint:
	return joints.get(joint_id)

func get_limb(limb_id: int) -> Limb:
	return limbs.get(limb_id)

func damage_bone(bone_id: int, amount: float, damage_type: String = "blunt"):
	"""Нанесение повреждения кости"""
	var bone = bones.get(bone_id)
	if not bone or bone.is_destroyed:
		return
	
	var multiplier = 1.0
	match damage_type:
		"sharp":
			multiplier = 1.5
		"piercing":
			multiplier = 1.3
		"blunt":
			multiplier = 1.0
		"crushing":
			multiplier = 2.0
	
	var actual_damage = amount * multiplier
	var was_broken = bone.is_broken
	
	if bone.take_damage(actual_damage):
		emit_signal("bone_damaged", bone_id, actual_damage)
		
		if bone.is_destroyed and not was_broken:
			emit_signal("bone_destroyed", bone_id)
			_check_limb_severance(bone_id)
		
		_propagate_damage_to_joints(bone_id)

func _propagate_damage_to_joints(bone_id: int):
	"""Распространение повреждения на связанные суставы"""
	var bone = bones.get(bone_id)
	if not bone:
		return
	
	for joint_id in bone.connected_joints:
		var joint = joints.get(joint_id)
		if joint:
			joint.apply_stress(20.0)
			if joint.is_dislocated:
				pass # Событие будет обработано отдельно

func _check_limb_severance(bone_id: int):
	"""Проверка на отсечение конечности"""
	for limb_id in limbs:
		var limb = limbs[limb_id]
		if bone_id in limb.bones:
			var destroyed_count = 0
			for bid in limb.bones:
				var b = bones.get(bid)
				if b and b.is_destroyed:
					destroyed_count += 1
			
			if destroyed_count >= ceil(limb.bones.size() * 0.6):
				limb.is_severed = true
				limb.functionality = 0
				emit_signal("limb_severed", limb_id)

func attach_prosthesis(limb_id: int, prosthesis_type: String):
	"""Установка протеза на конечность"""
	var limb = limbs.get(limb_id)
	if not limb or not limb.is_severed:
		return false
	
	limb.has_prosthesis = true
	limb.prosthesis_type = prosthesis_type
	limb.functionality = 70.0 # Базовая функциональность протеза
	
	emit_signal("prosthesis_attached", limb_id, prosthesis_type)
	return true

func get_skeleton_status() -> Dictionary:
	"""Получение полного статуса скелета"""
	var status = {
		"bones": {},
		"joints": {},
		"limbs": {},
		"overall_health": 0.0
	}
	
	var total_health = 0.0
	var max_health = 0.0
	
	for bone_id in bones:
		var bone = bones[bone_id]
		status["bones"][bone.name] = {
			"health": bone.health,
			"max_health": bone.max_health,
			"is_broken": bone.is_broken,
			"is_destroyed": bone.is_destroyed
		}
		total_health += bone.health
		max_health += bone.max_health
	
	for joint_id in joints:
		var joint = joints[joint_id]
		status["joints"][joint.name] = {
			"stability": joint.stability,
			"is_dislocated": joint.is_dislocated
		}
	
	for limb_id in limbs:
		var limb = limbs[limb_id]
		status["limbs"][limb.name] = {
			"functionality": limb.calculate_functionality(),
			"is_severed": limb.is_severed,
			"has_prosthesis": limb.has_prosthesis,
			"prosthesis_type": limb.prosthesis_type
		}
	
	status["overall_health"] = (total_health / max_health * 100) if max_health > 0 else 0
	
	return status

func export_skeleton_data() -> Dictionary:
	"""Экспорт данных скелета для сохранения"""
	var data = {}
	for bone_id in bones:
		var bone = bones[bone_id]
		data["bone_%d" % bone_id] = {
			"health": bone.health,
			"is_broken": bone.is_broken,
			"is_destroyed": bone.is_destroyed
		}
	
	for joint_id in joints:
		var joint = joints[joint_id]
		data["joint_%d" % joint_id] = {
			"stability": joint.stability,
			"is_dislocated": joint.is_dislocated
		}
	
	for limb_id in limbs:
		var limb = limbs[limb_id]
		data["limb_%d" % limb_id] = {
			"is_severed": limb.is_severed,
			"has_prosthesis": limb.has_prosthesis,
			"prosthesis_type": limb.prosthesis_type
		}
	
	return data

func import_skeleton_data(data: Dictionary):
	"""Импорт данных скелета из сохранения"""
	for key in data:
		if key.begins_with("bone_"):
			var bone_id = int(key.split("_")[1])
			var bone = bones.get(bone_id)
			if bone:
				bone.health = data[key]["health"]
				bone.is_broken = data[key]["is_broken"]
				bone.is_destroyed = data[key]["is_destroyed"]
		
		elif key.begins_with("joint_"):
			var joint_id = int(key.split("_")[1])
			var joint = joints.get(joint_id)
			if joint:
				joint.stability = data[key]["stability"]
				joint.is_dislocated = data[key]["is_dislocated"]
		
		elif key.begins_with("limb_"):
			var limb_id = int(key.split("_")[1])
			var limb = limbs.get(limb_id)
			if limb:
				limb.is_severed = data[key]["is_severed"]
				limb.has_prosthesis = data[key]["has_prosthesis"]
				limb.prosthesis_type = data[key]["prosthesis_type"]
