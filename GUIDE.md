# 钉钉Channel配置指导书

## 概述

本指导书帮助你将钉钉机器人与OpenClaw集成，实现通过钉钉与AI助手对话。

---

## 第一部分：钉钉开发者平台配置

### 1.1 创建应用

1. 访问 [钉钉开发者平台](https://open-dev.dingtalk.com/fe/app)
2. 点击 **"创建应用"**
3. 填写应用信息：
   - 应用名称：自定义（如"AI助手"）
   - 应用描述：自定义
   - 应用Logo：上传图标

### 1.2 添加机器人能力

1. 进入应用详情页
2. 点击 **"机器人与消息推送"**
3. 开启 **"机器人能力"**
4. 配置机器人信息：
   - 机器人名称：自定义
   - 机器人图标：上传图标
   - 机器人简介：描述功能

### 1.3 配置消息接收模式

**重要：选择 Stream 模式**

1. 在 **"消息接收模式"** 中选择 **"Stream模式"**
2. 不要选择 Webhook 模式（需要公网IP）
3. Stream模式支持内网环境，无需配置服务器

### 1.4 获取凭证

1. 在应用详情页找到 **"凭证信息"**
2. 记录以下信息：
   - **Client ID**（格式如 `dingxxxx`）
   - **Client Secret**

---

## 第二部分：OpenClaw配置

### 2.1 安装插件

在OpenClaw运行服务器上执行：

```bash
# 创建插件目录
mkdir -p ~/.openclaw/extensions/ddingtalk

# 进入目录
cd ~/.openclaw/extensions/ddingtalk

# 初始化npm
npm init -y

# 安装钉钉插件
npm install @largezhou/ddingtalk@latest
```

### 2.2 配置 openclaw.json

编辑 `~/.openclaw/openclaw.json` 文件：

#### 2.2.1 添加 channels 配置

```json
"channels": {
  "ddingtalk": {
    "clientId": "你的Client ID",
    "clientSecret": "你的Client Secret",
    "enabled": true
  }
}
```

#### 2.2.2 添加 entries 配置

```json
"entries": {
  "ddingtalk": {
    "enabled": true
  }
}
```

#### 2.2.3 添加 installs 配置

```json
"installs": {
  "ddingtalk": {
    "source": "npm",
    "spec": "@largezhou/ddingtalk@latest",
    "installPath": "/home/sandbox/.openclaw/extensions/ddingtalk/node_modules/@largezhou/ddingtalk",
    "version": "1.4.1",
    "installedAt": "2026-03-20T08:15:00.000Z"
  }
}
```

#### 2.2.4 添加 plugins 配置

```json
"plugins": {
  "allow": ["feishu", "ddingtalk", "xiaoyi-channel"],
  "load": {
    "paths": [
      "/home/sandbox/openclaw/node_modules/openclaw/extensions/feishu",
      "/home/sandbox/.openclaw/extensions/ddingtalk/node_modules/@largezhou/ddingtalk"
    ]
  }
}
```

### 2.3 重启Gateway

```bash
# 停止gateway
openclaw gateway stop

# 启动gateway
openclaw gateway
```

---

## 第三部分：验证配置

### 3.1 检查日志

```bash
# 查看最新日志
tail -100 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep -i "DingTalk"
```

**成功标志**：
```
[gateway/channels/ddingtalk] [default] starting DingTalk provider
DingTalk: configured
```

### 3.2 测试消息

1. 打开钉钉App
2. 找到你的机器人
3. 发送测试消息
4. 检查是否收到回复

---

## 第四部分：常见问题排查

### 4.1 unknown channel id: ddingtalk

**原因**：插件未正确加载

**解决方案**：
1. 检查 `plugins.load.paths` 是否包含插件路径
2. 确认插件安装成功：`ls ~/.openclaw/extensions/ddingtalk/node_modules/@largezhou/ddingtalk/`
3. 重启gateway

### 4.2 DingTalk: not configured

**原因**：缺少凭证配置

**解决方案**：
1. 检查 `channels.ddingtalk.clientId` 是否正确
2. 检查 `channels.ddingtalk.clientSecret` 是否正确
3. 重启gateway

### 4.3 机器人不回复

**原因**：Stream模式连接问题

**解决方案**：
1. 确认钉钉开发者平台配置了Stream模式
2. 检查网络连接
3. 查看gateway日志：`tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log`

### 4.4 npm install 失败

**解决方案**：
```bash
# 使用国内镜像
npm install @largezhou/ddingtalk --registry=https://registry.npmmirror.com
```

---

## 第五部分：配置文件完整示例

```json
{
  "channels": {
    "xiaoyi-channel": {
      "enabled": true
    },
    "feishu": {
      "enabled": true
    },
    "ddingtalk": {
      "clientId": "dinglboaxapeimcs1s7t",
      "clientSecret": "ETPw9TzFvgVCB0Hs322tvEhWp2kZpkeRVwujCzILfLHnTXGVWnc1DeRG1NxWbqdI",
      "enabled": true
    }
  },
  "entries": {
    "xiaoyi-channel": {
      "enabled": true
    },
    "feishu": {
      "enabled": true
    },
    "ddingtalk": {
      "enabled": true
    }
  },
  "installs": {
    "ddingtalk": {
      "source": "npm",
      "spec": "@largezhou/ddingtalk@latest",
      "installPath": "/home/sandbox/.openclaw/extensions/ddingtalk/node_modules/@largezhou/ddingtalk",
      "version": "1.4.1"
    }
  },
  "plugins": {
    "allow": ["feishu", "ddingtalk", "xiaoyi-channel"],
    "load": {
      "paths": [
        "/home/sandbox/openclaw/node_modules/openclaw/extensions/feishu",
        "/home/sandbox/.openclaw/extensions/ddingtalk/node_modules/@largezhou/ddingtalk"
      ]
    }
  }
}
```

---

## 附录

### A. 插件信息

| 项目 | 值 |
|-----|-----|
| 包名 | `@largezhou/ddingtalk` |
| 版本 | 1.4.1 |
| Channel ID | `ddingtalk` |
| 支持功能 | Stream模式、私聊/群聊、图片/文件消息 |

### B. 相关链接

- [钉钉开发者平台](https://open-dev.dingtalk.com/)
- [钉钉机器人文档](https://open.dingtalk.com/document/org/robot-overview)
- [OpenClaw文档](https://docs.openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)

### C. 更新日志

| 日期 | 版本 | 说明 |
|-----|------|------|
| 2026-03-20 | 1.0.0 | 初始版本 |

---

**文档作者**: 小艺Claw  
**创建日期**: 2026年3月20日
