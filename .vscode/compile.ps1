param(
    [string]$File,
    [string]$NoExtname,
    [string]$Extname,
    [string]$Workspace
)

# 颜色常量
$RED = "Red"
$GRE = "Green" 
$BLU = "Blue"
$RST = "Gray"  # Reset color

# 路径定义
$log_path = "$Workspace\.vscode\cache.log"
$bin_path = "$Workspace\bin\$NoExtname.exe"
$inc_path = "$Workspace\inc"
$src_path = $File

function Get-FileHashValue {
    param([string]$FilePath)
    
    if (Test-Path $FilePath) {
        $hash = Get-FileHash -Path $FilePath -Algorithm MD5
        return $hash.Hash
    }
    return $null
}

function Check-Hash {
    if (-not (Test-Path $log_path) -or -not (Test-Path $bin_path)) {
        return $false
    }
    
    $log_content = Get-Content $log_path | Where-Object { $_ -like "*$src_path*" }
    if (-not $log_content) {
        return $false
    }
    
    $log_parts = $log_content -split '\s+'
    $stored_bin_hash = $log_parts[0]
    $stored_src_hash = $log_parts[1]
    
    $current_bin_hash = Get-FileHashValue -FilePath $bin_path
    $current_src_hash = Get-FileHashValue -FilePath $src_path
    
    return ($stored_src_hash -eq $current_src_hash) -and ($stored_bin_hash -eq $current_bin_hash)
}

function Get-Compiler {
    switch ($Extname) {
        ".cpp" { return "g++" }
        ".c" { return "gcc" }
        default {
            Write-Host "[ERR] Unknown file type." -ForegroundColor $RED
            exit 1
        }
    }
}

function Get-Arguments {
    $args = "-D_DEBUG_=1 -W -Wall -ggdb -lm -O0"
    
    switch ($Extname) {
        ".cpp" { $args += " -std=c++23 -lstdc++exp" }
        ".c" { $args += " -std=c23" }
    }
    
    return $args
}

function Write-Hash {
    $current_bin_hash = Get-FileHashValue -FilePath $bin_path
    $current_src_hash = Get-FileHashValue -FilePath $src_path
    
    if (-not (Test-Path $log_path)) {
        New-Item -Path $log_path -Force | Out-Null
    }
    
    $log_content = Get-Content $log_path -ErrorAction SilentlyContinue
    $existing_line = $log_content | Where-Object { $_ -like "*$src_path*" }
    
    $new_line = "$current_bin_hash $current_src_hash $src_path"
    
    if ($existing_line) {
        $new_content = $log_content -replace [regex]::Escape($existing_line), $new_line
        Set-Content -Path $log_path -Value $new_content
    } else {
        Add-Content -Path $log_path -Value $new_line
    }
}

function Main {
    if (Check-Hash) {
        Write-Host "Source has already been built. Debug the binary directly." -ForegroundColor $BLU
        return
    }
    
    $compiler = Get-Compiler
    $arguments = Get-Arguments
    
    # 确保输出目录存在
    $bin_dir = Split-Path $bin_path -Parent
    if (-not (Test-Path $bin_dir)) {
        New-Item -ItemType Directory -Path $bin_dir -Force | Out-Null
    }
    
    # 构建编译命令
    $compileCommand = "$compiler `"$src_path`" -I `"$inc_path`" -o `"$bin_path`" $arguments"
    
    # 执行编译
    Invoke-Expression $compileCommand
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERR] Failed in building. Check the compilation log above for detail." -ForegroundColor $RED
        exit 1
    } else {
        Write-Hash
        Write-Host "Build successfully." -ForegroundColor $GRE
    }
}

# 执行主函数
Main