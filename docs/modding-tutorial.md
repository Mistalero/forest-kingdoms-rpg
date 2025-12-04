# Руководство по созданию модов

## Введение

Это руководство поможет вам создать ваш первый мод для Forest Kingdoms RPG.

## Подготовка к разработке

### Требования

- Установленный Forest Kingdoms RPG
- Текстовый редактор или IDE
- Базовые знания GDScript

### Структура мода

Каждый мод должен иметь следующую структуру:

```
mod_name/
├── mod.json
├── scripts/
├── assets/
└── README.md
```

## Создание простого мода

### 1. Создание файла описания мода

Создайте файл `mod.json` в корневой директории мода:

```json
{
  "name": "My First Mod",
  "version": "1.0.0",
  "author": "Your Name",
  "description": "Мой первый мод для Forest Kingdoms RPG",
  "dependencies": []
}
```

### 2. Создание скрипта мода

Создайте файл `scripts/main.gd`:

```gdscript
extends Mod

func _init():
    name = "My First Mod"
    version = "1.0.0"

func _ready():
    # Инициализация мода
    ModdingAPI.subscribe("game_start", on_game_start)

func on_game_start():
    print("Мой мод успешно загружен!")
```

### 3. Установка мода

Поместите папку мода в директорию `mods` игры.

## Продвинутые возможности

### Добавление новых предметов

```gdscript
# В скрипте мода
func _ready():
    ModdingAPI.register_item_type("magic_potion", MagicPotion)

class MagicPotion:
    extends Item
    
    func use(player):
        player.heal(50)
```

### Создание пользовательского интерфейса

```gdscript
# Создание нового окна
var custom_window = ModdingAPI.create_window("Мое окно")
custom_window.add_label("Привет из мода!")
```

## Отладка модов

Используйте консоль разработчика для отладки модов:

```
debug_mods true
```

## Лучшие практики

1. Всегда тестируйте моды в изолированной среде
2. Документируйте ваш код
3. Следите за производительностью
4. Обрабатывайте ошибки корректно