#!/bin/bash
# 本地开发服务器启动脚本 (Linux/Mac)
# 用于解决本地开发时的CORS问题

echo "🚀 启动超脑平台本地开发服务器..."
echo ""

# 检测Python是否可用
if command -v python3 &> /dev/null; then
    echo "✅ 检测到Python 3，使用Python HTTP服务器"
    echo "📍 访问地址: http://localhost:8000"
    echo "⚠️  按 Ctrl+C 停止服务器"
    echo ""
    python3 -m http.server 8000
elif command -v python &> /dev/null; then
    echo "✅ 检测到Python，使用Python HTTP服务器"
    echo "📍 访问地址: http://localhost:8000"
    echo "⚠️  按 Ctrl+C 停止服务器"
    echo ""
    python -m http.server 8000
elif command -v node &> /dev/null; then
    echo "✅ 检测到Node.js，尝试使用http-server"
    echo "📍 访问地址: http://localhost:8000"
    echo "⚠️  按 Ctrl+C 停止服务器"
    echo ""
    npx http-server -p 8000 -c-1
else
    echo "❌ 未检测到Python或Node.js"
    echo ""
    echo "请安装以下任一工具："
    echo "1. Python 3: https://www.python.org/downloads/"
    echo "2. Node.js: https://nodejs.org/"
    echo ""
    echo "或者手动运行："
    echo "  python3 -m http.server 8000"
    echo "  npx http-server -p 8000"
    echo ""
    exit 1
fi











