
## VS2026

## Administrator notes  

Run `.\build.ps1` to build the image. Then `docker push` to upload.  

When upgrading from VS2022 to VS2026, or between any versions, it's necessary to test chocolatey with no versions specified
to dynamically discover the latest package versions. Then, there might be a manual process to record those versions
in the Dockerfile. 
With that in mind, the purpose of the various files such as `packages.prebuild.noversions.config`, etc. is to automate
this process, at least to some extent. Adjust the "noversion" file. Run `docker build`. Copy the resulting output from 
the build process, both `noversion` and `version`, for future builds.  

A new strategy in 2025 is to treat the drone images differently from github actions runners. 
In the past there may have been some intention to include many versions of MSVC in one drone image, but it ought to be
feasible instead to focus each image on a particular MSVC version. If a C++ test should run on another MSVC version, direct it 
to use another docker image.

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
