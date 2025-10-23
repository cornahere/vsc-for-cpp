# vsc-for-cpp

为 Visual Studio Code 打造的单 C/C++ 文件工作区，支持 Windows / Linux。  
若未严格遵循环境要求，使用前确保 `.vscode/c_cpp_properties.json` 已经配置正确。  

## 环境要求
### Windows

- (Windows MinGW) 将 MinGW-w64 15.2.1 安装到 `C:\Program Files\mingw64`，并加入到环境变量。
- (Windows MSVC) 安装 Visual Studio 2022 Community 的 MSVC 组件。

### Linux
- 安装 GCC 15.2.1 与 GDB。
- 确保 sha256sum 可用。

## 结构说明

源代码请置于 `src` 文件夹中。  
公共头文件请置于 `inc` 文件夹中。  
源代码编译结果将会输出到 `bin` 文件夹中。Linux 下编译结果默认带 .run 后缀名。  
