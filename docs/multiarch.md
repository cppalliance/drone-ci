
## Multiarch

As mentioned in docs/drone-ci.md, in order to test on arm64 or s390x platforms specify one of these images:

cppalliance/droneubuntu1204:multiarch  
cppalliance/droneubuntu1404:multiarch  
cppalliance/droneubuntu1604:multiarch  
cppalliance/droneubuntu1804:multiarch  
cppalliance/droneubuntu2004:multiarch  

Include the parameter arch="arm64" or arch="s390x" in the job spec.

## Local multiarch testing

You can test other architectures in a virtualized environment on a x86_64 version of Ubuntu Linux.

```
sudo apt-get update
sudo apt-get install -y docker.io 
vi /etc/docker/daemon.json
```

Create the file /etc/docker/daemon.json and add  

```
{
"experimental": true
}
```
Restart docker
```
systemctl restart docker
```

Enable qemu
```
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

The previous step should be repeated after reboots also. You could put the command in /etc/rc.local.    

Run a container using another architecture:
```
docker run -it --platform=linux/s390x cppalliance/droneubuntu2004:multiarch bash
```

## Other options

[LinuxONE Community Cloud](https://linuxone.cloud.marist.edu/#/login) offers free s390x virtual machines.   
AWS has arm64 architecture servers.  



