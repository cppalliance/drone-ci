# Generates C:\vcvars wrapper scripts and C:\Windows\site-config.jam so that
# b2 (Boost.Build) can use the legacy MSVC toolsets installed as components of
# the VS2026 BuildTools.
#
# Background: b2 only auto-detects an MSVC toolset inside its own generation's
# Visual Studio directory (e.g. msvc-14.1 under "...\Microsoft Visual Studio\2017\..."),
# and it never passes vcvarsall's -vcvars_ver switch. Toolsets that live inside
# the VS2026 ("18") BuildTools are therefore invisible to it. The wrapper
# scripts pin the toolset via -vcvars_ver, and site-config.jam registers each
# toolset explicitly. b2 loads site-config.jam from %SystemRoot% on every run,
# independently of user-config.jam, which CI jobs commonly overwrite.

$ErrorActionPreference = 'Stop'

$vsRoot = 'C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools'
$vcvarsall = Join-Path $vsRoot 'VC\Auxiliary\Build\vcvarsall.bat'
if (-not (Test-Path $vcvarsall)) { throw "vcvarsall.bat not found: $vcvarsall" }
$msvcDir = Join-Path $vsRoot 'VC\Tools\MSVC'

New-Item -ItemType Directory -Force -Path 'C:\vcvars' | Out-Null

$lines = @()

# b2 toolset version -> toolset directory pattern under VC\Tools\MSVC.
# Note b2 has no "14.4": all VS2022 toolsets are named msvc-14.3 there.
$map = [ordered]@{
    '14.5' = '14.5*'
    '14.3' = '14.4*'
    '14.2' = '14.29.*'
    '14.1' = '14.16.*'
}

foreach ($b2ver in $map.Keys) {
    $dir = Get-ChildItem -Directory -Path $msvcDir -Filter $map[$b2ver] |
        Sort-Object Name | Select-Object -Last 1
    if (-not $dir) { throw ('No MSVC toolset matching {0} under {1}' -f $map[$b2ver], $msvcDir) }
    $cl = Join-Path $dir.FullName 'bin\Hostx64\x64\cl.exe'
    if (-not (Test-Path $cl)) { throw "cl.exe not found: $cl" }
    # -vcvars_ver takes the two-component toolset version, e.g. 14.16
    $tsver = $dir.Name.Split('.')[0,1] -join '.'
    $wrapper = 'C:\vcvars\v{0}.bat' -f ($b2ver -replace '\.','')
    ('@call "{0}" %* -vcvars_ver={1}' -f $vcvarsall, $tsver) |
        Set-Content -Path $wrapper -Encoding ascii
    $lines += ('using msvc : {0} : "{1}" : <setup>"{2}" ;' -f
        $b2ver, ($cl -replace '\\','/'), ($wrapper -replace '\\','/'))
}

# VS2015 (v140 / msvc-14.0) is deliberately NOT provided by this image.
# Determined empirically (2026-08): the VS2026 installer no longer carries the
# VC.140 component payload ("setup.exe modify --add Microsoft.VisualStudio.Component.VC.140"
# installs nothing), and the standalone VS2015 build tools installer
# (choco visualcpp-build-tools 14.0.25420.1) fails with MSI error 1603 on
# Server Core ltsc2025. msvc-14.0 jobs should continue to use the
# cppalliance/dronevs2015 image (ltsc2019 base, Hyper-V isolation on 2025 hosts).

Set-Content -Path 'C:\Windows\site-config.jam' -Value $lines -Encoding ascii

Write-Host '=== C:\Windows\site-config.jam ==='
Get-Content 'C:\Windows\site-config.jam' | Write-Host
Write-Host '=== C:\vcvars wrappers ==='
Get-ChildItem 'C:\vcvars' -Filter *.bat | ForEach-Object {
    Write-Host ('--- {0}' -f $_.FullName)
    Get-Content $_.FullName | Write-Host
}
