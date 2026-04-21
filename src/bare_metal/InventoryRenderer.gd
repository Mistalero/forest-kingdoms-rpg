class_name InventoryRenderer
extends Node

## Рендерер инвентаря для Bare Metal режима
## Отображает предметы, экипировку и контейнеры

# Цвета для предметов
var colors: Dictionary = {
    "common": "\x1b[37m",     # Белый - обычное
    "uncommon": "\x1b[32m",   # Зелёный - необычное
    "rare": "\x1b[34m",       # Синий - редкое
    "epic": "\x1b[35m",       # Пурпурный - эпическое
    "legendary": "\x1b[33m",  # Жёлтый - легендарное
    "equipped": "\x1b[36m",   # Голубой - экипировано
    "reset": "\x1b[0m"
}

# Иконки типов предметов
var item_icons: Dictionary = {
    "weapon": "⚔️",
    "armor": "🛡️",
    "potion": "🧪",
    "food": "🍖",
    "scroll": "📜",
    "ring": "💍",
    "amulet": "📿",
    "material": "🪵",
    "key": "🗝️",
    "misc": "📦"
}

func _ready() -> void:
    pass

func render_inventory(items: Array, capacity: int = -1, title: String = "Инвентарь") -> String:
    """Рендеринг полного инвентаря"""
    var output: Array[String] = []
    
    output.append("")
    output.append("=== %s ===" % title)
    output.append("")
    
    if capacity > 0:
        output.append("Вес: %d/%d" % [get_total_weight(items), capacity])
        output.append("")
    
    if items.is_empty():
        output.append("[Инвентарь пуст]")
    else:
        for i in range(items.size()):
            var item = items[i]
            var line = render_item_short(item, i + 1)
            output.append(line)
    
    output.append("")
    
    return "\n".join(output)

func render_item_short(item: Dictionary, index: int = -1) -> String:
    """Краткое отображение предмета"""
    var name = item.get("name", "Неизвестно")
    var rarity = item.get("rarity", "common")
    var type_name = item.get("type", "misc")
    var quantity = item.get("quantity", 1)
    var equipped = item.get("equipped", false)
    var weight = item.get("weight", 0)
    
    # Получение цвета по редкости
    var color_code = colors.get(rarity, colors["common"])
    
    # Получение иконки по типу
    var icon = item_icons.get(type_name, item_icons["misc"])
    
    # Формирование строки
    var index_str = ""
    if index > 0:
        index_str = "[%d] " % index
    
    var equipped_mark = " [Э]" if equipped else ""
    var qty_mark = " (x%d)" % quantity if quantity > 1 else ""
    var weight_mark = " (%.1f кг)" % weight if weight > 0 else ""
    
    return "%s%s%s%s%s%s%s%s" % [
        index_str,
        icon, " ",
        color_code, name, colors["reset"],
        equipped_mark, qty_mark, weight_mark
    ]

func render_item_detail(item: Dictionary) -> String:
    """Детальное отображение предмета"""
    var output: Array[String] = []
    
    var name = item.get("name", "Неизвестно")
    var rarity = item.get("rarity", "common")
    var type_name = item.get("type", "misc")
    var description = item.get("description", "")
    
    # Заголовок
    var color_code = colors.get(rarity, colors["common"])
    output.append("")
    output.append("=== %s%s%s ===" % [color_code, name, colors["reset"]])
    output.append("")
    
    # Основная информация
    output.append("Тип: %s" % item_icons.get(type_name, "📦") + " " + type_name.capitalize())
    output.append("Редкость: %s" % rarity.capitalize())
    
    if item.has("weight"):
        output.append("Вес: %.1f кг" % item["weight"])
    
    if item.has("value"):
        output.append("Цена: %d золотых" % item["value"])
    
    output.append("")
    
    # Описание
    if not description.is_empty():
        output.append("Описание:")
        output.append("  %s" % description)
        output.append("")
    
    # Характеристики
    if item.has("stats") and not item["stats"].is_empty():
        output.append("Характеристики:")
        for stat in item["stats"]:
            output.append("  • %s" % stat)
        output.append("")
    
    # Требования
    if item.has("requirements") and not item["requirements"].is_empty():
        output.append("Требования:")
        for req in item["requirements"]:
            output.append("  • %s" % req)
        output.append("")
    
    # Эффекты
    if item.has("effects") and not item["effects"].is_empty():
        output.append("Эффекты:")
        for effect in item["effects"]:
            output.append("  • %s" % effect)
        output.append("")
    
    return "\n".join(output)

func render_equipment(equipped_items: Dictionary) -> String:
    """Рендеринг экипировки"""
    var output: Array[String] = []
    
    output.append("")
    output.append("=== Экипировка ===")
    output.append("")
    
    # Слоты экипировки
    var slots = ["head", "neck", "chest", "shoulders", "arms", "hands", 
                 "waist", "legs", "feet", "main_hand", "off_hand", "ring1", "ring2"]
    
    var slot_names = {
        "head": "Голова",
        "neck": "Шея",
        "chest": "Тело",
        "shoulders": "Плечи",
        "arms": "Руки",
        "hands": "Кисти",
        "waist": "Пояс",
        "legs": "Ноги",
        "feet": "Ступни",
        "main_hand": "Основная рука",
        "off_hand": "Вторая рука",
        "ring1": "Кольцо 1",
        "ring2": "Кольцо 2"
    }
    
    var has_equipment = false
    
    for slot in slots:
        var slot_name = slot_names.get(slot, slot)
        
        if equipped_items.has(slot) and equipped_items[slot]:
            var item = equipped_items[slot]
            has_equipment = true
            output.append("  %s: %s" % [slot_name, render_item_short(item)])
        else:
            output.append("  %s: [Пусто]" % slot_name)
    
    output.append("")
    
    if not has_equipment:
        output.append("[Нет экипированных предметов]")
        output.append("")
    
    return "\n".join(output)

func render_container(container_data: Dictionary) -> String:
    """Рендеринг содержимого контейнера"""
    var output: Array[String] = []
    
    var container_name = container_data.get("name", "Контейнер")
    var items = container_data.get("items", [])
    var capacity = container_data.get("capacity", -1)
    
    output.append("")
    output.append("=== %s ===" % container_name)
    output.append("")
    
    if capacity > 0:
        output.append("СLOTS: %d/%d" % [items.size(), capacity])
        output.append("")
    
    if items.is_empty():
        output.append("[Пусто]")
    else:
        for i in range(items.size()):
            var item = items[i]
            output.append("  [%d] %s" % [i + 1, render_item_short(item)])
    
    output.append("")
    
    return "\n".join(output)

func render_shop(shop_data: Dictionary, player_gold: int = 0) -> String:
    """Рендеринг магазина/торговца"""
    var output: Array[String] = []
    
    var shop_name = shop_data.get("name", "Магазин")
    var merchant_name = shop_data.get("merchant", "Торговец")
    var items = shop_data.get("items", [])
    
    output.append("")
    output.append("=== %s ===" % shop_name)
    output.append("Торговец: %s" % merchant_name)
    output.append("Ваше золото: %d" % player_gold)
    output.append("")
    output.append("Товары:")
    output.append("")
    
    if items.is_empty():
        output.append("  [Нет товаров]")
    else:
        for i in range(items.size()):
            var item = items[i]
            var price = item.get("price", 0)
            var can_afford = player_gold >= price
            
            var price_color = colors["heal"] if can_afford else colors["damage"]
            
            output.append("  [%d] %s - %s%d золотых%s" % [
                i + 1,
                render_item_short(item),
                price_color,
                price,
                colors["reset"]
            ])
    
    output.append("")
    
    return "\n".join(output)

func get_total_weight(items: Array) -> float:
    """Подсчёт общего веса предметов"""
    var total: float = 0.0
    
    for item in items:
        if item.has("weight"):
            var qty = item.get("quantity", 1)
            total += item["weight"] * qty
    
    return total

func get_total_value(items: Array) -> int:
    """Подсчёт общей стоимости предметов"""
    var total: int = 0
    
    for item in items:
        if item.has("value"):
            var qty = item.get("quantity", 1)
            total += item["value"] * qty
    
    return total

func sort_items_by_rarity(items: Array) -> Array:
    """Сортировка предметов по редкости"""
    var rarity_order = {"legendary": 0, "epic": 1, "rare": 2, "uncommon": 3, "common": 4}
    
    var sorted_items = items.duplicate()
    sorted_items.sort_custom(func(a, b):
        var a_rarity = rarity_order.get(a.get("rarity", "common"), 4)
        var b_rarity = rarity_order.get(b.get("rarity", "common"), 4)
        return a_rarity < b_rarity
    )
    
    return sorted_items

func set_color(type: String, color_code: String) -> void:
    """Установка цвета для типа предмета"""
    colors[type] = color_code

func enable_colors(enabled: bool) -> void:
    """Включение/отключение цветов"""
    if not enabled:
        for key in colors:
            colors[key] = ""
    else:
        colors["common"] = "\x1b[37m"
        colors["uncommon"] = "\x1b[32m"
        colors["rare"] = "\x1b[34m"
        colors["epic"] = "\x1b[35m"
        colors["legendary"] = "\x1b[33m"
        colors["equipped"] = "\x1b[36m"
        colors["reset"] = "\x1b[0m"
