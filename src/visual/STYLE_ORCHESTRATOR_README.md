# Visual Style Orchestrator

## 🎨 Опциональное переключение стилей на лету

**Принцип работы:** Всё опционально, ничего не удаляется. Оркестратор работает как внешний контроллер, который управляет уже существующими системами рендеринга (Voxel и Anime), не модифицируя их исходный код.

---

## 🚀 Быстрый старт

### 1. Автоматическая регистрация
Система автоматически ищет менеджеры стилей при старте:
- `/root/VoxelWorld` - для Minecraft/Voxel стиля
- `/root/AnimeStyleManager` - для Anime/Cel-shading стиля

### 2. Переключение стилей в коде

```gdscript
# Переключить на Minecraft стиль
VisualStyleOrchestrator.set_voxel_style()

# Переключить на Anime стиль
VisualStyleOrchestrator.set_anime_style()

# Отключить спецэффекты (базовая отрисовка)
VisualStyleOrchestrator.set_base_style()

# Toggle (циклическое переключение)
VisualStyleOrchestrator.toggle_style()
```

### 3. Управление качеством

```gdscript
# Установить качество (LOW, MEDIUM, HIGH, ULTRA)
VisualStyleOrchestrator.set_quality(VisualStyleOrchestrator.QualityLevel.HIGH)
```

### 4. Горячие клавиши (встроены по умолчанию)
- **Esc** - переключение стиля
- **1** - LOW качество
- **2** - MEDIUM качество
- **3** - HIGH качество
- **4** - ULTRA качество

---

## 📡 Сигналы для UI

```gdscript
func _ready():
    VisualStyleOrchestrator.style_changed.connect(_on_style_changed)
    VisualStyleOrchestrator.quality_changed.connect(_on_quality_changed)

func _on_style_changed(style_name: String):
    print("Текущий стиль: ", style_name)
    # Обновить UI, иконки, настройки...

func _on_quality_changed(level: int):
    print("Качество: ", level)
    # Обновить ползунок качества в настройках...
```

---

## ⚙️ Настройка в инспекторе

После добавления сцены или в Project Settings:

| Параметр | Тип | Описание |
|----------|-----|----------|
| `voxel_manager_path` | NodePath | Путь к Voxel менеджеру (по умолчанию: `/root/VoxelWorld`) |
| `anime_manager_path` | NodePath | Путь к Anime менеджеру (по умолчанию: `/root/AnimeStyleManager`) |
| `enable_voxel_style` | bool | Глобально включить/выключить возможность использования воксельного стиля |
| `enable_anime_style` | bool | Глобально включить/выключить возможность использования аниме стиля |

---

## 🔌 Интеграция с существующими системами

### Требования к менеджерам стилей

Оркестратор использует универсальный подход и пробует несколько стратегий для активации/деактивации:

1. **Метод `set_active(bool)`** - предпочтительный вариант
2. **Свойство `active`** - если метод отсутствует
3. **Process режим** - остановка логики через `set_process(false)`
4. **Видимость** - для визуальных нод (`CanvasItem`, `Node3D`)

### Пример минимальной совместимости

Если ваш менеджер стилей поддерживает хотя бы один из этих подходов, он будет работать с оркестратором:

```gdscript
# Вариант 1: Метод set_active
func set_active(active: bool) -> void:
    visible = active
    set_process(active)

# Вариант 2: Свойство active
var active: bool = true:
    setget _set_active

func _set_active(value: bool):
    active = value
    visible = value

# Вариант 3: Ничего не делать (оркестратор сам задизейблит process)
# Просто убедитесь, что нода существует по указанному пути
```

---

## 🛡️ Обратная совместимость

### Гарантии:
- ✅ **Ни один существующий файл не модифицируется**
- ✅ **Все публичные сигнатуры сохраняются**
- ✅ **Работает даже если один из менеджеров отсутствует**
- ✅ **Безопасное переключение без конфликтов ресурсов**

### Что происходит при переключении:
1. Все активные стили корректно отключаются
2. Включается только выбранный стиль
3. Сбрасываются настройки окружения (Environment)
4. Испускается сигнал `style_changed`

---

## 📊 Таблица стилей

| Стиль | Константа | Описание |
|-------|-----------|----------|
| **Base/Default** | `StyleType.NONE` | Базовая отрисовка Godot без пост-процессинга |
| **Minecraft/Voxel** | `StyleType.VOXEL` | Воксельная графика, блочный мир |
| **Anime/Cel-Shader** | `StyleType.ANIME` | Аниме стиль, cel-shading, пост-эффекты |
| **Hybrid** | `StyleType.HYBRID` | Зарезервировано для будущего смешивания |

---

## 🎯 Примеры использования

### 1. Создание кнопки переключения в UI

```gdscript
extends Button

func _ready():
    pressed.connect(_on_pressed)
    VisualStyleOrchestrator.style_changed.connect(_update_button_text)
    _update_button_text()

func _on_pressed():
    VisualStyleOrchestrator.toggle_style()

func _update_button_text():
    var info = VisualStyleOrchestrator.get_current_style_info()
    text = "Стиль: " + info.style_name
```

### 2. Настройка в меню опций

```gdscript
extends VBoxContainer

@onready var style_dropdown: OptionButton = $StyleDropdown
@onready var quality_slider: HSlider = $QualitySlider

func _ready():
    _populate_styles()
    style_dropdown.item_selected.connect(_on_style_selected)
    quality_slider.value_changed.connect(_on_quality_changed)

func _populate_styles():
    style_dropdown.add_item("Base", 0)
    style_dropdown.add_item("Minecraft", 1)
    style_dropdown.add_item("Anime", 2)
    
    # Выбрать текущий
    var current = VisualStyleOrchestrator.current_style
    style_dropdown.select(current)

func _on_style_selected(index: int):
    match index:
        0: VisualStyleOrchestrator.set_base_style()
        1: VisualStyleOrchestrator.set_voxel_style()
        2: VisualStyleOrchestrator.set_anime_style()

func _on_quality_changed(value: float):
    var level = int(value)
    VisualStyleOrchestrator.set_quality(level)
```

### 3. Проверка доступности перед использованием

```gdscript
func _ready():
    var info = VisualStyleOrchestrator.get_current_style_info()
    
    if not info.voxel_available:
        print("Voxel стиль недоступен - менеджер не найден")
        # Скрыть кнопку вокселей в UI
    
    if not info.anime_available:
        print("Anime стиль недоступен - менеджер не найден")
        # Скрыть кнопку аниме в UI
```

---

## 🐛 Отладка

### Логи переключения
Оркестратор выводит подробные логи в консоль:
```
[VisualStyleOrchestrator] Voxel manager найден: VoxelWorld
[VisualStyleOrchestrator] Anime manager найден: AnimeStyleManager
[VisualStyleOrchestrator] Стиль переключен на: Minecraft/Voxel
[VisualStyleOrchestrator] Качество установлено: HIGH
```

### Получение полной информации
```gdscript
var info = VisualStyleOrchestrator.get_current_style_info()
print(info)
# Вывод:
# {
#   "style": 1,
#   "style_name": "Minecraft/Voxel",
#   "quality": 2,
#   "voxel_available": true,
#   "anime_available": true
# }
```

---

## 📝 Примечания

1. **Автлоад**: Оркестратор зарегистрирован как autoload `VisualStyleOrchestrator`
2. **Инициализация**: Менеджеры обнаруживаются в `_ready()` после первой рамки
3. **Безопасность**: Если менеджер не найден, вызов методов стиля безопасно игнорируется с warning
4. **Расширяемость**: Можно добавить поддержку новых стилей через enum `StyleType`

---

## 🔮 Планы развития

- [ ] Поддержка гибридного режима (Voxel + Anime одновременно)
- [ ] Сохранение настроек в конфиг проекта
- [ ] Анимации плавного перехода между стилями
- [ ] Профилирование производительности для каждого стиля
- [ ] Интеграция с системой достижений (смена стиля как достижение)
