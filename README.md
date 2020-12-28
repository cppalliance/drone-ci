
A CPPAlliance hosted [Drone](https://www.drone.io/) server for Boost libraries.  
  
### Instructions:  
  
If you are a Boost author, follow these steps to get started.  

- Visit https://drone.cpp.al
- "Authorize Drone". Click the "Authorize cppalliance-drone" button.  
- Sync repositories. Click the "sync" button.  
- A list of repositories will appear. For each repo, click and then choose "Activate Repository".  
- In the settings page, change Configuration from .drone.yml to .drone.star. "Save".  
  
Push a commit to one of the main git branches such as "develop" or "master", or submit a pull request, to trigger a build in drone.  
  
### Potential Issues

- asan jobs require privileged access, and will show an error about "LeakSanitizer does not work under ptrace".  Add an argument "privileged=True" to linux_cxx() in the .drone.star file. 
  
- If one of the jobs shows an error about requiring privileged access in the Drone UI, contact an administrator to increase privileges for the docker container.
  
- If you have any questions or problems, please open an Issue in this github repo.  
