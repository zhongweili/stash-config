# Stash 网站访问问题排查指南

本目录包含了一套完整的 Stash 网站访问问题排查工具，帮助你快速定位和解决访问问题。

## 🛠️ 工具列表

### 1. 综合排查工具 - `website-troubleshoot.sh`

**用途**: 全面排查特定网站的访问问题

**使用方法**:

```bash
./scripts/website-troubleshoot.sh google.com
./scripts/website-troubleshoot.sh https://github.com
```

**功能**:

- ✅ 检查 Stash 服务状态
- ✅ 测试基础网络连通性
- ✅ DNS 解析测试
- ✅ 代理访问测试
- ✅ 规则匹配检查
- ✅ 代理节点健康检查
- ✅ 访问速度测试
- ✅ 问题诊断和建议

### 2. 规则匹配检查 - `check-rules.sh`

**用途**: 专门检查域名的规则匹配情况

**使用方法**:

```bash
./scripts/check-rules.sh google.com
./scripts/check-rules.sh baidu.com
```

**功能**:

- ✅ 检查域名规则匹配
- ✅ 获取实际规则匹配信息
- ✅ IP 地理位置检查
- ✅ 规则优化建议

### 3. 实时性能监控 - `monitor-performance.sh`

**用途**: 实时监控 Stash 的性能状态

**使用方法**:

```bash
./scripts/monitor-performance.sh
```

**功能**:

- 📊 进程资源使用情况
- 📊 网络连接统计
- 📊 代理节点状态
- 📊 DNS 解析性能
- 📊 网络延迟测试
- 📊 错误统计

### 4. 快速修复工具 - `quick-fix.sh`

**用途**: 快速修复常见的配置和网络问题

**使用方法**:

```bash
./scripts/quick-fix.sh
```

**功能**:

- 🔧 重载配置文件
- 🔧 清理所有连接
- 🔧 重置 DNS 缓存
- 🔧 刷新代理节点
- 🔧 重启代理服务
- 🔧 修复系统 DNS 设置
- 🔧 修复权限问题
- 🔧 检查端口占用

## 📋 标准排查流程

当遇到网站无法访问或访问速度慢的问题时，建议按以下顺序进行排查：

### Step 1: 基础检查

```bash
# 1. 检查特定网站问题
./scripts/website-troubleshoot.sh <问题网站>

# 2. 检查规则匹配
./scripts/check-rules.sh <问题域名>
```

### Step 2: 性能监控

```bash
# 实时监控系统状态
./scripts/monitor-performance.sh
```

### Step 3: 快速修复

```bash
# 尝试快速修复
./scripts/quick-fix.sh
# 选择选项 9) 批量修复（推荐）
```

### Step 4: 重新测试

```bash
# 修复后重新测试
./scripts/website-troubleshoot.sh <问题网站>
```

## 🔍 常见问题诊断

### 问题 1: 直连和代理都无法访问

**可能原因**:

- 网络连接问题
- 防火墙阻止
- DNS 解析失败

**解决方案**:

1. 检查网络连接
2. 运行快速修复工具
3. 重置 DNS 缓存

### 问题 2: 直连正常但代理失败

**可能原因**:

- Stash 配置错误
- 代理节点不可用
- 规则配置问题

**解决方案**:

1. 检查配置文件语法
2. 刷新代理节点
3. 检查规则匹配

### 问题 3: 代理正常但直连失败

**说明**: 这通常是正常的，表示该网站需要通过代理访问

### 问题 4: 访问速度慢

**可能原因**:

- 代理节点响应慢
- DNS 解析慢
- 网络拥塞

**解决方案**:

1. 更换代理节点
2. 优化 DNS 配置
3. 检查网络延迟

## 🎯 针对性排查

### DNS 问题排查

```bash
# 检查 DNS 解析
nslookup <域名>
dig <域名> @8.8.8.8

# 重置 DNS 缓存
./scripts/quick-fix.sh
# 选择选项 3) 重置DNS缓存
```

### 代理节点问题排查

```bash
# 检查代理节点状态
curl -s "http://127.0.0.1:9090/proxies" | jq

# 刷新代理节点
./scripts/quick-fix.sh
# 选择选项 4) 刷新代理节点
```

### 规则配置问题排查

```bash
# 检查规则匹配
./scripts/check-rules.sh <域名>

# 重载配置
./scripts/quick-fix.sh
# 选择选项 1) 重载配置文件
```

## 📝 日志分析

### 查看实时日志

```bash
curl -s 'http://127.0.0.1:9090/logs?level=info'
```

### 查看连接信息

```bash
curl -s "http://127.0.0.1:9090/connections" | jq
```

### 查看代理状态

```bash
curl -s "http://127.0.0.1:9090/proxies" | jq
```

## ⚡ 快速命令参考

```bash
# 重载配置
curl -X PUT 'http://127.0.0.1:9090/configs?force=true'

# 清理连接
curl -X DELETE 'http://127.0.0.1:9090/connections'

# 测试代理
curl -I --proxy http://127.0.0.1:7890 https://google.com

# 测试直连
curl -I https://baidu.com

# 检查端口
lsof -i :7890
```

## 🔧 高级排查

### 网络抓包分析

```bash
# 使用 tcpdump 抓包（需要 sudo）
sudo tcpdump -i any -w /tmp/stash.pcap port 7890

# 使用 Wireshark 分析抓包文件
```

### 系统级网络检查

```bash
# 检查路由表
netstat -rn

# 检查网络接口
ifconfig

# 检查系统代理设置
networksetup -getwebproxy "Wi-Fi"
```

## 📞 获取帮助

如果使用工具后仍然无法解决问题，请：

1. 运行完整排查: `./scripts/website-troubleshoot.sh <问题网站>`
2. 保存输出结果
3. 检查 Stash 应用日志
4. 提供具体的错误信息和配置文件

---

**提示**: 所有工具都支持彩色输出，便于快速识别问题状态：

- 🟢 绿色：正常/成功
- 🟡 黄色：警告/需要注意
- 🔴 红色：错误/失败
- 🔵 蓝色：信息/步骤
