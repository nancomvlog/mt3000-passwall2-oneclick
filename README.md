# 🚀 GL-MT3000 Passwall2 一键安装工具

本脚本专为 **GL.iNet GL-MT3000 (Beryl AX)** 原厂固件打造，旨在解决原厂环境缺失依赖、手动安装繁琐的问题。

MT3000版本号：v4.8.1CN

### ✨ 项目亮点
- **自动化**：一键完成依赖补齐、插件安装、汉化部署。
- **离线包**：内置 `coreutils-base64` 和 `coreutils-nohup`，无需担心软件源 404。
- **兼容性**：适配原厂 OpenWrt 21.02.3 内核，运行稳定。
- **加速下载**：默认集成 ghproxy 镜像，国内环境无压力。

### 🛠️ 使用方法
请通过 SSH 连接到您的 MT3000，然后直接复制并运行以下命令：

```bash
wget -qO- https://ghproxy.net/https://raw.githubusercontent.com/nancomvlog/mt3000-passwall2-oneclick/main/install.sh | sh
