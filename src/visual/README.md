# VisualStyleManager

Менеджер визуальных стилей для переключения между режимами **Minecraft (Voxel)** и **Anime (Cel-Shader)** на лету.

## Возможности

- 🔄 Переключение между стилями в реальном времени
- 🎮 4 уровня качества (LOW, MEDIUM, HIGH, ULTRA)
- 🎨 Поддержка обоих стилей одновременно
- ⚙️ Гибкая настройка параметров рендеринга
- 💾 Сохранение/загрузка настроек
- 🔌 Автоматическое обнаружение VoxelWorld и AnimeStyleManager

## Использование

### Базовое переключение стилей

```gdscript
# Переключение на Minecraft стиль
VisualStyleManager.set_voxel_mode(true)

# Переключение на Anime стиль
VisualStyleManager.set_anime_mode(true)

# Тоггл между стилями
VisualStyleManager.toggle_style()
```

### Установка качества

```gdscript
# Установка качества LOW
VisualStyleManager.apply_quality(VisualStyleManager.QualityLevel.LOW)

# Установка качества ULTRA
VisualStyleManager.apply_quality(VisualStyleManager.QualityLevel.ULTRA)
```

### Получение информации

```gdscript
var info = VisualStyleManager.get_current_style_info()
print("Текущий стиль: ", info.style_name)
print("Качество: ", info.quality)
print("Voxel активен: ", info.voxel_active)
```

### Сигналы

```gdscript
func _ready():
    VisualStyleManager.style_changed.connect(_on_style_changed)
    VisualStyleManager.quality_changed.connect(_on_quality_changed)
    VisualStyleManager.voxel_mode_enabled.connect(_on_voxel_mode_enabled)
    VisualStyleManager.anime_mode_enabled.connect(_on_anime_mode_enabled)

func _on_style_changed(style_name: String):
    print("Стиль изменён на: ", style_name)

func _on_quality_changed(quality_level: int):
    print("Качество изменено на уровень: ", quality_level)
```

### Регистрация менеджеров вручную

```gdscript
# Если автоматическое обнаружение не работает
var voxel_world = get_node("/root/World/VoxelWorld")
var anime_manager = get_node("/root/AnimeStyleManager")

VisualStyleManager.register_voxel_world(voxel_world)
VisualStyleManager.register_anime_manager(anime_manager)
```

### Сохранение и загрузка настроек

```gdscript
# Сохранение
var settings = VisualStyleManager.save_settings()
SaveSystem.save_visual_settings(settings)

# Загрузка
var loaded_settings = SaveSystem.load_visual_settings()
VisualStyleManager.load_settings(loaded_settings)
```

## Доступные стили

| Стиль | Описание | Особенности |
|-------|----------|-------------|
| **Minecraft/Voxel** | Блочный воксельный стиль | Воксели, блоки, загрузка чанков |
| **Anime/Cel-Shader** | Аниме стиль с cel-shading | Cel-shading, контуры, bloom эффект |

## Уровни качества

| Уровень | FPS Cap | Voxel Distance | SSAO | SSR | Glow |
|---------|---------|----------------|------|-----|------|
| **LOW** | 30 | 2 чанка | ❌ | ❌ | ✅ (3 уровня) |
| **MEDIUM** | 60 | 4 чанка | ✅ | ❌ | ✅ (5 уровней) |
| **HIGH** | 120 | 8 чанков | ✅ | ✅ | ✅ (7 уровней) |
| **ULTRA** | ∞ | 16 чанков | ✅ | ✅ | ✅ (10 уровней) |

## API Reference

### Enums

```gdscript
enum VisualStyle { MINECRAFT, ANIME }
enum QualityLevel { LOW, MEDIUM, HIGH, ULTRA }
```

### Properties

- `default_style: VisualStyle` - Стиль по умолчанию
- `default_quality: QualityLevel` - Качество по умолчанию
- `enable_voxel_shadows: bool` - Включить тени для вокселей
- `enable_anime_outlines: bool` - Включить контуры для аниме
- `current_style: VisualStyle` - Текущий стиль (read-only)
- `current_quality: QualityLevel` - Текущее качество (read-only)
- `is_voxel_mode_active: bool` - Активен ли режим вокселей (read-only)
- `is_anime_mode_active: bool` - Активен ли режим аниме (read-only)

### Methods

#### Основные

- `apply_style(style: VisualStyle)` - Применить стиль
- `apply_quality(level: QualityLevel)` - Применить качество
- `toggle_style()` - Переключить стиль
- `set_voxel_mode(enabled: bool)` - Установить режим вокселей
- `set_anime_mode(enabled: bool)` - Установить режим аниме

#### Информация

- `get_current_style_info() -> Dictionary` - Получить информацию о текущем стиле
- `get_available_styles() -> Array` - Получить список доступных стилей

#### Регистрация

- `register_voxel_world(world: Node)` - Зарегистрировать VoxelWorld
- `register_anime_manager(manager: Node)` - Зарегистрировать AnimeStyleManager

#### Настройки

- `save_settings() -> Dictionary` - Сохранить настройки
- `load_settings(settings: Dictionary)` - Загрузить настройки

### Signals

- `style_changed(style_name: String)` - Вызывается при смене стиля
- `quality_changed(quality_level: int)` - Вызывается при смене качества
- `voxel_mode_enabled(enabled: bool)` - Вызывается при включении/выключении вокселей
- `anime_mode_enabled(enabled: bool)` - Вызывается при включении/выключении аниме

## Интеграция с UI

Пример создания простого UI для переключения стилей:

```gdscript
extends Control

@onready var style_button = $StyleButton
@onready var quality_button = $QualityButton

func _ready():
    update_ui()
    
    VisualStyleManager.style_changed.connect(update_ui)
    VisualStyleManager.quality_changed.connect(update_ui)

func _on_style_button_pressed():
    VisualStyleManager.toggle_style()

func _on_quality_button_pressed():
    var next_quality = (VisualStyleManager.current_quality + 1) % 4
    VisualStyleManager.apply_quality(next_quality)

func update_ui():
    var info = VisualStyleManager.get_current_style_info()
    style_button.text = "Стиль: " + info.style_name
    quality_button.text = "Качество: " + info.quality
```

## Обратная совместимость

- ✅ Полностью совместим с существующим `AnimeStyleManager`
- ✅ Работает с `VoxelWorld` без модификаций
- ✅ Не ломает существующие save-файлы
- ✅ Сохраняет все публичные сигнатуры методов
- ✅ Автоматически обнаруживает существующие менеджеры

## Примеры использования

### Горячие клавиши

```gdscript
func _input(event):
    if event.is_action_pressed("toggle_visual_style"):
        VisualStyleManager.toggle_style()
    elif event.is_action_pressed("increase_quality"):
        var next = min(VisualStyleManager.current_quality + 1, 3)
        VisualStyleManager.apply_quality(next)
    elif event.is_action_pressed("decrease_quality"):
        var next = max(VisualStyleManager.current_quality - 1, 0)
        VisualStyleManager.apply_quality(next)
```

### Плавный переход

```gdscript
func transition_to_style(target_style: VisualStyle, duration: float = 1.0):
    var tween = create_tween()
    tween.tween_method(
        func(progress):
            # Здесь можно добавить эффекты перехода
            pass,
        0.0, 1.0, duration
    )
    tween.tween_callback(func(): VisualStyleManager.apply_style(target_style))
```

## Отладка

```gdscript
# Вывод полной информации о состоянии
func debug_visual_state():
    var info = VisualStyleManager.get_current_style_info()
    print("=== Visual State ===")
    for key in info:
        print("%s: %s" % [key, info[key]])
    print("====================")
```
