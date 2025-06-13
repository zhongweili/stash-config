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
    echo "1) 重启 Stash 应用"
    echo "2) 清理网络连接"
    echo "3) 重置DNS缓存"
    echo "4) 刷新代理节点"
    echo "5) 重启代理服务"
    echo "6) 清理系统DNS设置"
    echo "7) 修复权限问题"
    echo "8) 检查端口占用"
    echo "9) 同步私有配置到 Stash"
    echo "10) 批量修复（推荐）"
    echo "0) 退出"
    echo ""
}

restart_stash_app() {
    echo -e "${BLUE}正在重启 Stash 应用...${NC}"
    
    # 检查 Stash 是否正在运行
    if pgrep -x "Stash" > /dev/null; then
        echo "正在停止 Stash..."
        killall Stash 2>/dev/null
        sleep 2
        
        # 确认进程已停止
        if pgrep -x "Stash" > /dev/null; then
            echo -e "${YELLOW}⚠️  Stash 进程仍在运行，请手动退出应用${NC}"
            return 1
        else
            echo -e "${GREEN}✅ Stash 已停止${NC}"
            echo "请手动重新启动 Stash 应用以加载新配置"
        fi
    else
        echo -e "${YELLOW}⚠️  Stash 当前未运行${NC}"
        echo "启动 Stash 时将自动加载新配置"
    fi
}

clear_connections() {
    echo -e "${BLUE}正在清理网络连接...${NC}"
    
    # 重启 Stash 是清理连接的最可靠方法
    restart_stash_app
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
    
    # 重启 Stash 来刷新代理节点
    echo "重启应用是刷新代理节点的最可靠方法"
    restart_stash_app
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

sync_private_config() {
    echo -e "${BLUE}正在同步私有配置到 Stash...${NC}"
    
    # 检查私有配置文件是否存在
    if [ ! -f "private/config.yaml" ]; then
        echo -e "${RED}❌ 私有配置文件 private/config.yaml 不存在${NC}"
        return 1
    fi
    
    # Stash 配置文件路径
    STASH_CONFIG_PATH="$HOME/Library/Application Support/Stash/Core/config.yaml"
    
    # 检查 Stash 配置目录是否存在
    STASH_CONFIG_DIR="$HOME/Library/Application Support/Stash/Core"
    if [ ! -d "$STASH_CONFIG_DIR" ]; then
        echo -e "${YELLOW}⚠️  Stash 配置目录不存在，正在创建...${NC}"
        mkdir -p "$STASH_CONFIG_DIR"
    fi
    
    # 备份现有的 Stash 配置文件
    if [ -f "$STASH_CONFIG_PATH" ]; then
        backup_path="$STASH_CONFIG_PATH.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$STASH_CONFIG_PATH" "$backup_path"
        echo "已备份现有配置到: $backup_path"
    fi
    
    # 同时更新项目内配置和 Stash 配置
    echo "正在同步配置..."
    
    # 1. 更新项目内配置
    if [ -f "config/Stash-Config.yaml" ]; then
        cp "config/Stash-Config.yaml" "config/Stash-Config.yaml.backup.$(date +%Y%m%d_%H%M%S)"
        echo "已备份项目配置文件"
    fi
    cp "private/config.yaml" "config/Stash-Config.yaml"
    
    # 2. 更新 Stash 实际使用的配置
    cp "private/config.yaml" "$STASH_CONFIG_PATH"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 配置同步成功${NC}"
        echo ""
        echo -e "${YELLOW}已更新的配置：${NC}"
        echo "1. 项目配置: config/Stash-Config.yaml"
        echo "2. Stash 配置: $STASH_CONFIG_PATH"
        echo ""
        echo -e "${YELLOW}注意事项：${NC}"
        echo "• 配置将在 Stash 下次启动时或重新加载时生效"
        echo "• 如果 Stash 正在运行，可能需要重启应用"
        echo "• 原配置已备份（带时间戳）"
        
        # 检查 Stash 是否正在运行
        if pgrep -x "Stash" > /dev/null; then
            echo ""
            echo -e "${BLUE}检测到 Stash 正在运行${NC}"
            read -p "是否重启 Stash 应用使配置生效? (y/n): " restart_stash
            if [[ "$restart_stash" =~ ^[Yy]$ ]]; then
                echo "正在重启 Stash..."
                killall Stash 2>/dev/null
                sleep 2
                echo "请手动重新启动 Stash 应用"
            fi
        else
            echo ""
            echo -e "${GREEN}配置已更新，启动 Stash 时将使用新配置${NC}"
        fi
    else
        echo -e "${RED}❌ 配置同步失败${NC}"
        return 1
    fi
}

batch_fix() {
    echo -e "${BLUE}开始批量修复...${NC}"
    echo ""
    
    echo "1/5 重置DNS缓存"
    reset_dns_cache
    sleep 2
    
    echo "2/5 修复系统DNS设置"
    fix_system_dns
    sleep 2
    
    echo "3/5 修复权限"
    fix_permissions
    sleep 2
    
    echo "4/5 检查端口"
    check_port_usage
    sleep 2
    
    echo "5/5 重启 Stash 应用"
    restart_stash_app
    
    echo ""
    echo -e "${GREEN}✅ 批量修复完成${NC}"
    echo ""
    echo "建议在 Stash 重启后执行以下命令测试修复效果："
    echo "./scripts/website-troubleshoot.sh baidu.com"
}

# 主循环
while true; do
    show_menu
    read -p "请输入选项 (0-10): " choice
    
    case $choice in
        1)
            restart_stash_app
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
            sync_private_config
            ;;
        10)
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
