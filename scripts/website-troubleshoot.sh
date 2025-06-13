#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查参数
if [ $# -eq 0 ]; then
    echo -e "${RED}用法: $0 <网站域名或URL>${NC}"
    echo "例子: $0 google.com"
    echo "     $0 https://github.com"
    exit 1
fi

WEBSITE="$1"
# 提取域名
DOMAIN=$(echo "$WEBSITE" | sed -e 's|^[^/]*//||' -e 's|/.*$||' -e 's|:.*$||')

echo -e "${BLUE}=== Stash 网站访问问题排查工具 ===${NC}"
echo -e "${BLUE}目标网站: ${YELLOW}$WEBSITE${NC}"
echo -e "${BLUE}域名: ${YELLOW}$DOMAIN${NC}"
echo -e "${BLUE}开始时间: $(date)${NC}"
echo ""

# 检查Stash是否运行
echo -e "${BLUE}1. 检查 Stash 服务状态${NC}"
echo "----------------------------------------"
if pgrep -x "Stash" > /dev/null; then
    echo -e "${GREEN}✅ Stash 正在运行，PID: $(pgrep -x "Stash")${NC}"
    
    # 检查控制接口
    if curl -s "http://127.0.0.1:9090/configs" | head -c 50 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Stash 控制接口正常${NC}"
    else
        echo -e "${RED}❌ Stash 控制接口无响应${NC}"
    fi
else
    echo -e "${RED}❌ Stash 未运行${NC}"
    exit 1
fi

# 检查基础网络连通性
echo -e "\n${BLUE}2. 基础网络连通性测试${NC}"
echo "----------------------------------------"
echo "测试系统直连（不通过代理）:"

# 测试ping
timeout 5 ping -c 2 "$DOMAIN" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Ping 测试通过${NC}"
else
    echo -e "${YELLOW}⚠️  Ping 测试失败（某些网站可能禁用ping）${NC}"
fi

# 测试直连HTTP
if [[ "$WEBSITE" == http* ]]; then
    TEST_URL="$WEBSITE"
else
    TEST_URL="https://$DOMAIN"
fi

echo "测试直连 HTTP 请求："
timeout 10 curl -I --connect-timeout 5 "$TEST_URL" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 直连 HTTP 请求成功${NC}"
    DIRECT_OK=true
else
    echo -e "${RED}❌ 直连 HTTP 请求失败${NC}"
    DIRECT_OK=false
fi

# DNS解析测试
echo -e "\n${BLUE}3. DNS 解析测试${NC}"
echo "----------------------------------------"
echo "系统DNS解析结果:"
SYSTEM_DNS=$(nslookup "$DOMAIN" | grep -A 1 "Name:" | tail -1 | awk '{print $2}')
echo "IP地址: $SYSTEM_DNS"

# 检查是否是fake-ip
if [[ "$SYSTEM_DNS" =~ ^198\.18\. ]]; then
    echo -e "${YELLOW}⚠️  检测到 Fake-IP 地址，这是正常的${NC}"
else
    echo -e "${GREEN}✅ 真实 IP 地址${NC}"
fi

# Stash代理测试
echo -e "\n${BLUE}4. 通过 Stash 代理测试${NC}"
echo "----------------------------------------"
echo "测试通过 Stash 代理访问:"

timeout 15 curl -I --proxy http://127.0.0.1:7890 --connect-timeout 5 "$TEST_URL" > /dev/null 2>&1
PROXY_RESULT=$?

if [ $PROXY_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ 通过 Stash 代理访问成功${NC}"
    PROXY_OK=true
else
    echo -e "${RED}❌ 通过 Stash 代理访问失败${NC}"
    PROXY_OK=false
fi

# 规则匹配检查
echo -e "\n${BLUE}5. 规则匹配检查${NC}"
echo "----------------------------------------"
echo "检查域名匹配的规则:"

# 获取规则匹配信息
RULE_INFO=$(curl -s "http://127.0.0.1:9090/rules" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 成功获取规则信息${NC}"
    # 这里可以添加更复杂的规则分析逻辑
else
    echo -e "${YELLOW}⚠️  无法获取规则信息${NC}"
fi

# 代理节点健康检查
echo -e "\n${BLUE}6. 代理节点健康检查${NC}"
echo "----------------------------------------"
echo "检查代理节点状态:"

PROXIES_INFO=$(curl -s "http://127.0.0.1:9090/proxies" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 成功获取代理节点信息${NC}"
    
    # 检查当前选中的代理
    echo "当前活跃连接数："
    curl -s "http://127.0.0.1:9090/connections" | jq '. | length' 2>/dev/null || echo "无法获取连接信息"
else
    echo -e "${YELLOW}⚠️  无法获取代理节点信息${NC}"
fi

# 速度测试
echo -e "\n${BLUE}7. 访问速度测试${NC}"
echo "----------------------------------------"
echo "测试下载速度:"

if [ "$PROXY_OK" = true ]; then
    echo "通过 Stash 代理下载测试文件..."
    START_TIME=$(date +%s.%N)
    timeout 10 curl -s --proxy http://127.0.0.1:7890 -o /dev/null "http://httpbin.org/bytes/1024" 2>/dev/null
    END_TIME=$(date +%s.%N)
    
    if [ $? -eq 0 ]; then
        DURATION=$(echo "$END_TIME - $START_TIME" | bc 2>/dev/null || echo "N/A")
        echo -e "${GREEN}✅ 代理速度测试完成，耗时: ${DURATION}秒${NC}"
    else
        echo -e "${RED}❌ 代理速度测试失败${NC}"
    fi
fi

# 问题诊断和建议
echo -e "\n${BLUE}8. 问题诊断和建议${NC}"
echo "----------------------------------------"

if [ "$DIRECT_OK" = false ] && [ "$PROXY_OK" = false ]; then
    echo -e "${RED}❌ 网络问题：直连和代理都无法访问${NC}"
    echo "建议："
    echo "1. 检查网络连接是否正常"
    echo "2. 检查防火墙设置"
    echo "3. 尝试访问其他网站测试"
    
elif [ "$DIRECT_OK" = true ] && [ "$PROXY_OK" = false ]; then
    echo -e "${YELLOW}⚠️  代理问题：直连正常但代理失败${NC}"
    echo "建议："
    echo "1. 检查 Stash 配置文件"
    echo "2. 检查代理规则是否正确"
    echo "3. 检查代理节点是否可用"
    echo "4. 查看 Stash 日志"
    
elif [ "$DIRECT_OK" = false ] && [ "$PROXY_OK" = true ]; then
    echo -e "${YELLOW}⚠️  网络问题：代理正常但直连失败${NC}"
    echo "这种情况通常是正常的，表示该网站需要通过代理访问"
    
else
    echo -e "${GREEN}✅ 网络状态正常${NC}"
    echo "如果仍然遇到问题，可能是："
    echo "1. 间歇性网络问题"
    echo "2. 特定页面或资源的问题"
    echo "3. 浏览器缓存问题"
fi

# 快速修复建议
echo -e "\n${BLUE}9. 快速修复命令${NC}"
echo "----------------------------------------"
echo "如果需要快速修复，可以尝试："
echo ""
echo "重载 Stash 配置："
echo "curl -X PUT 'http://127.0.0.1:9090/configs?force=true'"
echo ""
echo "清理连接："
echo "curl -X DELETE 'http://127.0.0.1:9090/connections'"
echo ""
echo "查看实时日志："
echo "curl -s 'http://127.0.0.1:9090/logs?level=info'"

echo -e "\n${BLUE}=== 排查完成 ===${NC}"
echo -e "${BLUE}结束时间: $(date)${NC}" 
