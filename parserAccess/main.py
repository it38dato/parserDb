import pyodbc
import pandas as pd
import os

# --- Блок выбора базы данных Access ---
mdb_dir = input("\nВведите путь к папке с файлами .mdb: ").strip('" ')
# Получаем список всех .mdb файлов в указанной папке
mdb_files = [f for f in os.listdir(mdb_dir) if f.lower().endswith('.mdb')]
if not mdb_files:
    print(f"В папке {mdb_dir} не найдено файлов .mdb!")
    exit()
print("\nСписок найденных баз данных:")
for i, filename in enumerate(mdb_files):
    print(f"{i}: {filename}")

file_path = input("Введите путь к файлу Excel: ").strip('"') # Убираем кавычки, если путь скопирован как ссылка
# Читаем все листы, чтобы показать список
excel_file = pd.ExcelFile(file_path, engine='pyxlsb')
print("\nСписок листов в файле:")
for i, sheet in enumerate(excel_file.sheet_names):
    print(f"{i}: {sheet}")
sheet_idx = int(input("Введите номер нужного листа: "))
sheet_name = excel_file.sheet_names[sheet_idx]

# Читаем выбранный лист (только строку для предпросмотра)
#dfSheet = pd.read_excel(file_path, sheet_name=sheet_name, engine='pyxlsb', nrows=1)
#print(dfSheet.to_string(index=False))
dfSheet = pd.read_excel(file_path, sheet_name=sheet_name, engine='pyxlsb')
#print("\nстрока таблицы:")
#print(dfSheet.tail(1).to_string(index=False))

# Получаем значения строки в виде списка
#row_values = dfSheet.iloc[0].tolist()
row_values = dfSheet.iloc[-1].tolist()
print("\nСписок значений строки:")
for i, value in enumerate(row_values):
    # Выводим индекс и значение (заменяя NaN на пустую строку для красоты)
    val_str = str(value) if pd.notna(value) else "[Пусто]"
    print(f"{i}: {val_str}")

# target_value = "22:собст. АМС выше 10 м на крыше"
# Если нужно использовать значение из Excel как target_value:
# target_value = str(dfSheet.iloc[0, 0]) # Например, берем первую ячейку
# target_value = input("Введите ячейку таблицы: ")
inputValue = int(input("\nВведите номер значения, которое нужно искать в Access: "))
target_value = str(row_values[inputValue])
print(f"Выбрана ячейка: {target_value}")

# 2. Основной цикл по всем найденным БД
for filename in mdb_files:
    chosen_mdb = os.path.join(mdb_dir, filename)
    print(f"\n--- Сканирую базу: {filename} ---")
    try:
        #conn_str = r'DRIVER={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=C:\Users\david.gabunia\parserDB\findTableAccess\unPackZip1\cfgBSS_RanSharing.mdb;'
        conn_str = f'DRIVER={{Microsoft Access Driver (*.mdb, *.accdb)}};DBQ={chosen_mdb};'
        with pyodbc.connect(conn_str) as conn:
            cursor = conn.cursor()

            # Получаем список всех таблиц
            tables = [row.table_name for row in cursor.tables(tableType='TABLE')]
            print(f"Начинаю поиск строки: '{target_value}'...")
            for table in tables:
                # Получаем только текстовые столбцы для ускорения поиска
                columns = [col.column_name for col in cursor.columns(table=table)
                           if col.type_name in ('VARCHAR', 'WVARCHAR', 'TEXT', 'LONGCHAR')]
                for col in columns:
                    try:
                        # Ищем точное совпадение (используем квадратные скобки для имен столбцов с пробелами)
                        #query = f"SELECT COUNT(*) FROM [{table}] WHERE [{col}] = ?"
                        # Используем LIKE и обрамляем значение знаками % для поиска подстроки
                        query = f"SELECT COUNT(*) FROM [{table}] WHERE [{col}] LIKE ?"
                        search_pattern = f"%{target_value}%"
                        #cursor.execute(query, target_value)
                        cursor.execute(query, search_pattern)
                        count = cursor.fetchone()[0]
                        if count > 0:
                            print(f"[НАЙДЕНО] БД: {chosen_mdb} | Таблица: {table} | Столбец: {col} | Совпадений: {count}")
                    except Exception as e:
                        continue  # Пропускаем ошибки доступа или специфических типов данных

    except Exception as e:
        print(f"Ошибка при открытии {filename}: {e}")

print("Поиск завершен.")
