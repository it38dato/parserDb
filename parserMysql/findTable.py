import mysql.connector
from libs.importKeys import importDataFile

listDataFile = importDataFile([])
count = 0
for index in listDataFile:
    print(str(count)+" - "+index)
    count = count + 1

listCmd = [
    "Показать список БД (1)",
    "Показать Список таблиц во всей БД (2)", 
    "Найти объект во всей базе и во всех таблицах (3)",
    "Показать Список колонок таблиц во всей БД (4)",
    "Выйти (0)"
    ]

while True:
    print("Список доступных команд:\n ", listCmd)
    choiceCmd = input("Выполните действия: ")
    print(f"... Выбор действия {choiceCmd}\n")

    choiceDB = input("Выберите БД (Nokia / Ericsson / Django): ")
    print(f"... Выбор БД {choiceDB}\n")

    match choiceDB:
        case "Nokia":
            print("+ Выбрана БД Nokia")
            print("!")
            try:
                print(f"Попытка подключения к {listDataFile[23]}...")
                conn = mysql.connector.connect(
                    host=listDataFile[23],  # .strip() уберет лишние пробелы/переносы
                    user=listDataFile[17],
                    password=listDataFile[19],
                    use_pure=True,  # Использовать реализацию на Python вместо C
                    #connect_timeout=10
                )
                cursor = conn.cursor()
                print("+ Подключение успешно")
            except Exception as e:
                print(f"- Ошибка подключения: {e}")
                break  # Прервать цикл, если БД недоступна

        case "Ericsson":
            print("+ Выбрана БД Ericsson")

            conn = mysql.connector.connect(
                    host=listDataFile[21],
                    user=listDataFile[17],
                    password=listDataFile[19],
                    use_pure=True,
                )
            cursor = conn.cursor()
        case "Django":
            print("+ Выбрана БД DjangoTemplate")

            conn = mysql.connector.connect(
                    host=listDataFile[7],
                    user=listDataFile[3],
                    password=listDataFile[5],
                    use_pure=True,
                )
            cursor = conn.cursor()
        
        case _:
            print("- Incorrect actions!")
            break

    match choiceCmd:
        case "1":
            print("+ Выполнение действия 1")
          
            cursor.execute("SHOW DATABASES")
            databases = cursor.fetchall()
            print("+ Получен список БД")
            print(databases)
        case "2":
            print("+ Выполнение действия 2")

            cursor.execute("SHOW DATABASES")
            databases = cursor.fetchall()
            for db_tuple in databases:
                database = db_tuple[0]    
                cursor.execute(f"USE {database}")
                cursor.execute("SHOW TABLES")
                tables = [table[0] for table in cursor.fetchall()]
                print(f"Tables Name: {tables}; Database Name: {database}")
        case "3":
            with open('logOut.txt', 'w', encoding='utf-8') as f:
                f.write("Создан файл\n ")

            print("+ Выполнение действия 3")
            obj = input("Выберите объект, который необходимо найти: ")

            # Определяем список баз, которые нужно пропустить
            exclude_dbs = ['information_schema', 'performance_schema', 'mysql', 'test', 'sys', 'zabbix', 'replication', 'TEST_CreateSite', 'CreateSite', 'config_Bulat2g', 'config_Bulat4g', 'config_Hytera4G']

            cursor.execute("SHOW DATABASES")
            databases = cursor.fetchall()
            for db_tuple in databases:
                database = db_tuple[0]

                # ПРОВЕРКА: если база в списке исключений, пропускаем её
                if database.lower() in exclude_dbs:
                    continue

                cursor.execute(f"USE {database}")
                print(f"USE database: {database}")
                cursor.execute("SHOW TABLES")
                tables = [table[0] for table in cursor.fetchall()]
                for table in tables:
                    try: 
                        listField = []
                        cursor.execute(f"SHOW COLUMNS FROM {table}")
                        #print(table)
                        for (Field, Type, Null, Key, Default, Extra) in cursor:
                            listField.append(Field)
                        #print(listField)
                        for col in listField:
                            #cursor.execute("SELECT * FROM "+database+"."+table+" WHERE "+col+" LIKE '%"+obj+"%';")
                            cursor.execute("SELECT * FROM "+database+"."+table+" WHERE `"+col+"` LIKE '%"+obj+"%';")
                            listQuery = cursor.fetchall()
                            #print(f"Result Query SELECT * FROM {database}.{table} WHERE `{col}` LIKE '%{obj}%':\n {listQuery}")

                            #if listQuery == []:
                            #    #print(f"Пустой запрос ! Можно пропустить")
                            #    continue
                            #else:
                            #    print(f"Need check Query SELECT * FROM {database}.{table} WHERE `{col}` LIKE '%{obj}%':\n {listQuery}!")

                            for row in listQuery:
                                #print(f"Need check Query SELECT * FROM {database}.{table} WHERE `{col}` LIKE '%{obj}%':\n {listQuery}!")
                                #print(f"FIND object: {obj}")
                                #print(f"In line : {row}")
                                for i in row:
                                    #print(f"Object from Line: {i}")
                                    if obj in str(i):
                                        #print(f"Object from Line: {i}")
                                        #print(row)
                                        #print(f"Похожий объект {i} - Колонка {col} в таблице {table} из базы {database}.\nQuery SELECT * FROM {database}.{table} WHERE `{col}` LIKE '%{obj}%'!\n")
                                        with open('logOut.txt', 'a', encoding='utf-8') as f:
                                            f.write(f"Похожий объект {i} - Колонка {col} в таблице {table} из базы {database}.\nQuery SELECT * FROM {database}.{table} WHERE `{col}` LIKE '%{obj}%';\n ")
                                #if obj in row:
                                #    print(row)
                                #    print(f"Колонка {col} в таблице {table} из базы {database}")
                    except mysql.connector.errors.DatabaseError:
                        continue
            print("Результат сохранен в файле logOut.txt")
        case "4":
            print("+ Выполнение действия 2")

            cursor.execute("SHOW DATABASES")
            databases = cursor.fetchall()
            for db_tuple in databases:
                database = db_tuple[0]
                # Пропускаем системные базы, если они не нужны, чтобы избежать ошибок прав
                if database in ['information_schema', 'performance_schema', 'sys']:
                    continue
                try:
                    cursor.execute(f"USE {database}")
                    cursor.execute("SHOW TABLES")
                    tables = [table[0] for table in cursor.fetchall()]
                    #print(f"Tables Name: {tables}; Database Name: {database}")
                    for table in tables:
                        # Получаем список колонок для каждой таблицы
                        cursor.execute(f"SHOW COLUMNS FROM `{table}`")
                        columns = [col[0] for col in cursor.fetchall()]
                        print(f"Database: {database} | Table: {table}")
                        print(f"Columns: {', '.join(columns)}")
                except Exception as e:
                    print(f"Could not use database {database}: {e}")
        case "0":
            break
        case _:
            print("- Incorrect actions!")

    choiceContinue = input("Do you wish to continue? [y/n]: ").lower()
    print(f"... Выбор действия {choiceContinue}")
    #print(choiceContinue)

    while choiceContinue not in ['y', 'n']:
        choiceContinue = input("- Invalid input! Enter y/n: ").lower()
    if choiceContinue in ['y']:
        state = 2 
    elif choiceContinue in ['n']:
        break

    cursor.close()
    conn.close()