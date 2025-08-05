
## P2996 ("Reflection for C++26")

The repository https://github.com/bloomberg/clang-p2996 contains experimental support for P2996 reflection.  

To facilitate testing, there is now a drone image with clang-p2996 built-in and available in the PATH variable as `clang++`.

From Docker Hub use the image `cppalliance/2404-p2996:1`

Bug reports or feedback are welcome.  

### Usage in Drone:  

Include a job in .drone.star:  

```
linux_cxx("Reflection", "clang++", buildtype="boost", buildscript="drone", image="cppalliance/2404-p2996:1", environment={'B2_TOOLSET': 'clang', 'B2_CXXSTD': '20,23,2c'}, globalenv=globalenv),
```

### In boost-ci:  

With the latest copy of `ci.yml` from boost-ci enable "reflection":  

```
  call-boost-ci:
    name: Run Boost.CI
    uses: boostorg/boost-ci/.github/workflows/reusable.yml@master
    with:
      enable_reflection: true
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
      COVERITY_SCAN_NOTIFICATION_EMAIL: ${{ secrets.COVERITY_SCAN_NOTIFICATION_EMAIL }}
```

### In any other CI framework:  

- Set the build container to `cppalliance/2404-p2996:1`  
- The compiler is `clang` or `clang++`

## TODO

_  

## List of likely non-TODO items   

Regarding "merging" clang-p2996 into previous LLVM versions.

The clang-p2996 repo has diverged significantly from the upstream LLVM project. Notice:  

```
This branch is 393 commits ahead of, 4198 commits behind llvm/llvm-project:main.
```

There are 13 merge conflicts. Every week the number will increase. Even if merge conflicts are resolved, the clang-p2996 code is based on the cutting-edge `main` branch, and that can't be expected to be backwards-merged into an old version of LLVM from years ago. It would generate conflicting classes, methods, functions, etc. 

