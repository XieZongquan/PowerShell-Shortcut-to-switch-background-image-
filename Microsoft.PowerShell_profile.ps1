# 设置背景图片文件夹路径/Set the path of the background image folder
$global:BgFolder = "Your/image/path"

$global:BgImages = @(Get-ChildItem -Path $global:BgFolder -Include *.jpg,*.jpeg,*.png -Recurse | Select-Object -ExpandProperty FullName)

# 启动时随机选一张图片/Select a random image at startup
$global:BgIndex = Get-Random -Minimum 0 -Maximum $global:BgImages.Count

# 设置透明度档位/Set the opacity level
$global:OpacityLevels = @(0.0, 0.2, 0.4, 0.6, 0.8, 1.0)
$global:OpacityIndex = 0

#-------------------------------------------------------------------------------------#
# 如果不需要自动调整窗口大小，删除这部分代码/If you don't need the window size to be automatically adjusted, delete this part of code
# 加载依赖/Loading dependencies
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# 加载 Win32 API/Load Win32 API
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinApi {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int x, int y, int width, int height, bool repaint);

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
}

[StructLayout(LayoutKind.Sequential)]
public struct RECT {
    public int Left, Top, Right, Bottom;
}
"@

# 根据图片比例调整窗口大小/Adjust the window size according to the image ratio
function Set-WindowToImageRatio {
    param([string]$ImagePath)

    try {
        $img = [System.Drawing.Image]::FromFile($ImagePath)
        $imgWidth = $img.Width
        $imgHeight = $img.Height
        $img.Dispose()
    } catch {
        Write-Host "无法读取图片尺寸：$ImagePath" -ForegroundColor Red
        return
    }

    $ratio = $imgWidth / $imgHeight

    $hwnd = [WinApi]::GetForegroundWindow()
    $rect = New-Object RECT
    [WinApi]::GetWindowRect($hwnd, [ref]$rect) | Out-Null

    $currentX = $rect.Left
    $currentY = $rect.Top

    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
    $maxWidth = $screen.Width
    $maxHeight = $screen.Height
	
# 此处将0.8修改为你想要的比例/Here, replace 0.8 with the proportion you desire.
    if ($ratio -ge 1) {
        $newWidth = [int]($maxWidth * 0.8)
        $newHeight = [int]($newWidth / $ratio)
    } else {
        $newHeight = [int]($maxHeight * 0.8)
        $newWidth = [int]($newHeight * $ratio)
    }

    $newWidth = [Math]::Min($newWidth, $maxWidth)
    $newHeight = [Math]::Min($newHeight, $maxHeight)

    [WinApi]::MoveWindow($hwnd, $currentX, $currentY, $newWidth, $newHeight, $true) | Out-Null
    Write-Host "[Window] -> ${newWidth} x ${newHeight} (ratio $([math]::Round($ratio, 2)))" -ForegroundColor Magenta
}
#-------------------------------------------------------------------------------------#


# 修改Windows Terminal settings.json/edit Windows Terminal settings.json
function Update-TerminalBackground {
    param(
        [string]$Image,
        [double]$Opacity = -1
    )

    $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

    if (-not (Test-Path $settingsPath)) {
        Write-Host "Cannot find the Windows Terminal configuration file" -ForegroundColor Red
        return
    }

    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
    $prof = $settings.profiles.defaults

    if ($Image) {
        $prof | Add-Member -NotePropertyName "backgroundImage" -NotePropertyValue $Image -Force
    }

    if ($Opacity -ge 0) {
        $prof | Add-Member -NotePropertyName "backgroundImageOpacity" -NotePropertyValue $Opacity -Force
    }

    $settings | ConvertTo-Json -Depth 20 | Set-Content $settingsPath -Encoding UTF8
}

# Alt+B 切换背景图片并同步调整窗口比例/Press "Alt + B" to switch the background image and simultaneously adjust the window ratio.
Set-PSReadLineKeyHandler -Key "Alt+b" -ScriptBlock {
    $global:BgIndex = ($global:BgIndex + 1) % $global:BgImages.Count
    $img = $global:BgImages[$global:BgIndex]
    # Write-Host "`r[Background] -> $img" -ForegroundColor Cyan
    Update-TerminalBackground -Image $img
    Set-WindowToImageRatio -ImagePath $img
    # [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# Alt+O 切换透明度/Press Alt + O to switch opacity level.
Set-PSReadLineKeyHandler -Key "Alt+o" -ScriptBlock {
    $global:OpacityIndex = ($global:OpacityIndex + 1) % $global:OpacityLevels.Count
    $opacity = $global:OpacityLevels[$global:OpacityIndex]
    Write-Host "`r[Opacity] -> $opacity" -ForegroundColor Yellow
    Update-TerminalBackground -Opacity $opacity
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# 启动时应用随机图片并调整窗口/When starting, display random images and adjust the window.
if ($global:BgImages.Count -gt 0) {
    $initImg = $global:BgImages[$global:BgIndex]
    Update-TerminalBackground -Image $initImg
    
    #-------------------------------------------------------------------------------------#
    #如果你不需要自动调整窗口大小，删除以下两行代码/If you don't need the window size to be automatically adjusted, delete the following two lines of code
    Start-Sleep -Milliseconds 300
    Set-WindowToImageRatio -ImagePath $initImg 
    #-------------------------------------------------------------------------------------#
} else {
    Write-Host "The background image folder is empty or the path is incorrect:$global:BgFolder" -ForegroundColor Red
}

