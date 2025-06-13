# Cloudflare 访问优化解决方案

## 问题描述

在使用 Stash 配置时发现 Cloudflare 相关域名访问速度较慢，影响代理规则的更新和使用体验。

## 优化措施

### 1. 创建专门的 Cloudflare 代理组

- 新增 `Cloudflare` 代理组
- 优先使用美国、新加坡、香港等地区节点
- 包含 WARP+ 节点作为备选

### 2. 完善的规则集

创建了专门的 Cloudflare 规则文件 `rules/Cloudflare.yaml`，包含：

- Cloudflare 主要服务域名
- Workers 和 Pages 平台
- CDN 相关域名
- 开发者和管理界面
- 安全服务和存储服务

### 3. DNS 优化

在 `fake-ip-filter` 中添加了更多 Cloudflare 域名，防止 IP 污染：

- `*.pages.dev`
- `*.imagedelivery.net`
- `*.videodelivery.net`
- `cdnjs.cloudflare.com`
- `ajax.cloudflare.com`

### 4. 测试工具

提供了 `scripts/test_cloudflare_speed.sh` 脚本用于测试访问速度。

## 使用方法

### 1. 测试当前访问速度

```bash
./scripts/test_cloudflare_speed.sh
```

### 2. 配置代理

1. 在 Stash 中找到 `Cloudflare` 代理组
2. 根据测试结果选择最优节点
3. 建议优先选择：
   - 🇺🇸 美国节点
   - 🇸🇬 新加坡节点
   - 🇭🇰 香港节点
   - WARP+ 节点

### 3. 监控效果

- 观察 Cloudflare 相关服务的访问速度
- 检查配置文件更新是否正常
- 验证 Workers 和 Pages 访问效果

## 涉及的域名

- `cloudflare.com` - 主站
- `workers.dev` - Workers 平台
- `pages.dev` - Pages 平台
- `dash.cloudflare.com` - 管理界面
- `api.cloudflare.com` - API 接口
- `1.1.1.1` - DNS 服务
- `cdnjs.cloudflare.com` - CDN 服务
- 以及其他相关子域名

## 预期效果

1. **访问速度提升** - 通过专门的代理策略优化访问速度
2. **稳定性增强** - 多节点备选确保服务可用性
3. **DNS 优化** - 防止 IP 污染，确保正确解析
4. **便于管理** - 独立的代理组便于针对性调优

## 故障排除

### 如果访问仍然缓慢

1. 运行测试脚本检查具体问题
2. 手动切换 Cloudflare 代理组中的节点
3. 检查是否有节点故障或限制
4. 考虑使用 WARP+ 节点

### 如果出现解析问题

1. 检查 DNS 配置是否正确
2. 验证 fake-ip-filter 设置
3. 尝试清除 DNS 缓存

## 维护建议

1. 定期运行测试脚本监控性能
2. 根据网络环境调整节点选择
3. 关注 Cloudflare 服务更新
4. 适时更新规则集内容

---

_最后更新: $(date)_
