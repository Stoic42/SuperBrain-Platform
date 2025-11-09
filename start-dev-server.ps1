# 本地开发服务器启动脚本 (Windows PowerShell)
# 用于解决本地开发时的CORS问题

Write-Host "🚀 启动超脑平台本地开发服务器..." -ForegroundColor Cyan
Write-Host ""

# 检测Python是否可用
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if ($pythonCmd) {
    Write-Host "✅ 检测到Python，使用Python HTTP服务器" -ForegroundColor Green
    Write-Host "📍 访问地址: http://localhost:8000" -ForegroundColor Yellow
    Write-Host "⚠️  按 Ctrl+C 停止服务器" -ForegroundColor Yellow
    Write-Host ""
    python -m http.server 8000
} else {
    # 检测Node.js是否可用
    $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
    if ($nodeCmd) {
        Write-Host "✅ 检测到Node.js，尝试使用http-server" -ForegroundColor Green
        Write-Host "📍 访问地址: http://localhost:8000" -ForegroundColor Yellow
        Write-Host "⚠️  按 Ctrl+C 停止服务器" -ForegroundColor Yellow
        Write-Host ""
        npx http-server -p 8000 -c-1
    } else {
        Write-Host "❌ 未检测到Python或Node.js" -ForegroundColor Red
        Write-Host ""
        Write-Host "请安装以下任一工具：" -ForegroundColor Yellow
        Write-Host "1. Python 3: https://www.python.org/downloads/" -ForegroundColor White
        Write-Host "2. Node.js: https://nodejs.org/" -ForegroundColor White
        Write-Host ""
        Write-Host "或者手动运行：" -ForegroundColor Yellow
        Write-Host "  python -m http.server 8000" -ForegroundColor Cyan
        Write-Host "  npx http-server -p 8000" -ForegroundColor Cyan
        Write-Host ""
        pause
        exit 1
    }
}











