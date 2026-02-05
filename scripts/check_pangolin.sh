#!/bin/bash

# 检查 Pangolin 是否已安装的脚本

echo "=========================================="
echo "检查 Pangolin 安装状态"
echo "=========================================="

# 方法1: 使用 pkg-config 检查
echo ""
echo "方法1: 使用 pkg-config 检查"
if pkg-config --exists pangolin; then
    echo "✓ Pangolin 已安装 (通过 pkg-config)"
    pkg-config --modversion pangolin
    pkg-config --cflags pangolin
    pkg-config --libs pangolin
else
    echo "✗ pkg-config 未找到 Pangolin"
fi

# 方法2: 使用 CMake 检查
echo ""
echo "方法2: 使用 CMake 检查"
cat > /tmp/check_pangolin.cmake << 'EOF'
find_package(Pangolin QUIET)
if(Pangolin_FOUND)
    message(STATUS "Pangolin found: YES")
    message(STATUS "Pangolin version: ${Pangolin_VERSION}")
    message(STATUS "Pangolin include dirs: ${Pangolin_INCLUDE_DIRS}")
    message(STATUS "Pangolin libraries: ${Pangolin_LIBRARIES}")
else()
    message(STATUS "Pangolin found: NO")
endif()
EOF

if cmake -P /tmp/check_pangolin.cmake 2>/dev/null | grep -q "Pangolin found: YES"; then
    echo "✓ Pangolin 已安装 (通过 CMake)"
    cmake -P /tmp/check_pangolin.cmake 2>/dev/null
else
    echo "✗ CMake 未找到 Pangolin"
fi
rm -f /tmp/check_pangolin.cmake

# 方法3: 检查头文件
echo ""
echo "方法3: 检查头文件"
if [ -f "/usr/local/include/pangolin/pangolin.h" ] || [ -f "/usr/include/pangolin/pangolin.h" ]; then
    echo "✓ 找到 Pangolin 头文件"
    if [ -f "/usr/local/include/pangolin/pangolin.h" ]; then
        echo "  位置: /usr/local/include/pangolin/pangolin.h"
    fi
    if [ -f "/usr/include/pangolin/pangolin.h" ]; then
        echo "  位置: /usr/include/pangolin/pangolin.h"
    fi
else
    echo "✗ 未找到 Pangolin 头文件"
fi

# 方法4: 检查库文件
echo ""
echo "方法4: 检查库文件"
FOUND_LIB=false
for lib_path in /usr/local/lib /usr/lib /usr/lib/x86_64-linux-gnu; do
    if ls ${lib_path}/libpangolin*.so* ${lib_path}/libpangolin*.a 2>/dev/null | grep -q pangolin; then
        echo "✓ 找到 Pangolin 库文件"
        echo "  位置: ${lib_path}"
        ls -lh ${lib_path}/libpangolin* 2>/dev/null
        FOUND_LIB=true
        break
    fi
done

if [ "$FOUND_LIB" = false ]; then
    echo "✗ 未找到 Pangolin 库文件"
fi

# 方法5: 检查 CMake 配置文件
echo ""
echo "方法5: 检查 CMake 配置文件"
FOUND_CMAKE=false
for cmake_path in /usr/local/lib/cmake/Pangolin /usr/local/share/cmake/Pangolin /usr/lib/cmake/Pangolin; do
    if [ -f "${cmake_path}/PangolinConfig.cmake" ] || [ -f "${cmake_path}/pangolin-config.cmake" ]; then
        echo "✓ 找到 Pangolin CMake 配置文件"
        echo "  位置: ${cmake_path}"
        FOUND_CMAKE=true
        break
    fi
done

if [ "$FOUND_CMAKE" = false ]; then
    echo "✗ 未找到 Pangolin CMake 配置文件"
fi

# 总结
echo ""
echo "=========================================="
echo "总结"
echo "=========================================="
if pkg-config --exists pangolin 2>/dev/null || \
   [ -f "/usr/local/include/pangolin/pangolin.h" ] || \
   [ -f "/usr/include/pangolin/pangolin.h" ]; then
    echo "✓ Pangolin 似乎已安装"
    echo ""
    echo "安装位置可能在以下目录之一:"
    echo "  - /usr/local/include/pangolin/"
    echo "  - /usr/local/lib/"
    echo "  - /usr/include/pangolin/"
    echo "  - /usr/lib/"
else
    echo "✗ Pangolin 似乎未安装"
fi

