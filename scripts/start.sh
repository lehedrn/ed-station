#!/bin/bash

# ed-station 一键启动脚本
# 功能：检查并清理端口占用，然后启动前后端服务

LOG_DIR="/home/workspace/com/ed-station/logs"
PROJECT_ROOT="/home/workspace/com/ed-station"

# 创建日志目录
mkdir -p $LOG_DIR

echo "=========================================="
echo "  ed-station 启动脚本"
echo "=========================================="

# 1. 检查并清理端口占用
echo "[1/4] 检查端口占用情况..."

PID_3888=$(lsof -t -i :3888 2>/dev/null)
PID_18080=$(lsof -t -i :18080 2>/dev/null)

if [ ! -z "$PID_3888" ]; then
    echo "      发现占用 3888 端口的进程 (PID: $PID_3888)，正在终止..."
    kill $PID_3888
    sleep 1
fi

if [ ! -z "$PID_18080" ]; then
    echo "      发现占用 18080 端口的进程 (PID: $PID_18080)，正在终止..."
    kill $PID_18080
    sleep 1
fi

# 等待端口释放
sleep 2

# 2. 确认端口已释放
echo "[2/4] 确认端口已释放..."
if lsof -i :3888 2>/dev/null | grep -q LISTEN; then
    echo "      警告：3888 端口仍未释放！"
    exit 1
fi
if lsof -i :18080 2>/dev/null | grep -q LISTEN; then
    echo "      警告：18080 端口仍未释放！"
    exit 1
fi
echo "      端口已释放，准备启动服务..."

# 3. 启动后端服务
echo "[3/4] 启动后端服务 (端口 18080)..."
cd $PROJECT_ROOT/ed-station-boot
nohup mvn spring-boot:run -Dspring-boot.run.profiles=dev > $LOG_DIR/backend.log 2>&1 &
BACKEND_PID=$!
echo "      后端进程已启动 (PID: $BACKEND_PID)"

# 4. 启动前端服务
echo "[4/4] 启动前端服务 (端口 3888)..."
cd $PROJECT_ROOT/ed-station-web
nohup pnpm dev > $LOG_DIR/frontend.log 2>&1 &
FRONTEND_PID=$!
echo "      前端进程已启动 (PID: $FRONTEND_PID)"

# 等待服务启动
echo ""
echo "等待服务启动..."
sleep 10

# 检查服务状态
echo ""
echo "=========================================="
echo "  服务启动状态检查"
echo "=========================================="

if lsof -i :18080 2>/dev/null | grep -q LISTEN; then
    echo "  [✓] 后端服务运行中 (端口 18080)"
else
    echo "  [✗] 后端服务启动失败"
fi

if lsof -i :3888 2>/dev/null | grep -q LISTEN; then
    echo "  [✓] 前端服务运行中 (端口 3888)"
else
    echo "  [✗] 前端服务启动失败"
fi

echo ""
echo "=========================================="
echo "  访问地址"
echo "=========================================="
echo "  前端：http://localhost:3888/"
echo "  后端：http://localhost:18080/"
echo "  接口文档：http://localhost:18080/doc.html"
echo ""
echo "  日志目录：$LOG_DIR"
echo "  查看后端日志：tail -f $LOG_DIR/backend.log"
echo "  查看前端日志：tail -f $LOG_DIR/frontend.log"
echo ""
