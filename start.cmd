@echo off
cd /d "%~dp0"
if not exist ".venv\Scripts\python.exe" (
  echo Please follow README.md to install dependencies first.
  pause
  exit /b 1
)
echo Open http://127.0.0.1:8000 in your browser.
echo Press Ctrl+C to stop.
".venv\Scripts\python.exe" -m uvicorn app:app --app-dir backend --host 127.0.0.1 --port 8000
pause
