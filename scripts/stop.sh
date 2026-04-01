#!/bin/bash

# ed-station 一键停止脚本

echo "=========================================="
echo "  ed-station 停止脚本"
echo "=========================================="

# 停止后端服务
echo "[1/2] 停止后端服务..."
PID_18080=$(lsof -t -i :18080 2>/dev/null)
if [ ! -z "$PID_18080" ]; then
    kill $PID_18080
    echo "      后端服务已停止 (PID: $PID_18080)"
else
    echo "      后端服务未运行"
fi

# 停止前端服务
echo "[2/2] 停止前端服务..."
PID_3888=$(lsof -t -i :3888 2>/dev/null)
if [ ! -z "$PID_3888" ]; then
    kill $PID_3888
    echo "      前端服务已停止 (PID: $PID_3888)"
else
    echo "      前端服务未运行"
fi

echo ""
echo "服务已停止"
