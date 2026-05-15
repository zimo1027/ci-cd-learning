#!/bin/bash

# Deployment Script
# 部署脚本 - 从开发目录部署到独立的部署目录

echo "🚀 Starting deployment..."

# 设置目录路径
PROJECT_DIR="/home/zimo1027/projects/ci-cd-learning"
DEPLOY_DIR="/home/zimo1027/deploy/ci-cd-learning"

echo "📁 Project directory: $PROJECT_DIR"
echo "🚀 Deploy directory: $DEPLOY_DIR"

# 创建部署目录（如果不存在）
mkdir -p $DEPLOY_DIR

# 复制应用文件到部署目录
echo "📁 Copying application files..."
cp $PROJECT_DIR/app.py $DEPLOY_DIR/
cp $PROJECT_DIR/requirements.txt $DEPLOY_DIR/

# 创建虚拟环境（如果不存在）
if [ ! -d "$DEPLOY_DIR/venv" ]; then
    echo "🐍 Creating virtual environment..."
    python3 -m venv $DEPLOY_DIR/venv
fi

# 激活虚拟环境并安装依赖
echo "📦 Installing dependencies..."
source $DEPLOY_DIR/venv/bin/activate
pip install -r $DEPLOY_DIR/requirements.txt --quiet

# 停止旧的应用实例
echo "🛑 Stopping old application instance..."
pkill -f "python.*app.py" || true
fuser -k 5000/tcp 2>/dev/null || true
sleep 2

# 启动新的应用实例（后台运行）
echo "🎯 Starting application..."
cd $DEPLOY_DIR

# 启动新实例
nohup python app.py > app.log 2>&1 &
APP_PID=$!

echo "📝 Application PID: $APP_PID"
echo "📝 Log file: $DEPLOY_DIR/app.log"

# 等待应用启动
sleep 3

# 检查应用是否运行
if ps -p $APP_PID > /dev/null; then
    echo "✅ Deployment completed successfully!"
    echo "📊 Application is running at: http://localhost:5000"
    echo "📁 Deployment directory: $DEPLOY_DIR"
    echo "📝 Logs: $DEPLOY_DIR/app.log"
    echo "🔍 Process ID: $APP_PID"
else
    echo "❌ Deployment failed - application not running"
    echo "📝 Check logs: $DEPLOY_DIR/app.log"
    if [ -f "$DEPLOY_DIR/app.log" ]; then
        cat $DEPLOY_DIR/app.log
    fi
    exit 1
fi

