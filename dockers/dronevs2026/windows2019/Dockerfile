# escape=`
# Use the latest Windows Server Core image with .NET Framework 4.8.
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019
# FROM mcr.microsoft.com/windows/servercore:ltsc2019
# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

WORKDIR C:\

# There will be some local file copies. However, let's move them down in the Dockerfile to avoid
# rebuilding everything.

RUN powershell -Command iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
RUN choco feature disable --name='ignoreInvalidOptionsSwitches'
RUN choco feature enable -n allowGlobalConfirmation

RUN choco install -y visualstudio2026buildtools --parameters  "--add Microsoft.VisualStudio.Component.VC.Llvm.Clang --add Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset --add Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Llvm.Clang --add Microsoft.VisualStudio.Component.VC.CMake.Project"
RUN choco install -y visualstudio2026-workload-vctools --parameters "--add Microsoft.VisualStudio.Component.VC.14.50.18.0.x86.x64"
# At least in the past, cmake was not found in the path without extra flags:
RUN choco install -y cmake.install --installargs '"ADD_CMAKE_TO_PATH=System"'

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
