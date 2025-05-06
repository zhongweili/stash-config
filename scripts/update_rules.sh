#!/bin/bash
# 处理本地 rules/ 目录下的规则文件，为 Stash 配置中心准备
# 不从外部仓库拉取，而是使用已有的本地规则文件

# 设置脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
RULES_DIR="${ROOT_DIR}/rules"
PUBLIC_DIR="${ROOT_DIR}/public"
PUBLIC_RULES_DIR="${PUBLIC_DIR}/rules"
PRIVATE_DIR="${ROOT_DIR}/private"
PRIVATE_CONFIG="${PRIVATE_DIR}/config.yaml"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}开始更新 Stash 规则文件...${NC}"
echo -e "${BLUE}========================================${NC}"

# 第1步：检查规则目录
echo -e "${YELLOW}[步骤 1/3] 检查规则目录...${NC}"
if [ ! -d "${RULES_DIR}" ]; then
    echo -e "${RED}错误：规则目录 ${RULES_DIR} 不存在!${NC}"
    exit 1
fi

# 确保输出目录存在
mkdir -p "${PUBLIC_RULES_DIR}"
mkdir -p "${PRIVATE_DIR}"

# 第2步：复制规则文件到public/rules目录
echo -e "${YELLOW}[步骤 2/3] 复制规则文件到public/rules目录...${NC}"

# 获取规则文件数量
RULE_FILES=($(find "${RULES_DIR}" -name "*.yaml" -type f))
RULE_COUNT=${#RULE_FILES[@]}

echo -e "${BLUE}发现 ${RULE_COUNT} 个规则文件${NC}"

# 复制所有规则文件到public/rules
cp "${RULES_DIR}"/*.yaml "${PUBLIC_RULES_DIR}/"

echo -e "${GREEN}成功复制 ${RULE_COUNT} 个规则文件到 public/rules 目录${NC}"

# 第3步：重新生成配置文件（保存到私有目录）
echo -e "${YELLOW}[步骤 3/3] 重新生成配置文件...${NC}"
bash "${SCRIPT_DIR}/build_config.sh" -o "${PRIVATE_CONFIG}"

echo -e "\n${GREEN}Stash规则更新完成！${NC}" 
