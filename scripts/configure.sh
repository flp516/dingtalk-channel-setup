#!/bin/bash
# 钉钉Channel配置脚本
# 用法: ./configure.sh <clientId> <clientSecret>

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查参数
if [ $# -lt 2 ]; then
    echo -e "${RED}错误: 缺少参数${NC}"
    echo "用法: $0 <clientId> <clientSecret>"
    echo "示例: $0 dinglboaxapeimcs1s7t ETPw9TzFvgVCB0Hs..."
    exit 1
fi

CLIENT_ID=$1
CLIENT_SECRET=$2

echo -e "${GREEN}=== 钉钉Channel配置脚本 ===${NC}"
echo ""

# 1. 创建插件目录
echo -e "${YELLOW}[1/5] 创建插件目录...${NC}"
mkdir -p ~/.openclaw/extensions/ddingtalk
cd ~/.openclaw/extensions/ddingtalk

# 2. 初始化npm
echo -e "${YELLOW}[2/5] 初始化npm...${NC}"
if [ ! -f "package.json" ]; then
    npm init -y > /dev/null 2>&1
fi

# 3. 安装插件
echo -e "${YELLOW}[3/5] 安装钉钉插件...${NC}"
npm install @largezhou/ddingtalk@latest --registry=https://registry.npmmirror.com > /dev/null 2>&1

# 检查安装结果
if [ ! -d "node_modules/@largezhou/ddingtalk" ]; then
    echo -e "${RED}错误: 插件安装失败${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 插件安装成功${NC}"

# 4. 配置openclaw.json
echo -e "${YELLOW}[4/5] 配置openclaw.json...${NC}"
OPENCLAW_CONFIG=~/.openclaw/openclaw.json

if [ ! -f "$OPENCLAW_CONFIG" ]; then
    echo -e "${RED}错误: openclaw.json 不存在${NC}"
    exit 1
fi

# 备份原配置
cp "$OPENCLAW_CONFIG" "${OPENCLAW_CONFIG}.bak"

# 使用node更新配置
node -e "
const fs = require('fs');
const config = JSON.parse(fs.readFileSync('$OPENCLAW_CONFIG', 'utf8'));

// 添加channels配置
if (!config.channels) config.channels = {};
config.channels.ddingtalk = {
    clientId: '$CLIENT_ID',
    clientSecret: '$CLIENT_SECRET',
    enabled: true
};

// 添加entries配置
if (!config.entries) config.entries = {};
config.entries.ddingtalk = { enabled: true };

// 添加installs配置
if (!config.installs) config.installs = {};
config.installs.ddingtalk = {
    source: 'npm',
    spec: '@largezhou/ddingtalk@latest',
    installPath: process.env.HOME + '/.openclaw/extensions/ddingtalk/node_modules/@largezhou/ddingtalk',
    version: '1.4.1',
    installedAt: new Date().toISOString()
};

// 添加plugins配置
if (!config.plugins) config.plugins = {};
if (!config.plugins.allow) config.plugins.allow = [];
if (!config.plugins.allow.includes('ddingtalk')) {
    config.plugins.allow.push('ddingtalk');
}
if (!config.plugins.load) config.plugins.load = { paths: [] };
const pluginPath = process.env.HOME + '/.openclaw/extensions/ddingtalk/node_modules/@largezhou/ddingtalk';
if (!config.plugins.load.paths.includes(pluginPath)) {
    config.plugins.load.paths.push(pluginPath);
}

fs.writeFileSync('$OPENCLAW_CONFIG', JSON.stringify(config, null, 2));
console.log('✓ 配置文件更新成功');
"

# 5. 重启gateway
echo -e "${YELLOW}[5/5] 重启gateway...${NC}"
openclaw gateway stop > /dev/null 2>&1 || true
sleep 2
openclaw gateway > /dev/null 2>&1 &
sleep 5

# 验证配置
echo ""
echo -e "${YELLOW}验证配置...${NC}"
LOG_FILE="/tmp/openclaw/openclaw-$(date +%Y-%m-%d).log"
if [ -f "$LOG_FILE" ]; then
    if grep -q "DingTalk: configured" "$LOG_FILE" 2>/dev/null; then
        echo -e "${GREEN}✓ 钉钉Channel配置成功！${NC}"
    else
        echo -e "${YELLOW}⚠ 配置可能未生效，请检查日志${NC}"
    fi
fi

echo ""
echo -e "${GREEN}=== 配置完成 ===${NC}"
echo ""
echo "下一步："
echo "1. 打开钉钉App"
echo "2. 找到你的机器人"
echo "3. 发送消息测试"
echo ""
echo "查看日志: tail -f $LOG_FILE | grep -i DingTalk"
