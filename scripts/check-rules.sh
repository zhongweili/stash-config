#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo -e "${RED}用法: $0 <域名>${NC}"
    echo "例子: $0 google.com"
    exit 1
fi

DOMAIN="$1"

echo -e "${BLUE}=== Stash 规则匹配检查工具 ===${NC}"
echo -e "${BLUE}目标域名: ${YELLOW}$DOMAIN${NC}"
echo ""

# 检查域名是否匹配各种规则类型
echo -e "${BLUE}1. 检查域名规则匹配${NC}"
echo "----------------------------------------"

# 检查直连规则
echo "检查是否匹配直连规则："

# 常见的直连域名模式
DIRECT_PATTERNS=(
    "\.cn$"
    "baidu"
    "tencent"
    "alibaba" 
    "taobao"
    "jd"
    "qq\.com"
    "weibo\.com"
    "163\.com"
    "126\.com"
)

MATCHED_DIRECT=false
for pattern in "${DIRECT_PATTERNS[@]}"; do
    if echo "$DOMAIN" | grep -E "$pattern" > /dev/null; then
        echo -e "${GREEN}✅ 匹配直连规则: $pattern${NC}"
        MATCHED_DIRECT=true
    fi
done

if [ "$MATCHED_DIRECT" = false ]; then
    echo -e "${YELLOW}⚠️  未匹配到直连规则${NC}"
fi

# 检查代理规则
echo -e "\n检查是否匹配代理规则："

PROXY_PATTERNS=(
    "google"
    "youtube"
    "facebook" 
    "twitter"
    "github"
    "stackoverflow"
    "reddit"
)

MATCHED_PROXY=false
for pattern in "${PROXY_PATTERNS[@]}"; do
    if echo "$DOMAIN" | grep -i "$pattern" > /dev/null; then
        echo -e "${GREEN}✅ 可能匹配代理规则: $pattern${NC}"
        MATCHED_PROXY=true
    fi
done

if [ "$MATCHED_PROXY" = false ]; then
    echo -e "${YELLOW}⚠️  未匹配到常见代理规则${NC}"
fi

# 获取实际的规则匹配信息
echo -e "\n${BLUE}2. 获取实际规则匹配${NC}"
echo "----------------------------------------"

# 创建一个测试请求来触发规则匹配
echo "发送测试请求以触发规则匹配..."
curl -s --proxy http://127.0.0.1:7890 --connect-timeout 3 "http://$DOMAIN" > /dev/null 2>&1

# 获取最近的连接信息
CONNECTIONS=$(curl -s "http://127.0.0.1:9090/connections" 2>/dev/null)
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 成功获取连接信息${NC}"
    
    # 查找相关连接
    RELEVANT_CONNECTION=$(echo "$CONNECTIONS" | jq -r ".connections[] | select(.metadata.host | contains(\"$DOMAIN\")) | {rule: .rule, chains: .chains, metadata: .metadata}" 2>/dev/null)
    
    if [ -n "$RELEVANT_CONNECTION" ] && [ "$RELEVANT_CONNECTION" != "null" ]; then
        echo "找到相关连接的规则匹配信息："
        echo "$RELEVANT_CONNECTION" | jq .
    else
        echo -e "${YELLOW}⚠️  未找到该域名的活跃连接${NC}"
    fi
else
    echo -e "${RED}❌ 无法获取连接信息${NC}"
fi

# IP地理位置检查
echo -e "\n${BLUE}3. IP 地理位置检查${NC}"
echo "----------------------------------------"

# 解析域名到IP
IP=$(nslookup "$DOMAIN" | grep -A 1 "Name:" | tail -1 | awk '{print $2}')
echo "域名解析的IP: $IP"

# 检查是否是fake-ip
if [[ "$IP" =~ ^198\.18\. ]]; then
    echo -e "${YELLOW}⚠️  这是 Fake-IP 地址，无法直接判断地理位置${NC}"
    echo "尝试获取真实IP..."
    REAL_IP=$(dig +short "$DOMAIN" @8.8.8.8 | tail -1)
    if [ -n "$REAL_IP" ]; then
        echo "真实IP: $REAL_IP"
        IP="$REAL_IP"
    fi
fi

# 简单的IP地理位置判断（基于已知的IP段）
if [[ "$IP" =~ ^(1|2|14|27|36|39|42|49|58|59|60|61|101|103|106|110|111|112|113|114|115|116|117|118|119|120|121|122|123|124|125|126|127|129|131|132|133|134|135|136|137|138|139|140|141|142|143|144|145|146|147|148|149|150|151|152|153|154|155|156|157|158|159|160|161|162|163|164|165|166|167|168|169|170|171|172|173|174|175|176|177|178|179|180|181|182|183|184|185|186|187|188|189|190|191|192|193|194|195|196|197|198|199|200|201|202|203|210|211|218|219|220|221|222|223)\..*$ ]]; then
    echo -e "${GREEN}✅ IP地址可能位于中国大陆${NC}"
    echo "根据 GEOIP,CN 规则，该域名应该直连"
else
    echo -e "${YELLOW}⚠️  IP地址可能位于海外${NC}"
    echo "根据 GEOIP,CN 规则，该域名应该走代理"
fi

# 建议
echo -e "\n${BLUE}4. 规则优化建议${NC}"
echo "----------------------------------------"

if [ "$MATCHED_DIRECT" = true ]; then
    echo -e "${GREEN}建议: 该域名适合直连访问${NC}"
elif [ "$MATCHED_PROXY" = true ]; then
    echo -e "${YELLOW}建议: 该域名可能需要代理访问${NC}"
else
    echo -e "${BLUE}建议: 该域名将按照默认规则处理${NC}"
    echo "可以考虑："
    echo "1. 如果是国内网站，添加到直连规则"
    echo "2. 如果是国外网站且访问慢，添加到代理规则" 
    echo "3. 检查是否被 GEOIP,CN 规则正确匹配"
fi

echo -e "\n${BLUE}=== 检查完成 ===${NC}" 
