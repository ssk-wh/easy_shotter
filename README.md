# EasyShotter

跨平台截图工具，类似 Snipaste，支持自动识别窗口区域和控件。

## 功能

- 自动识别窗口区域（鼠标悬停高亮）
- 自动识别窗口内控件（按钮、输入框等）
- 手动框选任意区域，支持拖拽调整
- 复制截图到剪贴板
- 保存截图到文件（PNG/JPG/BMP）
- 系统托盘常驻，单击即截图
- 全局快捷键 `Ctrl+Shift+A`
- 多显示器支持
- 放大镜预览 + 像素颜色拾取

## 技术栈

- C++17 / Qt 5.15.2 / CMake 3.16+
- Windows: Win32 API + UI Automation
- Linux: X11/XCB + AT-SPI2（待完善）

## 构建

```bash
cmake -B build -DCMAKE_PREFIX_PATH="<Qt5安装路径>"
cmake --build build --config Release
```

## TODO

### P0 - 核心功能完善

- [ ] Linux 平台实现（当前为 stub）
  - [ ] XCB 窗口枚举与层叠顺序获取
  - [ ] AT-SPI2 控件识别
  - [ ] X11 全局热键注册
  - [ ] XCB 全屏截图
- [ ] 截图保存时弹出文件选择对话框（当前仅保存到桌面）
- [ ] 全局快捷键可自定义（当前硬编码 Ctrl+Shift+A）
- [ ] 高 DPI / 缩放感知（Per-Monitor DPI V2）
- [ ] 多显示器不同缩放比例适配
- [ ] Wayland 支持（当前仅 X11）

### P1 - 标注功能（架构已预留 Tool+Item 模式）

- [ ] 画笔自由绘制（PenTool + PenStrokeItem）
- [ ] 马赛克 / 高斯模糊（MosaicTool + MosaicItem）
- [ ] 矩形 / 椭圆标注（RectangleTool + RectangleItem）
- [ ] 箭头标注（ArrowTool + ArrowItem）
- [ ] 文字标注（TextTool + TextItem）
- [ ] 撤销 / 重做（快照式 UndoStack 已设计）
- [ ] 标注工具栏按钮启用（当前 UI 已预留但禁用）

### P2 - 高级功能

- [ ] 截图钉在桌面（PinWindow，架构已设计）
- [ ] 截图历史记录
- [ ] 设置界面（快捷键配置、保存路径、图片格式等）
- [ ] 启动时自动运行（注册表 / autostart）
- [ ] 延时截图
- [ ] 滚动截图（长页面拼接）
- [ ] 颜色拾取器（独立模式，点击复制色值）
- [ ] 多语言支持（i18n）

### 已知问题

- [ ] 部分 Electron/Chrome 应用控件识别需用户手动开启无障碍
- [ ] 控件递归遍历深度限制为 8 层，极深嵌套控件可能遗漏
- [ ] `getWindowControls` 首次加载某窗口控件时可能有短暂延迟
