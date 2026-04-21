# Bare Metal MUD Mode для Forest Kingdoms RPG с архитектурой SkeleRealms
## Минималистичный текстовый режим без GUI, работающий напрямую с консолью

Этот режим обеспечивает максимально легковесную работу игры через терминал, 
используя архитектуру SkeleRealms для управления entity, компонентами и системами.

## Особенности

- **Прямой доступ к консоли** - никаких GUI элементов, только stdin/stdout
- **Минимальное потребление памяти** - отключение всех графических систем
- **Полная интеграция со SkeleRealms** - все компоненты доступны через команды
- **P2P сеть в текстовом режиме** - синхронизация между пирами через консоль
- **Асинхронная обработка команд** - неблокирующий ввод/вывод

## Структура файлов

```
src/bare_metal/
├── BareMetalMode.gd              # Основной класс режима
├── ConsoleInterface.gd           # Прямая работа с консолью
├── CommandParser.gd              # Парсер команд
├── EntityRenderer.gd             # Отображение данных entity
├── CombatRenderer.gd             # Боевая система в тексте
├── InventoryRenderer.gd          # Инвентарь в тексте
├── NetworkConsole.gd             # Сетевые команды
└── README.md                     # Документация
```

## Быстрый старт

### 1. Активация Bare Metal режима

В `project.godot` добавьте autoload:
```
BareMetalMode="res://src/bare_metal/BareMetalMode.gd"
```

### 2. Запуск в консольном режиме

```bash
godot --headless --script res://src/bare_metal/BareMetalMode.gd
```

Или из игры:
```
:baremetal
```

## Команды

### Базовые команды
```
help                    - Показать справку
look                    - Осмотреться
status                  - Показать статус персонажа
quit                    - Выход из игры
```

### SkeleRealms команды
```
entity list             - Список всех entity
entity info <id>        - Информация об entity
component list <id>     - Компоненты entity
component add <id> <type> - Добавить компонент
component remove <id> <type> - Удалить компонент
```

### Боевые команды
```
attack <target>         - Атаковать цель
damage <target> <amount> <type> - Нанести урон
limb status             - Статус конечностей
amputate <limb>         - Ампутировать конечность
prosthetic equip <type> - Установить протез
```

### Инвентарь
```
inventory               - Показать инвентарь
equip <slot> <item>     - Экипировать предмет
unequip <slot>          - Снять предмет
use <item>              - Использовать предмет
```

### Сеть
```
network peers           - Список пиров
network sync            - Синхронизировать состояние
network send <peer> <data> - Отправить данные
```

## API для разработчиков

### Пример использования BareMetalMode

```gdscript
# Получение доступа к режиму
var bare_metal = BareMetalMode.get_instance()

# Отправка текста в консоль
bare_metal.output("Привет, мир!")

# Регистрация команды
bare_metal.register_command("mycmd", self, "_on_mycmd")

func _on_mycmd(args: Array):
    bare_metal.output("Выполнена команда с аргументами: " + str(args))
```

### Работа с Entity через консоль

```gdscript
# Создание entity
var entity = SKEntity.new()
entity.form_id = "player_001"

# Добавление компонентов
entity.add_component(DamageableComponent.new())
entity.add_component(load("res://addons/skelerealms/scripts/components/inventory_component.gd").new())

# Отображение информации
BareMetalMode.get_instance().render_entity(entity)
```

### Интеграция с боевой системой

```gdscript
# Нанесение урона
var combat = SkeleRealmsCombat.get_instance()
combat.apply_damage(target_entity, {
    "amount": 25,
    "type": "slash",
    "source": player_entity,
    "limb": "left_arm"
})

# Проверка статуса конечностей
var limb_status = combat.get_limb_status(player_entity)
BareMetalMode.get_instance().output("Статус руки: " + str(limb_status))
```

## Конфигурация

### project.godot настройки

```ini
[bare_metal]
console/enabled=true
async_io/enabled=true
network/enabled=true
debug/verbose=false
```

### Переменные окружения

```bash
export BARE_METAL_MODE=1
export CONSOLE_ENCODING=utf-8
export ASYNC_IO_BUFFER=4096
```

## Производительность

- **Память**: ~5MB без графических систем
- **Запуск**: < 1 секунды
- **Команды**: < 10ms обработка
- **Сеть**: P2P синхронизация в реальном времени

## Расширение функциональности

### Добавление новой команды

```gdscript
# В своём скрипте
extends Node

func _ready():
    var bare_metal = BareMetalMode.get_instance()
    bare_metal.register_command("custom", self, "_on_custom")

func _on_custom(args: Array):
    # Логика команды
    BareMetalMode.get_instance().output("Custom command executed!")
```

### Кастомный рендерер

```gdscript
class_name CustomRenderer
extends Node

func render(data: Dictionary) -> String:
    var output = ""
    for key in data:
        output += "%s: %s\n" % [key, data[key]]
    return output
```

## Отладка

### Включить verbose режим

```
:debug verbose on
```

### Логирование команд

```
:debug log commands
```

### Профилирование производительности

```
:debug profile
```

## Совместимость

- **Godot**: 4.x
- **ОС**: Linux, macOS, Windows (консоль)
- **Терминалы**: Любой ANSI-совместимый
- **Сеть**: P2P через WebRTC/WebSocket

## Примеры использования

### Сессия 1: Базовое взаимодействие

```
$ godot --headless --script res://src/bare_metal/BareMetalMode.gd

Forest Kingdoms RPG - Bare Metal Mode
======================================

> help
Доступные команды: help, look, status, entity, component, attack, inventory...

> look
Вы находитесь в Главной комнате.
Видимые entity:
  [1] Игрок (player_001)
  [2] Страж (guard_001)
  [3] Меч (sword_iron_001)

> entity info 2
Entity ID: 2
Form ID: guard_001
Position: (0, 0, 5)
Компоненты:
  - DamageableComponent (HP: 100/100)
  - InventoryComponent (Slots: 5/10)
  - GOAPComponent (State: idle)

> attack 2
Атака по guard_001!
Нанесено 15 урона (slash).
HP: 85/100

> quit
Сохранение прогресса...
До свидания!
```

### Сессия 2: Работа с компонентами

```
> entity list
[1] player_001
[2] guard_001
[3] sword_iron_001

> component list 1
Компоненты player_001:
  - PlayerComponent
  - VitalsComponent
  - AttributesComponent
  - SkillsComponent
  - InventoryComponent
  - EquipmentComponent

> component add 1 ShopComponent
Добавлен ShopComponent к player_001

> component remove 1 ShopComponent
Удалён ShopComponent из player_001
```

### Сессия 3: Боевая система с конечностями

```
> limb status
Статус конечностей:
  - Голова: OK
  - Торс: OK
  - Левая рука: OK
  - Правая рука: OK
  - Левая нога: OK
  - Правая нога: OK

> damage 2 50 slash left_arm
Нанесено 50 урона по левой руке guard_001

> limb status (target: 2)
Статус конечностей guard_001:
  - Голова: OK
  - Торс: OK
  - Левая рука: КРИТИЧЕСКИ (0/25 HP)
  - Правая рука: OK
  - Левая нога: OK
  - Правая нога: OK

> amputate left_arm (target: 2)
Левая рука guard_001 ампутирована!
Шанс кровотечения: 75%
Штраф к атаке: -40%

> prosthetic equip iron_hook left_arm
Установлен протез: Железный крюк
Бонус к урону: +5
Штраф к ловкости: -2
```

## Лицензия

Интегрировано с архитектурой SkeleRealms (Bethesda-style RPG).
Основной код Forest Kingdoms RPG под оригинальной лицензией проекта.
