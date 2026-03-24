#!/bin/sh

# ==========================================================
# 项目: GL-MT3000 Passwall2 一键全量安装工具
# 作者: nancomvlog
# 架构: aarch64_cortex-a53 (Beryl AX 原厂固件专用)
# ==========================================================

# --- 1. 配置区域 (核心变量) ---
GH_USER="nancomvlog"
REPO="mt3000-passwall2-oneclick"
BRANCH="main"

# 使用 ghproxy 加速，确保国内下载稳定
BASE_URL="https://ghproxy.net/https://raw.githubusercontent.com/$GH_USER/$REPO/$BRANCH/packages"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}>>> 正在启动 MT3000 Passwall2 自动化安装流程...${NC}"

# --- 2. 架构校验 (对应 Python 第 5 章: 条件判断) ---
if ! opkg print-architecture | grep -q "aarch64_cortex-a53"; then
    echo -e "${RED}错误: 此脚本仅支持 MT3000 (Beryl AX) 架构！安装已中止。${NC}"
    exit 1
fi

# 准备临时工作目录
mkdir -p /tmp/pw_install && cd /tmp/pw_install
echo -e "${YELLOW}正在更新系统软件源...${NC}"
opkg update

# --- 3. 智能安装函数 (对应 Python 第 8 章: 函数重用) ---
smart_install() {
    local pkg_name=$1
    local file_name=$2
    
    if opkg list-installed | grep -q "$pkg_name"; then
        echo -e "${GREEN}[跳过]${NC} $pkg_name 已经安装。"
    else
        echo -e "${YELLOW}[下载]${NC} 正在获取 $file_name..."
        wget -q "$BASE_URL/$file_name" -O "$file_name"
        
        # 检查下载是否成功 (对应 Python 的异常处理思维)
        if [ $? -ne 0 ]; then
            echo -e "${RED}下载失败! 请检查仓库路径: $BASE_URL/$file_name${NC}"
            exit 1
        fi
        
        echo -e "${GREEN}[安装]${NC} 正在部署 $pkg_name..."
        opkg install "$file_name"
    fi
}

# --- 4. 执行顺序队列 (依赖在前，插件在后) ---

echo "--- 正在处理核心依赖 ---"
smart_install "coreutils-base64" "coreutils-base64_8.32-6_aarch64_cortex-a53.ipk"
smart_install "coreutils-nohup" "coreutils-nohup_8.32-6_aarch64_cortex-a53.ipk"

echo "--- 正在处理主程序及汉化 ---"
smart_install "luci-app-passwall2" "luci-app-passwall2_26.3.5_all.ipk"
smart_install "luci-i18n-passwall2-zh-cn" "luci-i18n-passwall2-zh-cn_26.3.5_all.ipk"

# --- 5. 刷新系统后台 (LuCI 缓存清理) ---
echo -e "${YELLOW}正在刷新界面并清理临时文件...${NC}"
rm -rf /tmp/luci-indexcache
/etc/init.d/rpcd restart

echo -e "${GREEN}-----------------------------------------------${NC}"
echo -e "${GREEN}🎉 恭喜！安装已成功完成。${NC}"
echo -e "${GREEN}请刷新页面，在 [高级设置] -> [服务] 菜单中找到它。${NC}"
echo -e "${GREEN}-----------------------------------------------${NC}"

# 自动清理现场
cd /root && rm -rf /tmp/pw_install
