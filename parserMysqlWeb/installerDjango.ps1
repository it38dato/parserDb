# Установка кодировки UTF-8 для корректного отображения логов
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$LogFile = Join-Path $PSScriptRoot "installationLog.log"

function Write-Log ($Message, $Level = "INFO") {
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogLine = "[$Timestamp] [$Level] $Message"
    Write-Host $LogLine
    Add-Content -Path $LogFile -Value $LogLine
}

Write-Log "Запуск процесса установки Django сервера с поддержкой прокси..."

# 1. Чтение config.json
if (-not (Test-Path "config.json")) {
    Write-Log "Файл config.json не найден!" "ERROR"
    Exit
}
$Config = Get-Content "config.json" -Raw | ConvertFrom-Json

# 2. Чтение .env
if (-not (Test-Path ".env")) {
    Write-Log "Файл .env не найден!" "ERROR"
    Exit
}
$EnvParams = @{}
Get-Content ".env" | Where-Object { $_ -match '=' -and $_ -notmatch '^#' } | ForEach-Object {
    $Name, $Value = $_ -split '=', 2
    $EnvParams[$Name.Trim()] = $Value.Trim()
}

# 3. Формирование параметров ПРОКСИ для pip
$ProxyArgs = ""
if ($Config.use_proxy -eq $true) {
    $ProxyServer = $EnvParams["PROXY_SERVER"]
    if (-not [string]::IsNullOrEmpty($ProxyServer)) {
        $ProxyArgs = "--proxy http://$ProxyServer"
        Write-Log "Используется прокси-сервер для установки библиотек: http://$ProxyServer"
    } else {
        Write-Log "В config.json включен прокси, но в .env параметр PROXY_SERVER пуст!" "WARNING"
    }
}

# 4. Определение путей базы и проекта
$ProjectName = $Config.project_name
if ([string]::IsNullOrEmpty($Config.project_path)) {
    $TargetDir = Join-Path $Home $ProjectName
} else {
    $TargetDir = Join-Path $Config.project_path $ProjectName
}

Write-Log "Целевой каталог проекта: $TargetDir"

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
    Write-Log "Папка проекта успешно создана."
}

# 5. Создание виртуального окружения рядом с проектом (с приставкой env)
$VenvName = "env$ProjectName"
$VenvPath = Join-Path (Split-Path $TargetDir) $VenvName
Write-Log "Создание виртуального окружения в: $VenvPath"

try {
    python -m venv $VenvPath
    Write-Log "Виртуальное окружение успешно создано."
} catch {
    Write-Log "Не удалось создать виртуальное окружение. Проверьте установку Python." "ERROR"
    Exit
}

$VenvPython = Join-Path $VenvPath "Scripts\python.exe"
$VenvPip = Join-Path $VenvPath "Scripts\pip.exe"

# 6. Обновление pip и установка библиотек с учетом прокси
Write-Log "Обновление pip..."
$PipUpdateArgs = if ($ProxyArgs) { "-m pip install --upgrade pip $ProxyArgs" } else { "-m pip install --upgrade pip" }
Start-Process -FilePath $VenvPython -ArgumentList $PipUpdateArgs -NoNewWindow -Wait

Write-Log "Установка необходимых библиотек..."
foreach ($Lib in $Config.libraries) {
    Write-Log "Установка: $Lib"
    
    # Собираем аргументы: install библиотека [--proxy http://...]
    $InstallArgs = if ($ProxyArgs) { "install $Lib $ProxyArgs" } else { "install $Lib" }
    
    $Process = Start-Process -FilePath $VenvPip -ArgumentList $InstallArgs -NoNewWindow -Wait -PassThru
    if ($Process.ExitCode -ne 0) {
        Write-Log "Ошибка при установке библиотеки: $Lib" "WARNING"
    }
}

# Переходим в папку назначения для развертывания Django
Push-Location $TargetDir

# 7. Инициализация Django проекта
$ManagePy = Join-Path $TargetDir "manage.py"
if (-not (Test-Path $ManagePy)) {
    Write-Log "Инициализация нового Django проекта с именем $ProjectName..."
    Start-Process -FilePath $VenvPython -ArgumentList "-m django startproject $ProjectName ." -NoNewWindow -Wait
} else {
    Write-Log "Проект Django уже инициализирован в этой папке."
}

# Копируем файл .env внутрь папки проекта для будущего использования сервером
Copy-Item (Join-Path $PSScriptRoot ".env") (Join-Path $TargetDir ".env") -Force

# 8. Применение базовых миграций
Write-Log "Применение начальных миграций Django..."
Start-Process -FilePath $VenvPython -ArgumentList "manage.py migrate" -NoNewWindow -Wait

# 9. Создание Суперпользователя (Администратора) из параметров .env
Write-Log "Создание учетной записи администратора..."
$Env:DJANGO_SUPERUSER_USERNAME = $EnvParams["DJANGO_SUPERUSER_USERNAME"]
$Env:DJANGO_SUPERUSER_PASSWORD = $EnvParams["DJANGO_SUPERUSER_PASSWORD"]
$Env:DJANGO_SUPERUSER_EMAIL = $EnvParams["DJANGO_SUPERUSER_EMAIL"]

Start-Process -FilePath $VenvPython -ArgumentList "manage.py createsuperuser --noinput" -NoNewWindow -Wait

$Env:DJANGO_SUPERUSER_USERNAME = $null
$Env:DJANGO_SUPERUSER_PASSWORD = $null
$Env:DJANGO_SUPERUSER_EMAIL = $null

Pop-Location

Write-Log "Установка успешно завершена! Проект готов к работе."
