#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Stash 性能监控工具 ===${NC}"
echo -e "${BLUE}开始时间: $(date)${NC}"
echo "按 Ctrl+C 停止监控"
echo ""

# 监控间隔（秒）
INTERVAL=5

# 历史数据存储
declare -a CONNECTION_HISTORY
declare -a MEMORY_HISTORY

while true; do
    clear
    echo -e "${BLUE}=== Stash 实时性能监控 ===${NC}"
    echo -e "${BLUE}更新时间: $(date)${NC}"
    echo ""
    
    # 1. Stash进程状态
    echo -e "${BLUE}1. 进程状态${NC}"
    echo "----------------------------------------"
    
    STASH_PID=$(pgrep -x "Stash")
    if [ -n "$STASH_PID" ]; then
        echo -e "${GREEN}✅ Stash 运行中，PID: $STASH_PID${NC}"
        
        # 获取进程资源使用情况
        PS_INFO=$(ps -p "$STASH_PID" -o %cpu,%mem,vsz,rss,time | tail -1)
        CPU_USAGE=$(echo "$PS_INFO" | awk '{print $1}')
        MEM_USAGE=$(echo "$PS_INFO" | awk '{print $2}')
        VSZ=$(echo "$PS_INFO" | awk '{print $3}')
        RSS=$(echo "$PS_INFO" | awk '{print $4}')
        TIME=$(echo "$PS_INFO" | awk '{print $5}')
        
        echo "CPU 使用率: ${CPU_USAGE}%"
        echo "内存使用率: ${MEM_USAGE}%"
        echo "虚拟内存: ${VSZ} KB"
        echo "物理内存: ${RSS} KB"
        echo "运行时间: ${TIME}"
    else
        echo -e "${RED}❌ Stash 未运行${NC}"
        sleep "$INTERVAL"
        continue
    fi
    
    # 2. 网络连接统计
    echo -e "\n${BLUE}2. 网络连接统计${NC}"
    echo "----------------------------------------"
    
    CONNECTIONS_DATA=$(curl -s "http://127.0.0.1:9090/connections" 2>/dev/null)
    if [ $? -eq 0 ]; then
        TOTAL_CONNECTIONS=$(echo "$CONNECTIONS_DATA" | jq '.connections | length' 2>/dev/null || echo "0")
        
        # 按规则分组统计
        DIRECT_COUNT=$(echo "$CONNECTIONS_DATA" | jq '[.connections[] | select(.chains[] | contains("DIRECT"))] | length' 2>/dev/null || echo "0")
        PROXY_COUNT=$(expr "$TOTAL_CONNECTIONS" - "$DIRECT_COUNT" 2>/dev/null || echo "0")
        
        echo "总连接数: $TOTAL_CONNECTIONS"
        echo "直连: $DIRECT_COUNT"
        echo "代理: $PROXY_COUNT"
        
        # 保存历史数据（最近20个数据点）
        CONNECTION_HISTORY+=("$TOTAL_CONNECTIONS")
        if [ ${#CONNECTION_HISTORY[@]} -gt 20 ]; then
            CONNECTION_HISTORY=("${CONNECTION_HISTORY[@]:1}")
        fi
        
        # 显示连接趋势
        echo -n "连接趋势: "
        for count in "${CONNECTION_HISTORY[@]}"; do
            if [ "$count" -gt 50 ]; then
                echo -n "█"
            elif [ "$count" -gt 30 ]; then
                echo -n "▇"
            elif [ "$count" -gt 20 ]; then
                echo -n "▅"
            elif [ "$count" -gt 10 ]; then
                echo -n "▃"
            elif [ "$count" -gt 0 ]; then
                echo -n "▁"
            else
                echo -n "_"
            fi
        done
        echo ""
    else
        echo -e "${RED}❌ 无法获取连接信息${NC}"
    fi
    
    # 3. 代理节点状态
    echo -e "\n${BLUE}3. 代理节点状态${NC}"
    echo "----------------------------------------"
    
    PROXIES_DATA=$(curl -s "http://127.0.0.1:9090/proxies" 2>/dev/null)
    if [ $? -eq 0 ]; then
        # 统计可用节点数
        echo "检查代理节点健康状态..."
        
        # 获取主要代理组的状态
        MAIN_GROUPS=("国外流量" "其他流量" "AIRPORT")
        for group in "${MAIN_GROUPS[@]}"; do
            GROUP_STATUS=$(echo "$PROXIES_DATA" | jq -r ".proxies[\"$group\"].now" 2>/dev/null)
            if [ "$GROUP_STATUS" != "null" ] && [ -n "$GROUP_STATUS" ]; then
                echo "$group: $GROUP_STATUS"
            fi
        done
    else
        echo -e "${RED}❌ 无法获取代理信息${NC}"
    fi
    
    # 4. DNS解析性能
    echo -e "\n${BLUE}4. DNS 解析性能${NC}"
    echo "----------------------------------------"
    
    # 测试DNS解析速度
    DNS_START=$(date +%s.%N)
    nslookup baidu.com > /dev/null 2>&1
    DNS_END=$(date +%s.%N)
    DNS_TIME=$(echo "$DNS_END - $DNS_START" | bc 2>/dev/null || echo "N/A")
    
    echo "DNS解析测试 (baidu.com): ${DNS_TIME}秒"
    
    # 5. 网络延迟测试
    echo -e "\n${BLUE}5. 网络延迟测试${NC}"
    echo "----------------------------------------"
    
    # 测试几个常见网站的延迟
    TEST_SITES=("baidu.com" "qq.com")
    for site in "${TEST_SITES[@]}"; do
        PING_RESULT=$(ping -c 1 -W 3 "$site" 2>/dev/null | grep "time=" | awk '{print $7}' | cut -d'=' -f2)
        if [ -n "$PING_RESULT" ]; then
            echo "$site: $PING_RESULT"
        else
            echo "$site: 超时"
        fi
    done
    
    # 6. 错误统计
    echo -e "\n${BLUE}6. 最近错误${NC}"
    echo "----------------------------------------"
    
    # 检查最近的连接错误
    if [ -n "$CONNECTIONS_DATA" ]; then
        ERROR_COUNT=$(echo "$CONNECTIONS_DATA" | jq '[.connections[] | select(.metadata.sourceIP == "")] | length' 2>/dev/null || echo "0")
        echo "异常连接数: $ERROR_COUNT"
    fi
    
    # 7. 系统建议
    echo -e "\n${BLUE}7. 系统建议${NC}"
    echo "----------------------------------------"
    
    if [ "$TOTAL_CONNECTIONS" -gt 100 ]; then
        echo -e "${YELLOW}⚠️  连接数较多，可能影响性能${NC}"
    fi
    
    if [ "$PROXY_COUNT" -gt "$DIRECT_COUNT" ]; then
        echo -e "${YELLOW}⚠️  代理连接较多，检查规则配置${NC}"
    fi
    
    # 底部状态栏
    echo ""
    echo "========================================"
    echo "监控间隔: ${INTERVAL}秒 | 按 Ctrl+C 退出"
    
    sleep "$INTERVAL"
done 
