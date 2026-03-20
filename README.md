# dingtalk-channel-setup

钉钉Channel配置技能 - 快速配置钉钉机器人与OpenClaw的集成

## 快速开始

### 方法一：使用配置脚本

```bash
# 下载脚本
git clone https://github.com/你的用户名/dingtalk-channel-setup.git
cd dingtalk-channel-setup

# 运行配置脚本
./scripts/configure.sh <clientId> <clientSecret>
```

### 方法二：手动配置

参考 [GUIDE.md](./GUIDE.md) 进行手动配置。

## 文件说明

| 文件 | 说明 |
|-----|------|
| `SKILL.md` | 技能定义文件 |
| `GUIDE.md` | 详细配置指导书 |
| `scripts/configure.sh` | 自动配置脚本 |

## 前置条件

1. 已安装OpenClaw
2. 已在钉钉开发者平台创建应用机器人
3. 已获取Client ID和Client Secret

## 钉钉开发者平台配置

1. 访问 https://open-dev.dingtalk.com/fe/app
2. 创建应用 → 添加机器人能力
3. **消息接收模式选择 Stream模式**
4. 获取 Client ID 和 Client Secret

## 验证配置

```bash
# 检查日志
tail -100 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep -i "DingTalk"

# 成功标志
# [gateway/channels/ddingtalk] [default] starting DingTalk provider
# DingTalk: configured
```

## 常见问题

详见 [GUIDE.md](./GUIDE.md) 第四部分。

## 相关链接

- [钉钉开发者平台](https://open-dev.dingtalk.com/)
- [OpenClaw文档](https://docs.openclaw.ai)

## License

MIT
