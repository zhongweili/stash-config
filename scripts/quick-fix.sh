#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Stash 快速修复工具 ===${NC}"
echo ""

show_menu() {
    echo "请选择要执行的修复操作："
    echo ""
    echo "1) 重载配置文件"
    echo "2) 清理所有连接"
    echo "3) 重置DNS缓存"
    echo "4) 刷新代理节点"
    echo "5) 重启代理服务"
    echo "6) 清理系统DNS设置"
    echo "7) 修复权限问题"
    echo "8) 检查端口占用"
    echo "9) 批量修复（推荐）"
    echo "0) 退出"
    echo ""
}

reload_config() {
    echo -e "${BLUE}正在重载配置文件...${NC}"
    
    curl -X PUT "http://127.0.0.1:9090/configs?force=true" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 配置重载成功${NC}"
    else
        echo -e "${RED}❌ 配置重载失败${NC}"
        return 1
    fi
}

clear_connections() {
    echo -e "${BLUE}正在清理所有连接...${NC}"
    
    curl -X DELETE "http://127.0.0.1:9090/connections" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 连接清理成功${NC}"
    else
        echo -e "${RED}❌ 连接清理失败${NC}"
        return 1
    fi
}

reset_dns_cache() {
    echo -e "${BLUE}正在重置DNS缓存...${NC}"
    
    # macOS DNS缓存清理
    sudo dscacheutil -flushcache 2>/dev/null
    sudo killall -HUP mDNSResponder 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ DNS缓存重置成功${NC}"
    else
        echo -e "${YELLOW}⚠️  DNS缓存重置可能需要管理员权限${NC}"
    fi
}

refresh_proxies() {
    echo -e "${BLUE}正在刷新代理节点...${NC}"
    
    # 强制更新代理提供者
    curl -X PUT "http://127.0.0.1:9090/providers/proxies/airport" -d '{"name":"airport"}' 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 代理节点刷新成功${NC}"
    else
        echo -e "${RED}❌ 代理节点刷新失败${NC}"
        return 1
    fi
}

restart_proxy_service() {
    echo -e "${BLUE}正在重启代理服务...${NC}"
    
    # 获取Stash进程ID
    STASH_PID=$(pgrep -x "Stash")
    
    if [ -n "$STASH_PID" ]; then
        echo "发现Stash进程 PID: $STASH_PID"
        echo "正在重启..."
        
        # 发送重启信号
        kill -HUP "$STASH_PID" 2>/dev/null
        
        sleep 3
        
        # 检查是否重启成功
        if pgrep -x "Stash" > /dev/null; then
            echo -e "${GREEN}✅ 代理服务重启成功${NC}"
        else
            echo -e "${RED}❌ 代理服务重启失败，请手动重启Stash应用${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ 未找到Stash进程${NC}"
        return 1
    fi
}

fix_system_dns() {
    echo -e "${BLUE}正在修复系统DNS设置...${NC}"
    
    # 检查当前DNS设置
    CURRENT_DNS=$(networksetup -getdnsservers "Wi-Fi" 2>/dev/null | head -1)
    
    echo "当前DNS设置: $CURRENT_DNS"
    
    # 如果DNS设置不正常，尝试修复
    if [[ "$CURRENT_DNS" == "1.0.0.1" ]] || [[ "$CURRENT_DNS" == "127.0.0.1" ]]; then
        echo "检测到异常DNS设置，正在修复..."
        
        echo "请输入管理员密码以修复DNS设置："
        sudo networksetup -setdnsservers "Wi-Fi" 114.114.114.114 8.8.8.8
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ DNS设置修复成功${NC}"
        else
            echo -e "${RED}❌ DNS设置修复失败${NC}"
            echo "请手动在系统设置中修改DNS为: 114.114.114.114, 8.8.8.8"
            return 1
        fi
    else
        echo -e "${GREEN}✅ DNS设置正常${NC}"
    fi
}

fix_permissions() {
    echo -e "${BLUE}正在修复权限问题...${NC}"
    
    # 修复配置文件权限
    chmod 644 config/*.yaml 2>/dev/null
    chmod +x scripts/*.sh 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 权限修复成功${NC}"
    else
        echo -e "${YELLOW}⚠️  部分权限修复可能需要管理员权限${NC}"
    fi
}

check_port_usage() {
    echo -e "${BLUE}正在检查端口占用情况...${NC}"
    
    PORTS=(7890 7891 7892 9090)
    
    for port in "${PORTS[@]}"; do
        PROCESS=$(lsof -i ":$port" 2>/dev/null | grep LISTEN | awk '{print $1}' | head -1)
        if [ -n "$PROCESS" ]; then
            echo "端口 $port: $PROCESS"
        else
            echo "端口 $port: 未被占用"
        fi
    done
    
    echo -e "${GREEN}✅ 端口检查完成${NC}"
}

batch_fix() {
    echo -e "${BLUE}开始批量修复...${NC}"
    echo ""
    
    echo "1/6 重载配置文件"
    reload_config
    sleep 2
    
    echo "2/6 清理连接"
    clear_connections
    sleep 2
    
    echo "3/6 重置DNS缓存"
    reset_dns_cache
    sleep 2
    
    echo "4/6 刷新代理节点"
    refresh_proxies
    sleep 2
    
    echo "5/6 修复权限"
    fix_permissions
    sleep 2
    
    echo "6/6 检查端口"
    check_port_usage
    
    echo ""
    echo -e "${GREEN}✅ 批量修复完成${NC}"
    echo ""
    echo "建议执行以下命令测试修复效果："
    echo "./scripts/website-troubleshoot.sh baidu.com"
}

# 主循环
while true; do
    show_menu
    read -p "请输入选项 (0-9): " choice
    
    case $choice in
        1)
            reload_config
            ;;
        2)
            clear_connections
            ;;
        3)
            reset_dns_cache
            ;;
        4)
            refresh_proxies
            ;;
        5)
            restart_proxy_service
            ;;
        6)
            fix_system_dns
            ;;
        7)
            fix_permissions
            ;;
        8)
            check_port_usage
            ;;
        9)
            batch_fix
            ;;
        0)
            echo -e "${BLUE}退出修复工具${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}无效选项，请重新选择${NC}"
            ;;
    esac
    
    echo ""
    read -p "按回车键继续..."
    clear
done 
