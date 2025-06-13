#!/bin/bash

# Cloudflare 访问速度测试脚本
# 用于测试不同代理节点对 Cloudflare 服务的访问速度

echo "=========================================="
echo "Cloudflare 访问速度测试"
echo "=========================================="

# 测试域名列表
CLOUDFLARE_DOMAINS=(
    "cloudflare.com"
    "workers.dev"
    "dash.cloudflare.com"
    "api.cloudflare.com"
    "1.1.1.1"
    "cdnjs.cloudflare.com"
)

# 测试函数
test_domain_speed() {
    local domain=$1
    echo "测试 $domain ..."
    
    # 使用 curl 测试延迟和下载速度
    local result=$(curl -o /dev/null -s -w "DNS解析: %{time_namelookup}s | 建立连接: %{time_connect}s | 总时间: %{time_total}s | HTTP状态: %{http_code}" "https://$domain" --max-time 10 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "✅ $domain - $result"
    else
        echo "❌ $domain - 连接失败或超时"
    fi
    echo ""
}

# 执行测试
echo "开始测试 Cloudflare 域名访问速度..."
echo ""

for domain in "${CLOUDFLARE_DOMAINS[@]}"; do
    test_domain_speed "$domain"
done

echo "=========================================="
echo "测试完成！"
echo ""
echo "建议："
echo "1. 如果多个域名访问速度都较慢，考虑切换代理节点"
echo "2. 可以在 Stash 中手动选择 Cloudflare 代理组的最优节点"
echo "3. 建议优先选择美国、新加坡或香港节点"
echo "==========================================" 
