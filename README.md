# PowerShell Background Image Shortcut Switch

[中文](#powershell背景图片快捷切换) | [English](#english Translated from chinese by chatGPT)

---

## PowerShell背景图片快捷切换

通过快捷键在 Windows Terminal 中快速切换背景图片、透明度，并根据图片比例自动调整窗口大小。

### 功能

- 启动时从指定文件夹中随机选取一张背景图片
- Alt+B 顺序切换背景图片
- Alt+O 顺序切换背景透明度（可在文件中自行设置挡位）
- 切换图片时自动按图片宽高比调整窗口大小

### 环境要求

- Windows 10 / 11
- [Windows Terminal](https://aka.ms/terminal)
- PowerShell 7+

### 使用方法

**第一步：** 准备背景图片，放入同一个文件夹，支持 jpg、jpeg、png、bmp格式。

**第二步：** 打开 PowerShell 配置文件：

```powershell
notepad $PROFILE
```

**第三步：** 将代码粘贴进配置文件，并将 `$global:BgFolder` 修改为你自己的图片文件夹路径。

**第四步：** 保存文件后重新加载配置：

```powershell
. $PROFILE
```

### 快捷键

| 快捷键 | 功能 |
|--------|------|
| Alt+B  | 顺序切换背景图片 |
| Alt+O  | 顺序切换透明度 |

### 注意事项

- 此脚本依赖 Windows Terminal，不支持其他终端模拟器
- Windows Terminal 的 settings.json 路径因版本不同可能有所差异，Preview 版路径中的包名略有不同，可通过以下命令确认：
  ```powershell
  Get-ChildItem "$env:LOCALAPPDATA\Packages" | Where-Object { $_.Name -like "*Terminal*" }
  ```
- 自动按图片宽高比调整窗口大小的功能实现需要编译 C# 代码，加载会略慢，同时windows会给出提示性输出;若不需要可删除相关代码。
- 窗口大小以屏幕可用区域的80%为基准计算，可编辑`Set-WindowToImageRatio`函数调整该比例。

---

## English(Translated from chinese by chatGPT)

Quickly switch background images and opacity in Windows Terminal using keyboard shortcuts, with automatic window resizing to match each image's aspect ratio.

### Features

- Randomly selects a background image from a specified folder on startup
- Alt+B cycles through background images in order
- Alt+O cycles through opacity levels (0.3 / 0.5 / 0.7 / 1.0)
- Automatically resizes the terminal window to match the aspect ratio of the current image

### Requirements

- Windows 10 / 11
- [Windows Terminal](https://aka.ms/terminal)
- PowerShell 7+

### Setup

**Step 1:** Prepare your background images in a single folder. Supported formats: jpg, jpeg, png, bmp, gif.

**Step 2:** Open your PowerShell profile:

```powershell
notepad $PROFILE
```

**Step 3:** Paste the full code below into the profile file, and update `$global:BgFolder` to point to your image folder.

**Step 4:** Save the file and reload the profile:

```powershell
. $PROFILE
```

### Shortcuts

| Shortcut | Action |
|----------|--------|
| Alt+B    | Cycle to the next background image |
| Alt+O    | Cycle to the next opacity level |

### Notes

- This script requires Windows Terminal and does not work with other terminal emulators.
- The path to settings.json may differ slightly for the Preview build of Windows Terminal. Run the following to locate it:
  ```powershell
  Get-ChildItem "$env:LOCALAPPDATA\Packages" | Where-Object { $_.Name -like "*Terminal*" }
  ```
- The feature to automatically resize the window according to the image aspect ratio requires compiling C# code, which may result in slightly slower loading and display of prompt messages from Windows. If not needed, you can remove the relevant code.
- The window size is calculated as 80% of the available screen area. You can adjust this by editing the `Set-WindowToImageRatio` function.
