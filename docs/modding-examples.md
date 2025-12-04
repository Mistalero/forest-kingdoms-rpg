# Примеры модов

## Введение

Этот документ содержит примеры различных типов модов, которые можно создать для Forest Kingdoms RPG.

## Пример 1: Простой мод добавления предмета

```gdscript
# simple_item_mod/scripts/main.gd
extends Mod

func _ready():
    # Регистрация нового предмета
    ModdingAPI.register_item_type("health_potion", HealthPotion)

class HealthPotion:
    extends Item
    
    var name = "Зелье здоровья"
    var description = "Восстанавливает 50 единиц здоровья"
    var value = 25
    
    func use(player):
        player.heal(50)
        return true
```

## Пример 2: Мод, изменяющий игровую механику

```gdscript
# double_xp_mod/scripts/main.gd
extends Mod

func _ready():
    # Удваиваем получаемый опыт
    ModdingAPI.subscribe("player_gain_xp", on_player_gain_xp)

func on_player_gain_xp(player, amount):
    # Изменяем количество получаемого опыта
    ModdingAPI.modify_xp_gain(player, amount * 2)
```

## Пример 3: Мод с пользовательским интерфейсом

```gdscript
# custom_ui_mod/scripts/main.gd
extends Mod

var button

func _ready():
    # Создание кнопки в главном меню
    button = ModdingAPI.create_menu_button("Мой мод", on_button_pressed)

func on_button_pressed():
    # Создание окна при нажатии кнопки
    var window = ModdingAPI.create_window("Приветствие")
    window.add_label("Привет от моего мода!")
    window.show()
```

## Пример 4: Мод, добавляющий нового врага

```gdscript
# new_enemy_mod/scripts/main.gd
extends Mod

func _ready():
    # Регистрация нового типа врага
    ModdingAPI.register_enemy_type("giant_spider", GiantSpider)

class GiantSpider:
    extends Enemy
    
    var name = "Гигантский паук"
    var health = 100
    var attack = 25
    var defense = 10
    
    func _init():
        # Загрузка спрайта врага
        sprite = preload("res://mods/new_enemy_mod/assets/spider.png")
    
    func on_death():
        # Выпадение предметов при смерти
        var loot = ["spider_silk", "poison_gland"]
        return loot
```

## Пример 5: Мод, добавляющий квест

```gdscript
# quest_mod/scripts/main.gd
extends Mod

func _ready():
    # Добавление нового квеста
    var quest = ModdingAPI.create_quest("Паучья проблема")
    quest.description = "Уничтожьте 10 гигантских пауков в Темном лесу"
    quest.objective = {"type": "kill", "target": "giant_spider", "count": 10}
    quest.reward = {"xp": 500, "gold": 100, "items": ["spider_boots"]}
    
    ModdingAPI.add_quest(quest)
```

## Пример 6: Мод, изменяющий баланс игры

```gdscript
# balance_mod/scripts/main.gd
extends Mod

func _ready():
    # Изменение базовых параметров игры
    ModdingAPI.modify_game_setting("player_base_health", 150)
    ModdingAPI.modify_game_setting("player_base_mana", 100)
    ModdingAPI.modify_game_setting("combat_turn_time", 30)
```

## Пример 7: Мод, добавляющий новую локацию

```gdscript
# new_location_mod/scripts/main.gd
extends Mod

func _ready():
    # Регистрация новой локации
    var location = ModdingAPI.create_location("Заброшенная башня")
    location.description = "Таинственная башня, заброшенная много лет назад"
    location.level = 15
    location.enemies = ["ghost", "skeleton_mage"]
    location.loot_table = ["ancient_scroll", "magic_ring"]
    
    ModdingAPI.add_location(location)
```

## Рекомендации по созданию модов

1. Начинайте с простых модов
2. Используйте существующие примеры как шаблоны
3. Тщательно тестируйте моды
4. Документируйте код
5. Следите за производительностью