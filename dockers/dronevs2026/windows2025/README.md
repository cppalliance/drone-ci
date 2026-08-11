
## VS2026 on Windows Server 2025

Based on `windowsservercore-ltsc2025`. Runs with process isolation on Windows Server 2025
container hosts, or with Hyper-V isolation (`--isolation=hyperv`) on any host.
The older ltsc2019-based image is in `../windows2019` and remains tagged `cppalliance/dronevs2026:1`;
this one builds as `cppalliance/dronevs2026:2`.

In addition to the current VS2026 toolset, this image installs the final MSVC toolset of every
earlier Visual Studio going back to VS2015, as components of the single VS2026 BuildTools
installation. Select a toolset per build, e.g. `b2 toolset=msvc-14.0` (VS2015),
`msvc-14.1` (VS2017), `msvc-14.2` (VS2019), `msvc-14.4` (VS2022), `msvc-14.5` (VS2026),
or `vcvarsall.bat -vcvars_ver=14.29` and similar.

## Administrator notes  

Run `.\build.ps1` to build the image. Then `docker push` to upload.  

Building an image of this size requires the docker daemon storage size to be raised, in
`C:\ProgramData\docker\config\daemon.json` on the build host:
```
{
  "storage-opts": ["size=127GB"]
}
```

When upgrading between versions, it's necessary to test chocolatey with no versions specified
to dynamically discover the latest package versions. Then, there might be a manual process to record those versions
in the Dockerfile. 
With that in mind, the purpose of the various files such as `packages.prebuild.noversions.config`, etc. is to automate
this process, at least to some extent. Adjust the "noversion" file. Run `docker build`. Copy the resulting output from 
the build process, both `noversion` and `version`, for future builds.  

The package versions were carried over unchanged from the windows2019 image for reproducibility.
Items to watch on the first build against ltsc2025:
- The `KB*` packages are Windows 8.1-era hotfix shims; on Server 2025 they should detect
  non-applicability and skip. If one hard-fails, remove it from the config files.
- `dotnetfx` 4.8 should skip, since ltsc2025 already ships .NET Framework 4.8.1.

The following packages were installed "automatically" as dependencies:   
```
  <package id="KB2919355" />
  <package id="KB2919442" />
  <package id="KB2999226" />
  <package id="KB3033929" />
  <package id="KB3035131" />
  <package id="KB3118401" />
  <package id="python3" />
  <package id="python314" />
  <package id="vcredist140" />
  <package id="vcredist2015" />
  <package id="visualstudio-installer" />
```
