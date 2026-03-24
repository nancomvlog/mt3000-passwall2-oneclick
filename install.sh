#!/bin/sh

# ==========================================================
# 项目: GL-MT3000 Passwall2 一键安装工具
# 功能: 自动补齐依赖、安装插件及汉化、刷新后台
# 架构: aarch64_cortex-a53 (Beryl AX 原厂固件专用)
# ==========================================================

# --- 1. 配置区域 (变量定义 - 对应 Python 第 2 章) ---
# 请将下面的 "你的用户名" 修改为你真实的 GitHub ID
GH_USER="nancomvlog"
REPO="mt3000-passwall"
BRANCH="main"
# 使用 ghproxy 加速下载
BASE_URL="https://ghproxy.net/https://raw.githubusercontent.com/$GH_USER/$REPO/$BRANCH/packages"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}>>> 开始执行 MT3000 Passwall2 自动化安装流程...${NC}"

# --- 2. 环境检查 (条件判断 - 对应 Python 第 5 章) ---
if ! opkg print-architecture | grep -q "aarch64_cortex-a53"; then
    echo -e "${RED}错误: 此脚本仅支持 MT3000 (Beryl AX) 架构！安装中止。${NC}"
    exit 1
fi

# 准备工作目录
mkdir -p /tmp/pw_install && cd /tmp/pw_install
echo -e "${YELLOW}检查系统软件源更新...${NC}"
opkg update

# --- 3. 智能安装函数 (函数定义 - 对应 Python 第 8 章) ---
# 作用: 检查包是否存在，不存在则下载并安装
smart_install() {
    local pkg_name=$1
    local file_name=$2
    
    if opkg list-installed | grep -q "$pkg_name"; then
        echo -e "${GREEN}[已存在]${NC} $pkg_name 已经在系统中，跳过下载。"
    else
        echo -e "${YELLOW}[下载中]${NC} 正在获取 $pkg_name..."
        wget -q "$BASE_URL/$file_name" -O "$file_name"
        if [ $? -ne 0 ]; then
            echo -e "${RED}下载失败: $file_name，请检查 GitHub 路径或网络。${NC}"
            exit 1
        fi
        echo -e "${GREEN}[安装中]${NC} 正在部署 $file_name..."
        opkg install "$file_name"
    fi
}

# --- 4. 执行安装队列 (列表操作 - 对应 Python 第 4 章) ---

# A. 安装核心依赖 (你辛苦找出来的两个核心零件)
smart_install "coreutils-base64" "coreutils-base64_8.32-6_aarch64_cortex-a53.ipk"
smart_install "coreutils-nohup" "coreutils-nohup_8.32-6_aarch64_cortex-a53.ipk"

# B. 安装 Passwall2 主程序及汉化包
smart_install "luci-app-passwall2" "luci-app-passwall2_26.3.5_all.ipk"
smart_install "luci-i18n-passwall2-zh-cn" "luci-i18n-passwall2-zh-cn_26.3.5_all.ipk"

# --- 5. 刷新系统环境 (临门一脚) ---
echo -e "${YELLOW}正在执行最后的清理和界面刷新...${NC}"
rm -rf /tmp/luci-indexcache
/etc/init.d/rpcd restart

echo -e "${GREEN}-----------------------------------------------${NC}"
echo -e "${GREEN}🎉 恭喜！Passwall2 已在您的 MT3000 上部署完成。${NC}"
echo -e "${GREEN}请刷新浏览器，进入：高级设置 -> 服务 -> Passwall2${NC}"
echo -e "${GREEN}-----------------------------------------------${NC}"

# 清理临时文件
cd /root && rm -rf /tmp/pw_install
