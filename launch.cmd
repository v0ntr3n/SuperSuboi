@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem Run from this file's directory even when double-clicked from elsewhere.
pushd "%~dp0"
if errorlevel 1 (
    echo [ERROR] Cannot open the SuperSuboi project directory.
    exit /b 1
)
set "VENV_DIR=%CD%\.venv"
set "VENV_PY=%VENV_DIR%\Scripts\python.exe"
set "READY_FILE=%VENV_DIR%\.supersuboi-ready"

if /I "%~1"=="--help" goto help
if /I "%~1"=="--setup-only" (
    set "SETUP_ONLY=1"
    goto setup
)
if /I "%~1"=="--setup" goto setup
if /I "%~1"=="--skip" goto skip
if /I "%~1"=="--check" goto check
if not "%~1"=="" goto unknown_option

echo.
echo ========================================
echo   SuperSuboi - Zapret Windows Launcher
echo ========================================
echo.

rem No prompts: use the prepared environment, otherwise set it up automatically.
if exist "%VENV_PY%" if exist "%READY_FILE%" goto use_venv
echo [INFO] First run: setting up the local Python environment automatically.
goto setup

:setup
echo.
echo [INFO] Preparing Python environment...
if not exist "requirements.txt" (
    echo [ERROR] requirements.txt is missing.
    goto failed
)
if exist "%VENV_PY%" goto install_deps
call :find_python
if errorlevel 1 goto no_python
echo [INFO] Creating .venv...
%BOOT_PY% -m venv "%VENV_DIR%"
if errorlevel 1 (
    echo [ERROR] Could not create the virtual environment.
    goto failed
)

:install_deps
"%VENV_PY%" -c "import sys; print('Python', sys.version.split()[0])"
if errorlevel 1 (
    echo [ERROR] The local .venv is broken. Delete .venv and retry.
    goto failed
)
if exist "%READY_FILE%" del /Q "%READY_FILE%" >nul 2>&1
echo [INFO] Installing dependencies from requirements.txt...
"%VENV_PY%" -m pip install --disable-pip-version-check -r "requirements.txt"
if errorlevel 1 (
    echo [ERROR] Dependency installation failed. Fix the error and double-click launch.cmd again.
    goto failed
)
>"%READY_FILE%" echo Installed requirements.txt successfully.
set "RUN_ENV=venv"
if defined SETUP_ONLY goto setup_only_done
goto launch

:setup_only_done
call :prepare_config
if errorlevel 1 goto failed
echo [OK] Environment and local configuration are ready.
goto done

:skip
echo [INFO] Skipping dependency installation.
if exist "%VENV_PY%" goto use_venv
call :find_python
if errorlevel 1 goto no_python
set "RUN_ENV=system"
goto launch

:use_venv
set "RUN_ENV=venv"
goto launch

:check
if exist "%VENV_PY%" (
    echo [INFO] Checking the local .venv...
    "%VENV_PY%" -c "import PySide6, qasync, dotenv, win32api, requests; print('Required Python imports: OK')"
    if errorlevel 1 goto check_failed
    goto done
)
call :find_python
if errorlevel 1 goto no_python
echo [INFO] Checking the installed system Python...
%BOOT_PY% -c "import PySide6, qasync, dotenv, win32api, requests; print('Required Python imports: OK')"
if errorlevel 1 goto check_failed
goto done

:launch
call :prepare_config
if errorlevel 1 goto failed

rem Used only by automated Windows CI to exercise double-click/no-args flow
rem without starting an interactive Qt window.
if /I "%SUPERSUBOI_CI_SKIP_GUI%"=="1" (
    echo [OK] Automatic launcher setup and config checks passed.
    goto done
)

echo.
echo [INFO] Starting SuperSuboi (Zapret)...
echo [INFO] Windows may ask for administrator permission for the packet driver.
echo.
if /I "%RUN_ENV%"=="venv" goto run_venv
%BOOT_PY% "run.py"
goto after_run

:run_venv
"%VENV_PY%" "run.py"

:after_run
set "APP_EXIT=%ERRORLEVEL%"
if not "%APP_EXIT%"=="0" (
    echo.
    echo [ERROR] run.py exited with code %APP_EXIT%.
    echo Double-click launch.cmd again to retry installation if necessary.
    pause
)
popd
exit /b %APP_EXIT%

:prepare_config
rem run.py otherwise prompts for an optional token and exits on its first run.
rem Only create missing files; never replace user configuration or credentials.
if not exist ".env" (
    >".env" echo DEV_API=
    if errorlevel 1 exit /b 1
    echo [INFO] Created .env with an empty, optional GitHub token.
)
if not exist "config.properties" (
    >"config.properties" (
        echo [application]
        echo appId=com.supersuboi.zapret
        echo appName=SuperSuboi
        echo company=SuperSuboi
        echo copyright=Copyright 2026
        echo domain=com.supersuboi.zapret
        echo version=1.2.14
        echo [build]
        echo projectName=GoodbyeDPI_UI
        echo hotLoad=OFF
        echo excludeFiles=
    )
    if errorlevel 1 exit /b 1
    echo [INFO] Created config.properties with runnable defaults.
)
exit /b 0

:find_python
set "BOOT_PY="
py -3.12 -c "import sys; assert sys.version_info >= (3, 10)" >nul 2>&1
if not errorlevel 1 (
    set "BOOT_PY=py -3.12"
    exit /b 0
)
py -3 -c "import sys; assert sys.version_info >= (3, 10)" >nul 2>&1
if not errorlevel 1 (
    set "BOOT_PY=py -3"
    exit /b 0
)
python -c "import sys; assert sys.version_info >= (3, 10)" >nul 2>&1
if not errorlevel 1 (
    set "BOOT_PY=python"
    exit /b 0
)
exit /b 1

:no_python
echo.
echo [ERROR] Python 3.10 or newer was not found.
echo Install Python 3.12 from https://www.python.org/downloads/windows/
echo Select "Add python.exe to PATH" during installation, then rerun launch.cmd.
goto failed

:check_failed
echo [ERROR] Dependencies are missing or broken. Double-click launch.cmd to set up.
goto failed

:unknown_option
echo [ERROR] Unknown option: %~1
:help
echo.
echo Usage:
echo   launch.cmd              Automatically set up .venv if needed, then run app
echo   launch.cmd --setup      Create/repair .venv, install packages, run app
echo   launch.cmd --skip       Skip installation and run with existing Python
echo   launch.cmd --setup-only Prepare environment without opening the app
echo   launch.cmd --check      Verify installed Python dependencies
echo   launch.cmd --help       Show this help
goto done

:failed
if not defined SETUP_ONLY pause
popd
exit /b 1

:done
popd
exit /b 0
