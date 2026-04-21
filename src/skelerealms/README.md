# SkeleRealms Integration в Forest Kingdoms RPG

## Обзор

Архитектура [SkeleRealms](https://github.com/SlashScreen/skelerealms) успешно интегрирована в игру Forest Kingdoms RPG. Этот документ описывает компоненты интеграции и способы их использования.

## Установленные компоненты

### 1. Ядро SkeleRealms (addons/skelerealms/)

Полная копия оригинального репозитория SkeleRealms со всеми системами:

- **Entity System** - Псевдо-ECS система для управления объектами мира
- **GOAP AI** - Система искусственного интеллекта на основе целей
- **Inventory & Equipment** - Система инвентаря и экипировки
- **Skills & Attributes** - Система навыков и характеристик
- **Status Effects** - Система статусных эффектов
- **Factions/Covens** - Система фракций
- **Crime System** - Система преступлений
- **Bartering** - Система торговли
- **Save System** - Система сохранений
- **World Persistence** - Межсценная персистентность объектов

### 2. Локальные компоненты (src/skelerealms/)

#### SkeleRealmsCore.gd
Детальная скелетная система с:
- 45 костей и суставов
- Система повреждений костей
- Отсечение конечностей
- Вывихи суставов

#### SkeleRealmsCombat.gd
Боевая система с:
- Различными типами урона
- Зонами поражения
- Множителями урона по частям тела
- Боевыми штрафами за травмы

#### SkeleRealmsProsthesis.gd
Система протезирования:
- 6 типов протезов
- Требования к фракциям
- Бонусы и ограничения

#### SkeleRealmsIntegration.gd (НОВЫЙ)
Мост между системами Forest Kingdoms и SkeleRealms:
- Автоматическая регистрация autoload'ов
- Интеграция с GameManager
- Подключение к генераторам мира
- Сетевая синхронизация
- MUD режим совместимость

## Автозагрузка (Autoloads)

В project.godot зарегистрированы следующие синглтоны:

```ini
[autoload]
SkeleRealmsCore="*res://src/skelerealms/SkeleRealmsCore.gd"
SkeleRealmsCombat="*res://src/skelerealms/SkeleRealmsCombat.gd"
SkeleRealmsProsthesis="*res://src/skelerealms/SkeleRealmsProsthesis.gd"
SkeleRealmsIntegration="*res://src/skelerealms/SkeleRealmsIntegration.gd"
SkeleRealmsGlobal="*res://addons/skelerealms/scripts/sk_global.gd"
GameInfo="*res://addons/skelerealms/scripts/system/game_info.gd"
SaveSystem="*res://addons/skelerealms/scripts/system/save_system.gd"
CovenSystem="*res://addons/skelerealms/scripts/covens/coven_system.gd"
CrimeMaster="*res://addons/skelerealms/scripts/crime/crime_master.gd"
```

## Настройка

### Конфигурация (addons/skelerealms/config/sk_config.tres)

```gdscript
default_world = "main"
equipment_slots = ["head", "chest", "legs", "feet", "hands", "main_hand", "off_hand"]
skills = {
    "strength": {"initial_level": 1, "max_level": 100},
    "agility": {"initial_level": 1, "max_level": 100},
    "intelligence": {"initial_level": 1, "max_level": 100},
    "endurance": {"initial_level": 1, "max_level": 100},
    "combat": {"initial_level": 1, "max_level": 100}
}
attributes = {
    "health": {"base": 100, "scale": 10},
    "stamina": {"base": 50, "scale": 5},
    "magicka": {"base": 75, "scale": 8}
}
```

## Использование

### Создание Entity с компонентами

```gdscript
# Через интеграционный слой
var entity_data = {
    "form_id": "npc_guard_001",
    "world": "main",
    "position": Vector3(10, 0, 5),
    "unique": true,
    "components": ["damageable", "inventory", "goap", "npc", "vitals"]
}
var entity = SkeleRealmsIntegration._create_entity_from_data(entity_data)

# Или напрямую
var entity = SKEntity.new()
entity.form_id = "player"
entity.add_component(DamageableComponent.new())
```

### Нанесение урона

```gdscript
# Через интеграционный слой
SkeleRealmsIntegration.apply_damage(target_node, {
    "amount": 25.0,
    "type": "physical",
    "source": attacker_node
})

# Через детальную систему костей
SkeleRealmsCore.damage_bone(BoneID.LEFT_HUMERUS, 50.0)
if SkeleRealmsCore.is_bone_destroyed(BoneID.LEFT_HUMERUS):
    SkeleRealmsCore.sever_limb(LimbID.LEFT_ARM)
```

### Работа с GOAP AI

```gdscript
# Добавление GOAP компонента к NPC
var goap = GOAPComponent.new()
npc_entity.add_component(goap)

# Создание действий
var action = MyCustomAction.new()
goap.add_child(action)

# Добавление целей
var objective = Objective.new()
objective.goals = {"is_safe": true}
objective.priority = 1.0
goap.objectives.append(objective)
```

### MUD команды

```gdscript
# Спавн entity
mud_command("spawn", ["npc_guard_001"])

# Информация об entity
mud_command("info", ["entity_123"])

# Экипировка предмета
mud_command("equip", ["main_hand", "iron_sword"])
```

## Совместимость с существующими системами

### Генераторы мира
SkeleRealmsIntegration автоматически подключается к генераторам:
- WorldGenerator
- NPCGenerator
- BuildingGenerator
- QuestGenerator
- ItemGenerator

### P2P Сеть
Интеграция поддерживает сетевую синхронизацию:
- Синхронизация entities между пирами
- Репликация повреждений
- Синхронизация инвентаря

### MUD Режим
Полная совместимость с текстовым интерфейсом:
- Команды взаимодействия с entities
- Текстовое описание состояния костей
- Информация о протезах

## Структура файлов

```
/workspace
├── addons/skelerealms/          # Оригинальный SkeleRealms
│   ├── scripts/
│   │   ├── entities/            # ECS система
│   │   ├── components/          # Компоненты entities
│   │   ├── ai/                  # GOAP AI система
│   │   ├── system/              # Системные менеджеры
│   │   ├── covens/              # Фракции
│   │   ├── crime/               # Преступления
│   │   ├── barter/              # Торговля
│   │   └── ...
│   └── config/
│       └── sk_config.tres       # Конфигурация
│
└── src/skelerealms/             # Локальные расширения
    ├── SkeleRealmsCore.gd       # Скелетная система
    ├── SkeleRealmsCombat.gd     # Боевая система
    ├── SkeleRealmsProsthesis.gd # Протезирование
    ├── SkeleRealmsIntegration.gd # Интеграция
    └── README.md                # Эта документация
```

## Статус интеграции

✅ Полностью интегрировано:
- Entity система
- GOAP AI
- Inventory/Equipment
- Skills/Attributes
- Status Effects
- Save System
- Детальная скелетная система
- Боевая система с зонами поражения
- Система протезирования
- MUD совместимость

🔄 Требует настройки:
- Конкретные действия GOAP для NPC
- Баланс навыков и характеристик
- Контент предметов и экипировки

## Дополнительные ресурсы

- [Оригинальная документация SkeleRealms](addons/skelerealms/docs/)
- [Документация Forest Kingdoms](docs/)
- [API моддинга](docs/MODDING_API.md)
