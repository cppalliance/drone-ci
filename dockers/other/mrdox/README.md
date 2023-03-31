
LLVM/CLANG docker images for mrdox or other projects.  

See the Dockerfile for all steps.  

Build it with:  

```
./build.sh  
```

Other Notes:

```
A method to build on Windows:

# From Administrator CMD.EXE,
# after running vcvars64.bat

cmake -S ../llvm/llvm -B . -G "Visual Studio 17 2022" -A x64 -DCMAKE_CONFIGURATION_TYPES="Release" -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra"
cmake --build . --config Release
cmake --install . --prefix "C:\Users\vinnie\src\llvm-install\Release" --config Release
```
