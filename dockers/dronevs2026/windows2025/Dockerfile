# escape=`
# Windows Server 2025 base image, with .NET Framework 4.8.1.
# Requires a container host running Windows Server 2025 (process isolation),
# or any host with Hyper-V isolation.
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8.1-windowsservercore-ltsc2025
# FROM mcr.microsoft.com/windows/servercore:ltsc2025
# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

WORKDIR C:\

# There will be some local file copies. However, let's move them down in the Dockerfile to avoid
# rebuilding everything.

RUN powershell -Command iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
RUN choco feature disable --name='ignoreInvalidOptionsSwitches'
RUN choco feature enable -n allowGlobalConfirmation

RUN choco install -y visualstudio2026buildtools --parameters  "--add Microsoft.VisualStudio.Component.VC.Llvm.Clang --add Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset --add Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Llvm.Clang --add Microsoft.VisualStudio.Component.VC.CMake.Project"

# Install the current VS2026 toolset plus the final MSVC toolset of every earlier
# Visual Studio, back to VS2017. All of these coexist under the single
# BuildTools installation and are selected per-build with
# "vcvarsall.bat -vcvars_ver=14.x" or b2 toolset=msvc-14.x:
#   VC.14.50.18.0     msvc-14.5  VS2026
#   VC.14.44.17.14    msvc-14.3  VS2022 (final 17.x toolset; b2 calls all VS2022 toolsets 14.3)
#   VC.14.29.16.11    msvc-14.2  VS2019 (final 16.x toolset)
#   VC.v141           msvc-14.1  VS2017 (14.16)
# VS2015 (VC.140 / msvc-14.0) is not included: the VS2026 installer no longer
# carries its payload, and the standalone VS2015 installer fails (MSI 1603) on
# Server Core ltsc2025. msvc-14.0 jobs stay on the cppalliance/dronevs2015 image.
RUN choco install -y visualstudio2026-workload-vctools --parameters "--add Microsoft.VisualStudio.Component.VC.14.50.18.0.x86.x64 --add Microsoft.VisualStudio.Component.VC.14.44.17.14.x86.x64 --add Microsoft.VisualStudio.Component.VC.14.29.16.11.x86.x64 --add Microsoft.VisualStudio.Component.VC.v141.x86.x64"

# At least in the past, cmake was not found in the path without extra flags:
RUN choco install -y cmake.install --installargs '"ADD_CMAKE_TO_PATH=System"'

# Register the legacy MSVC toolsets with b2 (Boost.Build). b2 only auto-detects a
# toolset inside its own generation's Visual Studio directory, so the toolsets
# installed above as components of VS2026 BuildTools are invisible to it. The
# script writes vcvarsall wrappers to C:\vcvars and registers each toolset in
# C:\Windows\site-config.jam, which b2 loads on every run, independently of
# user-config.jam (which CI jobs commonly overwrite). See README.md.
COPY generate-b2-config.ps1 'C:\\tmp\\generate-b2-config.ps1'
RUN powershell -NoProfile -ExecutionPolicy Bypass -File C:\tmp\generate-b2-config.ps1

# Smoke-test every registered toolset: initialize its environment and verify the
# expected compiler version is selected. Fails the image build otherwise.
RUN call C:\vcvars\v141.bat amd64 && cl 2>&1 | findstr /C:"Version 19.16"
RUN call C:\vcvars\v142.bat amd64 && cl 2>&1 | findstr /C:"Version 19.29"
RUN call C:\vcvars\v143.bat amd64 && cl 2>&1 | findstr /C:"Version 19.4"
RUN call C:\vcvars\v145.bat amd64 && cl 2>&1 | findstr /C:"Version 19.5"

RUN powershell New-Item -Path 'c:\\tmp' -ItemType Directory -Force
COPY packages.prebuild.versions.config 'C:\\tmp\\packages.prebuild.versions.config'
COPY packages.prebuild.noversions.config 'C:\\tmp\\packages.prebuild.noversions.config'

RUN choco install -y C:\\tmp\\packages.prebuild.noversions.config

RUN mklink /D "Git" "C:\Program Files\Git"

RUN choco export --output-file-path='c:\\tmp\\packages.postbuild.versions.config' --include-version-numbers
RUN choco export --output-file-path='c:\\tmp\\packages.postbuild.noversions.config'
RUN type c:\\tmp\\packages.postbuild.versions.config
RUN type c:\\tmp\\packages.postbuild.noversions.config
RUN echo __done__

RUN setx path "C:\Git\usr\bin\;%path%"
ENTRYPOINT ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
