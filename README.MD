# parserDb

Набор инструментов, Python-скриптов и макросов для парсинга, импорта, экспорта и анализа данных в различных СУБД (MySQL, PostgreSQL, SQLite, Microsoft Access).

---

## 📂 Структура проекта

```text
parserDb/
├── parserAccess/          # Парсинг баз данных MS Access
│   ├── unPackZip1/        # Директория для исходных файлов БД Access
│   ├── main.py            # Основной скрипт парсинга
│   └── req.txt            # Зависимости для модуля Access
├── parserMysql/           # Утилиты для работы с MySQL
│   ├── findTable.py       # Поиск БД, таблиц, объектов и выгрузка столбцов
│   ├── select.py          # Выполнение SQL-запросов
│   ├── dropTables.py      # Удаление таблиц
│   └── *.bat              # Скрипты быстрого запуска для Windows
├── parserMysqlWeb/        # Веб-интерфейс для работы с MySQL на базе Django
│   ├── change/            # Файлы проекта для переноса на веб-сервер
│   ├── config.json        # Конфигурация веб-сервера
│   ├── installerDjango.ps1# PowerShell-скрипт для развертывания сервера
│   └── .env               # Переменные окружения (логины, пароли)
├── parserSqlite/          # Утилиты для работы с SQLite3
│   ├── addTable.py        # Создание таблиц в db.sqlite3
│   ├── findTable.py       # Поиск и фильтрация таблиц
│   └── *.bat              # Скрипты запуска
├── scripts/               # Вспомогательные системные скрипты
│   ├── checkPython.bat    # Проверка версии Python
│   └── git*.sh            # Скрипты автоматизации работы с Git
├── config.txt             # Основной файл конфигурации подключений к БД
├── correctMysqlQuerry.ddl # Примеры и анализ SQL-запросов MySQL
├── importExcelMysql.py    # Импорт данных из Excel в MySQL
├── importTxtPsql.py       # Импорт данных из TXT в PostgreSQL
├── importTxtPsqlData.txt  # Образец входных данных для PostgreSQL
├── parserMysql.xlsm       # Excel-книга с VBA-макросами для выгрузки из MySQL
├── requirements.txt       # Общие зависимости Python
└── startImportExcelMysql.bat # Запуск импорта из Excel в MySQL
```

---

## ⚙️ Установка и настройка

1. **Клонируйте репозиторий:**
   ```bash
   git clone https://github.com
   cd parserDb
   ```

2. **Проверьте версию Python (для Windows):**
   Запустите `scripts/checkPython.bat` или выполните в терминале `python --version`.

3. **Установите зависимости:**
   ```bash
   pip install -r requirements.txt
   ```
   *(Для работы с модулем MS Access дополнительно установите зависимости из `parserAccess/req.txt`)*.

4. **Настройте конфигурацию:**
   Откройте файл `config.txt` и укажите параметры подключения к вашим базам данных (строки, начинающиеся с `DB_`, а также `FILTER_TABLE` для SQLite).

---

## 🚀 Описание модулей и использование

### 1. Работа с MySQL (`parserMysql/`)
* **`findTable.py`** *(запуск через `startFindTable.bat`)* — интерактивный поиск по MySQL:
  * Просмотр списка всех доступных БД и таблиц.
  * Поиск конкретного объекта в выбранной БД.
  * **Опция 3:** Глубокий поиск объекта по всем базам и таблицам с сохранением отчета в `logout.txt`.
  * **Опция 4:** Выгрузка названий столбцов (удобно для сверки структур таблиц).
* **`select.py`** *(запуск через `startSelect.bat`)* — выполнение пользовательских SELECT-запросов к MySQL.
* **`dropTables.py`** *(запуск через `startDropTables.bat`)* — пакетное или выборочное удаление таблиц из БД.

### 2. Импорт данных из файлов
* **Excel ➔ MySQL (`importExcelMysql.py`):**
  Переносит данные из таблиц Excel в MySQL. Для запуска в Windows используйте `startImportExcelMysql.bat`.
* **TXT ➔ PostgreSQL (`importTxtPsql.py`):**
  Загружает данные из текстового файла в PostgreSQL.
  * Перед запуском заполните параметры подключения к БД внутри скрипта `importTxtPsql.py`.
  * Формат входных данных должен соответствовать шаблону `importTxtPsqlData.txt`.

### 3. Выгрузка в Excel (`parserMysql.xlsm`)
Книга Excel с макросами для прямого подключения к MySQL:
1. Откройте файл и измените параметры подключения к БД.
2. При необходимости отредактируйте SQL-запросы в режиме разработчика (Alt + F11).
3. Запустите макрос — результаты выгрузятся на **Лист1**.

### 4. Парсинг MS Access (`parserAccess/`)
1. Поместите файлы баз данных Access в папку `parserAccess/unPackZip1/`.
2. Запустите `parserAccess/main.py`.
3. Результаты парсинга будут сохранены в лог-файл.

### 5. Работа с SQLite (`parserSqlite/`)
Убедитесь, что файл базы данных `db.sqlite3` находится в одной директории со скриптами:
* **`addTable.py`** *(запуск через `startAddTable.bat`)* — добавляет новые таблицы в БД (предварительно задайте структуру таблиц в коде скрипта).
* **`findTable.py`** *(запуск через `startfindTable.bat`)* — выводит список таблиц. Для фильтрации укажите имя таблицы в `config.txt` в параметре `FILTER_TABLE`.

### 6. Веб-интерфейс MySQL (`parserMysqlWeb/`)
Веб-приложение на базе Django для работы с БД через браузер:
1. Укажите логины и пароли в файле `parserMysqlWeb/.env`.
2. Настройте параметры в `parserMysqlWeb/config.json`.
3. Для автоматической установки окружения и сервера используйте PowerShell-скрипт `installerDjango.ps1`, затем перенесите файлы из директории `change/` в развернутый проект.

---

## ⚠️ Рекомендации по безопасности
* Перед публикацией изменений в Git убедитесь, что файлы `config.txt` и `parserMysqlWeb/.env` с реальными паролями добавлены в `.gitignore` и не попадают в публичный репозиторий.
