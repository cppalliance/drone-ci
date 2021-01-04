
## Drone Documentation

[https://docs.drone.io](https://docs.drone.io/)

More specific details about this implementation -

In the .drone.star file, one of the parameters for a job is "image".  This could be any docker image, however in practice it should be one of the following:  
  
cppalliance/droneubuntu1204:1  
cppalliance/droneubuntu1404:1  
cppalliance/droneubuntu1604:1  
cppalliance/droneubuntu1804:1  
cppalliance/droneubuntu2004:1  
cppalliance/dronevs2017  
cppalliance/dronevs2019  
  
These images have been preinstalled with most of the packages found on a travis-ci image.  

For OSX builds, specify the xcode version instead of the image. Recent versions of xcode from 6.4 to 11.7 are available.  
  
xcode_version="10.3"  
  
The job fields "llvm_os" and "llvm_ver" are used to install the correct version of LLVM by [linux-cxx-install.sh](https://github.com/boostorg/boost-ci/blob/master/ci/drone/linux-cxx-install.sh).  

llvm_os is the Ubuntu descriptive name such as "xenial" or "bionic".  
llvm_ver is the version such as "5.0".  
