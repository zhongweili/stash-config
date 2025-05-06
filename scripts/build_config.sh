#!/bin/bash
# 生成Stash配置文件，自动集成本地rules目录中的所有规则文件

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 路径定义
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
RULES_DIR="${ROOT_DIR}/rules"
CONFIG_DIR="${ROOT_DIR}/config"
PUBLIC_DIR="${ROOT_DIR}/public"
PRIVATE_DIR="${ROOT_DIR}/private"
PUBLIC_RULES_DIR="${PUBLIC_DIR}/rules"
DEFAULT_TEMPLATE="${CONFIG_DIR}/Stash-Config.yaml"
DEFAULT_OUTPUT="${PRIVATE_DIR}/config.yaml"

# 帮助函数
help() {
    echo -e "${BLUE}Stash配置生成工具${NC}"
    echo -e "用法: $0 [选项]"
    echo -e "\n选项:"
    echo -e "  -h, --help            显示帮助信息"
    echo -e "  -t, --template FILE   指定模板文件 (默认: ${DEFAULT_TEMPLATE})"
    echo -e "  -o, --output FILE     指定输出文件 (默认: ${DEFAULT_OUTPUT})"
    echo -e "  -r, --rules DIR       指定规则目录 (默认: ${RULES_DIR})"
    echo
    echo -e "说明: 此脚本从本地rules目录读取规则文件，自动生成Stash配置文件"
}

# 解析命令行参数
TEMPLATE_FILE="${DEFAULT_TEMPLATE}"
OUTPUT_FILE="${DEFAULT_OUTPUT}"
RULES_SOURCE="${RULES_DIR}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            help
            exit 0
            ;;
        -t|--template)
            TEMPLATE_FILE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -r|--rules)
            RULES_SOURCE="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}错误: 未知参数 $1${NC}"
            help
            exit 1
            ;;
    esac
done

# 检查必要文件和目录
if [ ! -f "${TEMPLATE_FILE}" ]; then
    echo -e "${RED}错误: 模板文件 ${TEMPLATE_FILE} 不存在${NC}"
    exit 1
fi

if [ ! -d "${RULES_SOURCE}" ]; then
    echo -e "${RED}错误: 规则目录 ${RULES_SOURCE} 不存在${NC}"
    exit 1
fi

# 创建输出目录
mkdir -p "$(dirname "${OUTPUT_FILE}")"
mkdir -p "${PUBLIC_RULES_DIR}"

# 复制模板文件到临时输出文件
TMP_OUTPUT="${OUTPUT_FILE}.tmp"
cp "${TEMPLATE_FILE}" "${TMP_OUTPUT}"

echo -e "${GREEN}正在生成Stash配置文件...${NC}"

# 获取规则文件
RULE_FILES=($(find "${RULES_SOURCE}" -name "*.yaml" -type f))

# 更新rule-providers部分
for RULE_FILE in "${RULE_FILES[@]}"; do
    RULE_NAME=$(basename "${RULE_FILE}" .yaml)
    
    # 如果规则尚未在模板中定义，则添加它
    if ! grep -q "rule-file-path-${RULE_NAME}:" "${TMP_OUTPUT}"; then
        # 在rule-providers-config部分末尾添加新规则
        sed -i '' "/rule-providers-config:/,/rule-providers-group:/ s|rule-providers-group:|  ${RULE_NAME}:\n    rule-file-path-${RULE_NAME}: \&rule-file-path-${RULE_NAME} myprovider/ruleset/${RULE_NAME}.yaml\n    rule-provider-url-${RULE_NAME}: \&rule-provider-url-${RULE_NAME} https://cdn.jsdelivr.net/gh/zhongweili/stash-config@master/public/rules/${RULE_NAME}.yaml\n  rule-providers-group:|" "${TMP_OUTPUT}"
        
        # 在rules部分添加新规则引用
        sed -i '' "/^rules:/a\\
  - RULE-SET,${RULE_NAME},${RULE_NAME}" "${TMP_OUTPUT}"
        
        # 在rule-providers部分添加新规则
        sed -i '' "/^rule-providers:/a\\
  ${RULE_NAME}: \n    type: http\n    behavior: classical\n    path: *rule-file-path-${RULE_NAME}\n    url: *rule-provider-url-${RULE_NAME}\n    interval: *rule-interval" "${TMP_OUTPUT}"
    fi
done

# 移动临时文件到最终输出位置
mv "${TMP_OUTPUT}" "${OUTPUT_FILE}"

echo -e "${GREEN}配置文件生成完成${NC}"
echo -e "${BLUE}共处理了 ${#RULE_FILES[@]} 个规则文件${NC}"
echo -e "${YELLOW}注意: 请确保CDN已正确配置，以便规则能够正常更新${NC}" 
