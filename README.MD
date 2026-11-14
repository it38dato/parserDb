importTxtPsql* - файлы для переноса данных из файла *.txt в БД postgresql. файл importTxtPsqlData.txt это образец заполнения данных. в файле imprortTxtPsql.py необходимо заполнить параметры БД
importExcelMysql.py - Скрипт для переноса данных с excel в mysql.
startImportExcelMysql.bat - Запускает проект importExcelMysql
parserAccess/unPackZip1/* - файлы access бд для сбора данных
parserAccess/req.txt - файл для установки зависимости при работе с проектом
parserAccess/main.py - основной скрипт для запуска проекта. Скрипт парсит файлы БД access. в лог сохраняет результаты
parserSqlite/addTable.py - Скрипт для добавления таблиц в БД Sqlite. необходимо добавить свои параметры таблиц и db.sqlite3 должен быть рядом с скриптом.
parserSqlite/startAddTable.bat - Запускает проект addTable
parserSqlite/findTable.py - скрипт покажет список таблиц БД в Sqlite3. нужно в файле config.txt в строке начиная FILTER_TABLE добавить таблицу, которую хотите найти и db.sqlite3 должен быть рядом с скриптом.
parserSqlite/startfindTable.bat - Запускает проект findTable
config.txt - Параметры для работы с БД
parserMysql.xlsm - проект, который делает выполняет подключение к БД MySql и выгружает таблицу из Mysql. для запуска в файле parserMysql.xlsm необходимо поменять параметры БД и режиме разработчика менять запросы. в Лист1 -отобразится информация после запуска кода.
parserMysql/findTable.py - Скрипт для поиска таблиц и объектов в БД mysql с полезными опциями. Скрипт может показать список всех БД, список всех таблиц, которые находятся в БД и найти объект в выбраной БД. опция 3 более точно находит объект во всем базам данных и таблицам и в logout.txt можно посмотреть результаты. опция 4 выполняет выгрузку названия стоблцов и необходима при сравнении данных по названиям стоблцов. Необходимо в conifg.txt строки начиная с DB_ добавить свои параметры.
parserMysql/startFindTable.bat - Запускает проект findTable
parserMysql/select.py - Скрипт, который выполняет запросы с mysql 
parserMysql/startSelect.bat - Запускает проект select
parserMysql/dropTables.py - Скрипт, который удаляет таблицы с mysql 
parserMysql/startDropTables.bat - Запускает проект dropTables
correctMysqlQuerry.ddl - Анализ запроса mysql
parserMysqlWeb/.env - логины и пароли для работы с вебсервером
parserMysqlWeb/config.json - настройка для вебсервера джанго
parserMysqlWeb/installerDjango.ps1 - Скрипт для настройки вебсервера
parserMysqlWeb/change/* - проект, который можно локально перенести в настроенный проект вебсервера
scripts/checkPython.bat - проверяет версию питона
scripts/git* - скрипты (*.sh) для подготовки данных и работы с Git