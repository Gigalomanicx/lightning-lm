# yaml-cpp 多版本管理说明

## 为什么需要从源码编译？

Ubuntu 20.04 系统自带的 yaml-cpp 0.6.2 与代码期望的版本存在 ABI 不兼容问题：
- 系统版本：`convert_to_map(std::shared_ptr<...>)` （按值传递）
- 代码需要：`convert_to_map(std::shared_ptr<...> const&)` （按引用传递）

## 安装方式

### 方案 1：用户目录安装（推荐，不影响系统）

```bash
cd src/lightning-lm/scripts
./build_yaml_cpp.sh
```

安装位置：`~/.local/yaml-cpp-0.7.0/`

**优点：**
- ✅ 不需要 sudo 权限
- ✅ 不会影响系统库
- ✅ 可以安装多个版本并存
- ✅ 卸载简单（删除目录即可）

### 方案 2：系统目录安装（需要 sudo）

如果必须安装到系统目录，修改脚本中的 `INSTALL_PREFIX` 为 `/usr/local/yaml-cpp`

**注意：**
- ⚠️ 需要 sudo 权限
- ⚠️ 可能与系统包管理器安装的版本冲突
- ⚠️ 卸载需要手动清理

## 多版本管理

### 如何管理多个版本？

1. **不同版本安装到不同目录**
   - `~/.local/yaml-cpp-0.7.0/`
   - `~/.local/yaml-cpp-0.8.0/`
   - 等等

2. **通过环境变量选择版本**
   ```bash
   # 使用 0.7.0 版本
   export CMAKE_PREFIX_PATH="$HOME/.local/yaml-cpp-0.7.0:$CMAKE_PREFIX_PATH"
   export LD_LIBRARY_PATH="$HOME/.local/yaml-cpp-0.7.0/lib:$LD_LIBRARY_PATH"
   
   # 切换到 0.8.0 版本
   export CMAKE_PREFIX_PATH="$HOME/.local/yaml-cpp-0.8.0:$CMAKE_PREFIX_PATH"
   export LD_LIBRARY_PATH="$HOME/.local/yaml-cpp-0.8.0/lib:$LD_LIBRARY_PATH"
   ```

3. **通过 CMake 参数指定（推荐）**
   ```bash
   colcon build --cmake-args \
     -Dyaml-cpp_DIR="$HOME/.local/yaml-cpp-0.7.0/lib/cmake/yaml-cpp"
   ```

## 版本查找优先级

CMake 配置会自动按以下顺序查找：

1. **用户编译版本** (`~/.local/yaml-cpp-*/`)
2. **ROS2 Foxy vendor** (`/opt/ros/foxy/opt/yaml_cpp_vendor/`)
3. **系统版本** (`/usr/lib/`)

## 验证安装

```bash
# 检查库文件
ls -la ~/.local/yaml-cpp-0.7.0/lib/

# 检查 CMake 配置
ls -la ~/.local/yaml-cpp-0.7.0/lib/cmake/yaml-cpp/

# 测试链接
ldd your_executable | grep yaml
```

## 卸载

```bash
# 删除用户安装的版本
rm -rf ~/.local/yaml-cpp-0.7.0/

# 从环境变量中移除（如果已添加到 ~/.bashrc）
# 编辑 ~/.bashrc 删除相关行
```

## 常见问题

### Q: 安装多个版本会冲突吗？
A: 不会，如果安装到用户目录。CMake 会根据 `CMAKE_PREFIX_PATH` 或 `yaml-cpp_DIR` 选择版本。

### Q: 会影响其他 ROS2 包吗？
A: 不会。其他包会继续使用它们自己的 yaml-cpp 版本（通过 ROS2 的依赖管理）。

### Q: 如何确认使用的是哪个版本？
A: 编译时查看 CMake 输出，会显示 "Using user-compiled yaml-cpp" 或 "Using system yaml-cpp"。

