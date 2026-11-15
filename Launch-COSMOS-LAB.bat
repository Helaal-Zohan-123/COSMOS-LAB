@echo off
setlocal
set "PORT=4173"
set "URL=http://127.0.0.1:%PORT%/"
set "DIST_DIR=%~dp0dist"
if "%DIST_DIR:~-1%"=="\" set "DIST_DIR=%DIST_DIR:~0,-1%"

if not exist "%DIST_DIR%\index.html" (
  echo [ERROR] Could not find "%DIST_DIR%\index.html".
  echo Please extract the entire ZIP archive before launching.
  pause
  exit /b 1
)

echo.
echo   COSMOS LAB - Jezero Evidence Explorer
echo   Serving: "%DIST_DIR%"
echo   URL:     %URL%
echo   Close this window to stop the local server.
echo.

python -c "import http.server" >nul 2>nul
if %errorlevel%==0 (
  start "" "%URL%"
  python -m http.server %PORT% --bind 127.0.0.1 --directory "%DIST_DIR%"
  goto :eof
)

py -3 -c "import http.server" >nul 2>nul
if %errorlevel%==0 (
  start "" "%URL%"
  py -3 -m http.server %PORT% --bind 127.0.0.1 --directory "%DIST_DIR%"
  goto :eof
)

where npx >nul 2>nul
if %errorlevel%==0 (
  start "" "%URL%"
  npx --yes serve -l tcp://127.0.0.1:%PORT% "%DIST_DIR%"
  goto :eof
)

set "COSMOS_DIST_DIR=%DIST_DIR%"
set "COSMOS_PORT=%PORT%"
start "" "%URL%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$root = [IO.Path]::GetFullPath($env:COSMOS_DIST_DIR); $port = $env:COSMOS_PORT; $mime = @{'.html'='text/html; charset=utf-8';'.js'='application/javascript; charset=utf-8';'.css'='text/css; charset=utf-8';'.json'='application/json; charset=utf-8';'.jpg'='image/jpeg';'.jpeg'='image/jpeg';'.png'='image/png';'.svg'='image/svg+xml';'.ico'='image/x-icon';'.woff2'='font/woff2';'.wasm'='application/wasm'}; $listener = New-Object System.Net.HttpListener; $listener.Prefixes.Add('http://127.0.0.1:' + $port + '/'); $listener.Start(); Write-Host ('PowerShell HttpListener active at http://127.0.0.1:' + $port + '/'); try { while ($listener.IsListening) { $ctx = $listener.GetContext(); $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/')); if ([string]::IsNullOrEmpty($rel)) { $rel = 'index.html' }; $candidate = [IO.Path]::GetFullPath((Join-Path $root ($rel -replace '/', '\'))); if (-not $candidate.StartsWith($root, [StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path $candidate -PathType Leaf)) { $candidate = Join-Path $root 'index.html' }; $ext = [IO.Path]::GetExtension($candidate).ToLowerInvariant(); $ctx.Response.ContentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }; $bytes = [IO.File]::ReadAllBytes($candidate); $ctx.Response.ContentLength64 = $bytes.Length; $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length); $ctx.Response.Close() } } finally { $listener.Stop() }"
