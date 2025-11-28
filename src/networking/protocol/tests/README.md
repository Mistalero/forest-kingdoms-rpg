# Тесты для игрового протокола Forest Kingdoms RPG

Эта директория содержит unit-тесты для всех компонентов игрового протокола обмена сообщениями.

## Структура тестов

- `test_message_types.gd` - Тесты для типов сообщений
- `test_message_structure.gd` - Тесты для структуры сообщений
- `test_message_serializer.gd` - Тесты для сериализатора
- `test_message_handler.gd` - Тесты для обработчиков сообщений
- `test_runner.gd` - Тестовый раннер для запуска всех тестов

## Запуск тестов

Для запуска всех тестов используйте тестовый раннер:

```gdscript
const TestRunner = preload("res://src/networking/protocol/tests/test_runner.gd")

func run_protocol_tests():
    var runner = TestRunner.new()
    var result = runner.run_all_tests()
    return result
```

Или запустите тесты для отдельных компонентов:

```gdscript
# Тесты для типов сообщений
const TestMessageTypes = preload("res://src/networking/protocol/tests/test_message_types.gd")
var message_types_test = TestMessageTypes.new()
var result1 = message_types_test.run_tests()

# Тесты для структуры сообщений
const TestMessageStructure = preload("res://src/networking/protocol/tests/test_message_structure.gd")
var message_structure_test = TestMessageStructure.new()
var result2 = message_structure_test.run_tests()

# Тесты для сериализатора
const TestMessageSerializer = preload("res://src/networking/protocol/tests/test_message_serializer.gd")
var message_serializer_test = TestMessageSerializer.new()
var result3 = message_serializer_test.run_tests()

# Тесты для обработчиков сообщений
const TestMessageHandler = preload("res://src/networking/protocol/tests/test_message_handler.gd")
var message_handler_test = TestMessageHandler.new()
var result4 = message_handler_test.run_tests()
```

## Покрытие тестами

Тесты охватывают следующие аспекты:

### Типы сообщений
- Проверка наличия всех определенных типов сообщений
- Валидация типов сообщений
- Функция проверки валидности типа сообщения
- Функция получения всех типов сообщений

### Структура сообщений
- Базовая структура сообщения (ID, временная метка, приоритет, TTL)
- Специализированные структуры (PlayerJoinMessage, MovementUpdateMessage, ChatMessage)
- Преобразование сообщений в словарь и обратно
- Валидация сообщений
- Проверка истечения времени жизни сообщений

### Сериализатор
- JSON сериализация/десериализация
- Бинарная сериализация/десериализация
- Автоматический выбор типа сериализации
- Получение размера сериализованных данных
- Валидация сериализованных данных

### Обработчики сообщений
- Инициализация обработчиков
- Обработка различных типов сообщений
- Создание и отправка сообщений
- Сигналы для уведомления о событиях

## Результаты тестирования

Тестовый раннер предоставляет подробную статистику:

- Количество пройденных тестов
- Количество проваленных тестов
- Общее количество тестов
- Результаты для каждого тестового набора

## Добавление новых тестов

Для добавления новых тестов:

1. Создайте новый файл теста в формате `test_*.gd`
2. Реализуйте функцию `run_tests()` которая возвращает `true` при успехе
3. Добавьте счетчики `tests_passed` и `tests_failed`
4. Добавьте вызов новых тестов в `test_runner.gd`
5. Обновите эту документацию

## Рекомендации по тестированию

1. Покрывайте все публичные методы и функции тестами
2. Тестируйте граничные условия и ошибочные ситуации
3. Используйте вспомогательные функции `assert_true()` и `assert_false()` для проверок
4. Добавляйте описательные сообщения к проверкам
5. Поддерживайте тесты в актуальном состоянии при изменении кода