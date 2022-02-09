# escape=`

# Use a specific tagged image. Tags can be changed, though that is unlikely for most images.
# You could also use the immutable tag @sha256:324e9ab7262331ebb16a4100d0fb1cfb804395a766e3bb1806c62989d1fc1326
ARG FROM_IMAGE=mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019
FROM ${FROM_IMAGE}

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# Copy our Install script.
# COPY Install.cmd C:\TEMP\

# Download collect.exe in case of an install failure.
# ADD https://aka.ms/vscollect.exe C:\TEMP\collect.exe

# Use the latest release channel. For more control, specify the location of an internal layout.
ARG CHANNEL_URL=https://aka.ms/vs/17/preview/channel
ADD ${CHANNEL_URL} C:\TEMP\VisualStudio.chman

RUN `
    # Download the Build Tools bootstrapper.
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/pre/vs_buildtools.exe `
    `
    # Install Build Tools with the Microsoft.VisualStudio.Workload.AzureBuildTools workload, excluding workloads and components with known issues.
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache modify `
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" `
        --channelUri C:\TEMP\VisualStudio.chman `
        --installChannelUri C:\TEMP\VisualStudio.chman `
        --add Microsoft.VisualStudio.Workload.MSBuildTools `
        --add Microsoft.VisualStudio.Workload.VCTools `
        --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
        --remove Microsoft.VisualStudio.Component.Windows81SDK)    `
    `
    # Cleanup
    && del /q vs_buildtools.exe

WORKDIR C:\
RUN powershell -Command iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

# Earlier list from https://docs.travis-ci.com/user/reference/windows/
# a list of the resulting packages, automatically installed during buildtools:
# RUN choco install -y chocolatey --version 0.11.3
# RUN choco install -y chocolatey-dotnetfx.extension --version 1.0.1
# RUN choco install -y chocolatey-visualstudio.extension --version 1.10.0
# RUN choco install -y KB2919355 --version 1.0.20160915
# RUN choco install -y KB2919442 --version 1.0.20160915
# RUN choco install -y visualstudio-installer --version 2.0.2

# This is already the dotnet image. Let's not install "dotnet"
# RUN choco install -y dotnetfx

RUN choco install -y 7zip.install --version 19.0
# cmake not in path without extra flag:
RUN choco install -y cmake.install --installargs '"ADD_CMAKE_TO_PATH=System"'
RUN choco install -y curl --version 7.80.0
RUN choco install -y git.install --version 2.34.0
RUN choco install -y hashdeep --version 4.4
RUN choco install -y jq --version 1.6
RUN choco install -y python --version 3.10.0
RUN choco install -y rsync --version 6.2.3
RUN choco install -y ruby --version 3.0.2.1
RUN choco install -y Wget --version 1.21.2
RUN choco install -y winscp --version 5.19.4
RUN choco install -y winscp.install --version 5.19.4
RUN choco install -y vim --version 8.2.3607

# can take 10 minutes:
RUN choco install -y windows-sdk-10.1

# Another resulting package
# RUN choco install -y chocolatey-core.extension --version 1.3.5.1

RUN mklink /D "Git" "C:\Program Files\Git"
RUN setx path "C:\Git\usr\bin\;%path%"

# Define the entry point for the Docker container.
# This entry point starts the developer command prompt and launches the PowerShell shell.
ENTRYPOINT ["C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
