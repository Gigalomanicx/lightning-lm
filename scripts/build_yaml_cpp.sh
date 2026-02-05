#!/bin/bash
# 从源码编译安装兼容的 yaml-cpp 版本
# 安装到用户目录，避免影响系统库
# 支持 Ubuntu 20.04 和 22.04

set -e

# 检测 Ubuntu 版本
if [ -f /etc/os-release ]; then
    . /etc/os-release
    UBUNTU_VERSION=$(echo $VERSION_ID | cut -d. -f1)
else
    UBUNTU_VERSION=$(lsb_release -rs | cut -d. -f1)
fi

echo "检测到 Ubuntu 版本: ${UBUNTU_VERSION}"

# 根据 Ubuntu 版本选择 yaml-cpp 版本
# Ubuntu 22.04 的 yaml-cpp 版本应该是 0.7.0，通常已经修复了 ABI 问题
# 但如果仍有问题，可以从源码编译
if [ "$UBUNTU_VERSION" -ge 22 ]; then
    # Ubuntu 22.04 通常使用 yaml-cpp 0.7.0，先检查系统版本是否可用
    SYSTEM_YAML_CPP_VERSION=$(dpkg -l | grep libyaml-cpp-dev | awk '{print $3}' | cut -d- -f1 || echo "")
    if [ -n "$SYSTEM_YAML_CPP_VERSION" ]; then
        echo "检测到系统 yaml-cpp 版本: ${SYSTEM_YAML_CPP_VERSION}"
        echo "Ubuntu 22.04 的 yaml-cpp 通常已经修复了 ABI 问题。"
        echo "如果编译时仍有符号不匹配错误，再运行此脚本从源码编译。"
    fi
    YAML_CPP_VERSION="0.7.0"  # Ubuntu 22.04 推荐版本
    echo "将从源码安装 yaml-cpp ${YAML_CPP_VERSION}"
else
    YAML_CPP_VERSION="0.7.0"  # Ubuntu 20.04 兼容版本
    echo "Ubuntu 20.04 的系统 yaml-cpp 0.6.2 有 ABI 问题，将从源码安装 ${YAML_CPP_VERSION}"
fi

# 使用用户目录，避免影响系统库
INSTALL_PREFIX="${HOME}/.local/yaml-cpp-${YAML_CPP_VERSION}"
BUILD_DIR="/tmp/yaml-cpp-build"

echo "正在下载 yaml-cpp ${YAML_CPP_VERSION}..."

# 清理旧的构建目录
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}

# 下载源码
cd ${BUILD_DIR}
if [ ! -d "yaml-cpp" ]; then
    git clone https://github.com/jbeder/yaml-cpp.git
fi

cd yaml-cpp
git fetch --all --tags
git checkout yaml-cpp-${YAML_CPP_VERSION}

echo "正在编译 yaml-cpp..."
mkdir -p build
cd build

# 配置 CMake
cmake .. \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DCMAKE_BUILD_TYPE=Release \
    -DYAML_BUILD_SHARED_LIBS=ON \
    -DYAML_CPP_BUILD_TESTS=OFF

# 编译
make -j$(nproc)

echo "正在安装 yaml-cpp 到 ${INSTALL_PREFIX}..."
make install  # 不需要 sudo，因为安装到用户目录

echo ""
echo "=========================================="
echo "yaml-cpp ${YAML_CPP_VERSION} 安装完成！"
echo "安装路径: ${INSTALL_PREFIX}"
echo ""
echo "这个版本安装在用户目录，不会影响系统库。"
echo ""
echo "使用方法："
echo "1. 临时使用（当前终端会话）："
echo "   export CMAKE_PREFIX_PATH=\"${INSTALL_PREFIX}:\$CMAKE_PREFIX_PATH\""
echo "   export LD_LIBRARY_PATH=\"${INSTALL_PREFIX}/lib:\$LD_LIBRARY_PATH\""
echo ""
echo "2. 永久使用（添加到 ~/.bashrc）："
echo "   echo 'export CMAKE_PREFIX_PATH=\"${INSTALL_PREFIX}:\$CMAKE_PREFIX_PATH\"' >> ~/.bashrc"
echo "   echo 'export LD_LIBRARY_PATH=\"${INSTALL_PREFIX}/lib:\$LD_LIBRARY_PATH\"' >> ~/.bashrc"
echo ""
echo "3. 在 CMake 中指定（推荐）："
echo "   在 colcon build 时使用："
echo "   colcon build --cmake-args -Dyaml-cpp_DIR=\"${INSTALL_PREFIX}/lib/cmake/yaml-cpp\""
echo "=========================================="

