#!/bin/bash

# 卸载通过源码编译安装的 Pangolin 的脚本
# 注意：此脚本会删除通过 make install 安装到 /usr/local 的 Pangolin 文件

echo "=========================================="
echo "Pangolin 卸载脚本"
echo "=========================================="
echo ""
echo "警告: 此脚本将删除以下位置的 Pangolin 文件:"
echo "  - /usr/local/include/pangolin/"
echo "  - /usr/local/lib/libpangolin*"
echo "  - /usr/local/lib/cmake/Pangolin/"
echo "  - /usr/local/share/cmake/Pangolin/"
echo "  - /usr/local/bin/pangolin* (如果有)"
echo ""
read -p "确定要继续吗? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "取消卸载"
    exit 0
fi

echo ""
echo "开始卸载..."

# 删除头文件
if [ -d "/usr/local/include/pangolin" ]; then
    echo "删除头文件: /usr/local/include/pangolin/"
    sudo rm -rf /usr/local/include/pangolin
else
    echo "未找到 /usr/local/include/pangolin/"
fi

# 删除库文件
if ls /usr/local/lib/libpangolin*.so* /usr/local/lib/libpangolin*.a 2>/dev/null | grep -q pangolin; then
    echo "删除库文件: /usr/local/lib/libpangolin*"
    sudo rm -f /usr/local/lib/libpangolin*.so*
    sudo rm -f /usr/local/lib/libpangolin*.a
else
    echo "未找到 /usr/local/lib/libpangolin*"
fi

# 删除 CMake 配置文件
for cmake_path in /usr/local/lib/cmake/Pangolin /usr/local/share/cmake/Pangolin; do
    if [ -d "$cmake_path" ]; then
        echo "删除 CMake 配置: $cmake_path"
        sudo rm -rf "$cmake_path"
    fi
done

# 删除可执行文件（如果有）
if ls /usr/local/bin/pangolin* 2>/dev/null | grep -q pangolin; then
    echo "删除可执行文件: /usr/local/bin/pangolin*"
    sudo rm -f /usr/local/bin/pangolin*
fi

# 更新动态链接库缓存
if command -v ldconfig &> /dev/null; then
    echo "更新动态链接库缓存..."
    sudo ldconfig
fi

echo ""
echo "=========================================="
echo "卸载完成！"
echo "=========================================="
echo ""
echo "提示: 如果 Pangolin 是通过 apt 安装的，请使用:"
echo "  sudo apt remove libpangolin-dev"
echo "  sudo apt autoremove"

