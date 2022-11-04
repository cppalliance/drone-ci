
## Drone Documentation

[https://docs.drone.io](https://docs.drone.io/)

More specific details about this implementation -

In the .drone.star file, one of the parameters for a job is "image".  This could be any docker image, however in practice it should be one of the following:  
  
cppalliance/droneubuntu1204:1  
cppalliance/droneubuntu1404:1  
cppalliance/droneubuntu1604:1  
cppalliance/droneubuntu1804:1  
cppalliance/droneubuntu2004:1  
cppalliance/droneubuntu2204:1  
cppalliance/dronevs2017  
cppalliance/dronevs2019:2  
cppalliance/dronevs2022
  
These images have been preinstalled with most of the packages found on a travis-ci image.  

For OSX builds, specify the xcode version instead of the image. Recent versions of xcode from 6.4 to 14.1 are available. Include xcode_version in the job definition in .drone.star, such as `xcode_version="10.3"`.  

List of available versions:

```
6.4 7 7.1 7.2 7.3 8 8.1 8.2 8.3 8.3.2 8.3.3 9 9.1 9.2 9.3 9.4 9.4.1
10 10.1 10.2 10.3 11 11.1 11.2 11.2.1 11.3 11.4 11.5 11.6 11.7 12 12.1 12.2 12.3 12.4
12.5 12.5.1 13.0 13.1 13.2 13.2.1 13.3 13.3.1 13.4 13.4.1 14.0 14.1
```

FreeBSD uses the setting `freebsd_version` instead of `image`, and defaults to `freebsd_version="13.1"` which is the version being hosted currently. Here are examples of FreeBSD jobs. Notice the linkflags used with gcc:  

```
  freebsd_cxx("gcc 11 freebsd", "g++-11", buildtype="boost", buildscript="drone", freebsd_version="13.1", environment={'B2_TOOLSET': 'gcc-11', 'B2_CXXSTD': '17,20', 'B2_LINKFLAGS': '-Wl,-rpath=/usr/local/lib/gcc11'}, globalenv=globalenv),
  freebsd_cxx("clang 14 freebsd", "clang++-14", buildtype="boost", buildscript="drone", freebsd_version="13.1", environment={'B2_TOOLSET': 'clang-14', 'B2_CXXSTD': '17,20'}, globalenv=globalenv),
```

Full list of compilers on FreeBSD:  
```
g++-8 g++-9 g++-10 g++-11  
clang++-10 clang++-11 clang++-12 clang++-13 clang++-14 clang++-15  
```

If you need a package installed on MacOS or FreeBSD, please open an issue.  

### linux_cxx function

To add more linux-based jobs, add instances of of linux_cxx, following the example in .drone.star. 

Here is a review of each argument to the function:

name - The name field will be displayed for each job in the Drone UI (drone.cpp.al). You are encouraged to adjust the name to be more descriptive. When the first batch of .drone.star files was created using an automated script, the name was based on the environment variables in .travis.yml. The original .travis.yml file doesn't include a name, so it had to be invented. The script truncates the name at around 50 characters, since a long name will not be displayed on the web page.

cxx - This is the CXX environment variable.

cxxflags - The CXXFLAGS environment variable. For both cxx and cxxflags, you may set them as function args, or as environment variables in the "environment" section later.  

packages - a list of apt packages to install.

sources - a list of apt sources to install.

The job fields "llvm_os" and "llvm_ver" are used to install the correct version of LLVM by [linux-cxx-install.sh](https://github.com/boostorg/boost-ci/blob/master/ci/drone/linux-cxx-install.sh).  

llvm_os - the Ubuntu descriptive name such as "xenial" or "bionic".  

llvm_ver - the version such as "5.0".  

arch - the platform architecture, usually "amd64"

image - the docker image to run the build. See discussion above. 

buildtype - Originally, buildtype referred to which script in the .drone folder would be called. The most common script is named "boost.sh", and for a job to refer to this script set the buildtype to "boost". Other less common scripts were labelled with a sha hash, such as "81e7b2095f-2ddd7570b8.sh". Set buildtype to match, such as "81e7b2095f-2ddd7570b8". It is recommended to changes these hashes to something more meanful, such as "valgrind" or "docs-script".  If the buildscript variable is set (see next variable), then the buildtypes are all consolidated inside one buildscript instead of being separate files. Within the one buildscript, the buildtypes are conditionally called.  

buildscript - Newer versions of the drone files have a variable called buildscript. If buildscript is present, it will be the script called. Usually, this will be set to "drone", and so the script is ".drone/drone.sh". In that file, buildtypes are "if" conditional sections.  

```
if [ "$DRONE_JOB_BUILDTYPE" == "{{ buildtype }}" ]; then .... "
```

environment - a dictionary of environment variables.  

globalenv - a dictionary of environment variables for all jobs. Usually globalenv=globalenv , and then set globalenv at the top of the file.  

privileged - set privileged=True if the Drone job needs to run in a privileged Docker container. (usually not the case)  

## Multiarch

In order to test on arm64 or s390x platforms, specify one of these images  

cppalliance/droneubuntu1204:multiarch  
cppalliance/droneubuntu1404:multiarch  
cppalliance/droneubuntu1604:multiarch  
cppalliance/droneubuntu1804:multiarch  
cppalliance/droneubuntu2004:multiarch  
cppalliance/droneubuntu2204:multiarch  

Include the parameter arch="arm64" or arch="s390x" in the job spec.

### Why is there a dependency on the https://github.com/boostorg/boost-ci repository?  

The .drone.star file includes functions.star from https://github.com/boostorg/boost-ci/blob/master/ci/drone/functions.star . Most reusable drone code was removed from the .drone.star files and migrated to the https://github.com/boostorg/boost-ci/blob/master/ci/drone folder to facilitate better maintainability and manageability.  A fix can be done in one place, in boost-ci, instead of rolling out two hundred individual pull requests.   

Although not recommended, here are the steps to optionally remove that dependency:  

copy the contents of functions.star directly into your .drone.star file  
copy the .sh shell scripts to your local repo's .drone directory  
modify the functions in .drone.star to call the .sh scripts at their new path (which is .drone). So,  
```
 "./.drone/boost-ci/ci/drone/linux-cxx-install.sh",
```
changes to  
```
 "./.drone/linux-cxx-install.sh",
```

### How are the docker images created?  

As a reference, a copy of the Dockerfiles used to create the images and containers may be found in the dockers/ directory of this repository.   
