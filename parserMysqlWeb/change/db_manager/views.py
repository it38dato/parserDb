import pymysql
import psycopg2
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from .models import DBSettings

import mysql.connector
# Подключаем вашу функцию импорта кредов, если она лежит в корне или скриптах
#from scripts.importKeys import importDataFile 
import os

def get_client_db_connection(config):
    """
    Устанавливает динамическое соединение с внешней СУБД на основе конфигурации пользователя.
    """
    password = config.get_password()
    if config.db_type == 'postgresql':
        return psycopg2.connect(
            host=config.host,
            port=config.port,
            database=config.db_name,
            user=config.user_name,
            password=password,
            connect_timeout=5  # Ограничение по времени подключения
        )
    elif config.db_type == 'mysql':
        return pymysql.connect(
            host=config.host,
            port=config.port,
            database=config.db_name,
            user=config.user_name,
            password=password,
            connect_timeout=5
        )
    return None

@login_required
def dashboard(request):
    results = []
    search_query = ""
    
    if request.method == "POST" and "search_value" in request.POST:
        search_query = request.POST.get("search_value", "").strip()
        
        if search_query:
            # 1. Загружаем данные для подключения (как в вашем консольном скрипте)
            #listDataFile = importDataFile([])
            
            # 2. Определяем, какую БД выбрал пользователь. 
            # (Можно захардкодить одну или брать из сессии/запроса. Для примера берем Nokia)
            db_host = os.getenv('DB_CP_HOST')
            db_user = os.getenv('DB_CP_USERNAME')
            db_pass = os.getenv('DB_CP_PASSWORD')
            
            # Список баз для пропуска
            exclude_dbs = [
                'information_schema', 'performance_schema', 'mysql', 'test', 
                'sys', 'zabbix', 'replication', 'TEST_CreateSite', 'CreateSite', 
                'config_Bulat2g', 'config_Bulat4g', 'config_Hytera4G'
            ]
            
            conn = None
            cursor = None
            try:
                # Подключаемся к серверу
                conn = mysql.connector.connect(
                    host=db_host,
                    user=db_user,
                    password=db_pass,
                    use_pure=True
                )
                cursor = conn.cursor()
                
                # Получаем список всех БД на этом сервере
                cursor.execute("SHOW DATABASES")
                databases = [db[0] for db in cursor.fetchall()]
                
                for database in databases:
                    # Проверяем исключения
                    if database.lower() in [db.lower() for db in exclude_dbs]:
                        continue
                        
                    try:
                        cursor.execute(f"USE `{database}`")
                        cursor.execute("SHOW TABLES")
                        tables = [table[0] for table in cursor.fetchall()]
                        
                        for table in tables:
                            try:
                                # Получаем колонки таблицы
                                cursor.execute(f"SHOW COLUMNS FROM `{table}`")
                                fields = [col[0] for col in cursor.fetchall()]
                                
                                for col in fields:
                                    # Безопасный запрос с экранированием структуры и плейсхолдером для значения
                                    query = f"SELECT `{col}` FROM `{database}`.`{table}` WHERE `{col}` LIKE %s"
                                    cursor.execute(query, (f"%{search_query}%",))
                                    rows = cursor.fetchall()
                                    
                                    # Собираем совпадения для вывода на веб-страницу
                                    for row in rows:
                                        found_val = row[0]
                                        results.append({
                                            'database': database,
                                            'table': table,
                                            'column': col,
                                            'value': found_val
                                        })
                                        
                            except mysql.connector.Error:
                                continue # Если упала отдельная таблица, идем дальше
                    except mysql.connector.Error:
                        continue # Если не смогли сделать USE для базы, пропускаем её
                        
            except Exception as e:
                print(f"Ошибка подключения или выполнения: {e}")
            finally:
                if cursor: cursor.close()
                if conn: conn.close()

    # Передаем результаты поиска и поисковую строку обратно в интерфейс
    context = {
        'results': results,
        'search_query': search_query,
        'total_found': len(results)
    }
    return render(request, 'db_manager/dashboard.html', context)

@login_required
def db_settings(request):
    """
    Вьюха для создания и редактирования параметров подключения к внешней БД.
    """
    # Пытаемся получить текущие настройки, если они уже созданы
    try:
        config = request.user.db_config
    except DBSettings.DoesNotExist:
        config = None

    if request.method == 'POST':
        db_type = request.POST.get('db_type')
        host = request.POST.get('host')
        port = request.POST.get('port')
        db_name = request.POST.get('db_name')
        user_name = request.POST.get('user_name')
        password = request.POST.get('password')

        if not config:
            # Создаем новую запись, если её не было
            config = DBSettings(user=request.user)
        
        config.db_type = db_type
        config.host = host
        config.port = int(port) if port else (5432 if db_type == 'postgresql' else 3306)
        config.db_name = db_name
        config.user_name = user_name
        
        # Обновляем пароль только если пользователь ввел новое значение
        if password:
            config.set_password(password)

        try:
            # Небольшая проверка «на лету» перед сохранением параметров
            conn = get_client_db_connection(config)
            if conn:
                conn.close()
            
            config.save()
            messages.success(request, "Параметры подключения успешно сохранены и проверены!")
            return redirect('dashboard')
        except Exception as e:
            error_msg = f"Не удалось подключиться с указанными параметрами: {e}"
            messages.error(request, error_msg)

    return render(request, 'db_manager/settings.html', {'config': config})
