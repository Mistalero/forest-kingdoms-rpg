# API для моддинга

## Введение

API для моддинга предоставляет интерфейс для создания и интеграции пользовательских модов в игру Forest Kingdoms RPG.

## Основные компоненты API

### 1. Система событий

Система событий позволяет модам реагировать на различные действия в игре.

```gdscript
# Пример подписки на событие
ModdingAPI.subscribe("player_level_up", on_player_level_up)

func on_player_level_up(player, new_level):
    # Логика мода при повышении уровня игрока
    pass
```

### 2. Регистрация новых компонентов

API позволяет регистрировать новые игровые компоненты:

```gdscript
# Регистрация нового типа предмета
ModdingAPI.register_item_type("magic_sword", MagicSwordClass)

# Регистрация нового типа врага
ModdingAPI.register_enemy_type("dragon", DragonClass)
```

### 3. Доступ к игровым данным

API предоставляет безопасный доступ к игровым данным:

```gdscript
# Получение данных игрока
var player_data = ModdingAPI.get_player_data()

# Изменение характеристик игрока
ModdingAPI.modify_player_stat("strength", 10)
```

## Методы API

### subscribe(event_name, callback)
Подписка на событие игры.

### register_item_type(type_name, class_reference)
Регистрация нового типа предмета.

### register_enemy_type(type_name, class_reference)
Регистрация нового типа врага.

### get_player_data()
Получение данных игрока.

### modify_player_stat(stat_name, value)
Изменение характеристики игрока.

## Безопасность

API обеспечивает безопасность выполнения модов путем:
- Песочницы для выполнения кода
- Проверки доступа к игровым ресурсам
- Ограничения на системные вызовы