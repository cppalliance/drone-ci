
## VS2026 on Windows Server 2025

Based on `windowsservercore-ltsc2025`. Runs with process isolation on Windows Server 2025
container hosts, or with Hyper-V isolation (`--isolation=hyperv`) on any host.
The older ltsc2019-based image is in `../windows2019` and remains tagged `cppalliance/dronevs2026:1`;
this one builds as `cppalliance/dronevs2026:2`.

In addition to the current VS2026 toolset, this image installs the final MSVC toolset of every
earlier Visual Studio going back to VS2017, as components of the single VS2026 BuildTools
installation. Select a toolset per build: `msvc-14.1` (VS2017), `msvc-14.2` (VS2019),
`msvc-14.3` (VS2022; b2 has no "14.4"), `msvc-14.5` (VS2026), or
`vcvarsall.bat -vcvars_ver=14.29` and similar.

VS2015 (`msvc-14.0`) is deliberately not included. Determined empirically (2026-08): the
VS2026 installer no longer carries the VC.140 component payload, and the standalone VS2015
build tools installer fails with MSI error 1603 on Server Core ltsc2025. msvc-14.0 jobs
should continue to use the `cppalliance/dronevs2015` image (ltsc2019 base), which runs on
Windows Server 2025 hosts under Hyper-V isolation.

## b2 toolset registration (site-config.jam)

b2 only auto-detects an MSVC toolset inside its own generation's Visual Studio directory
(e.g. msvc-14.1 under `...\Microsoft Visual Studio\2017\...`), and it never passes
vcvarsall's `-vcvars_ver` switch. Toolsets installed as components of VS2026 BuildTools are
therefore invisible to it: `b2 toolset=msvc-14.1` prints "Did not find command for MSVC
toolset" and, worse, the build can still exit 0 without compiling anything.

`generate-b2-config.ps1` runs at image build time and writes:
- `C:\vcvars\v140.bat` ... `v145.bat`: one-line wrappers that initialize the environment for
  a pinned toolset (via `-vcvars_ver`, or the classic VS2015 vcvarsall for v140).
- `C:\Windows\site-config.jam`: registers each toolset with b2, e.g.
  `using msvc : 14.1 : "<path to cl.exe>" : <setup>"C:/vcvars/v141.bat" ;`

site-config.jam is used (rather than user-config.jam) because b2 loads it from
`%SystemRoot%` on every invocation, independently of user-config.jam, which CI jobs
commonly overwrite (`echo ... > %USERPROFILE%\user-config.jam`). No changes to
.drone.star / .drone.jsonnet / boost-ci are needed. A job can opt out with b2's
`--ignore-site-config` flag. A job that itself runs `using msvc : <version> : ... ;` with
different parameters will fail loudly with "duplicate initialization"; such jobs should
either use the image's registration or opt out.

The Dockerfile smoke-tests every wrapper and expected cl.exe version at build time.

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
