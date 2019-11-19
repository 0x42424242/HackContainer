# HackContainer

Docker container used to spin up quick access to linux commands. Combined with the following powershell aliases.

Located at `C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1`

```
function hackbox() {
	docker run --rm -i -t --privileged --cap-add=SYS_PTRACE --entrypoint="/bin/zsh" -w /root/ hackbox:latest
}
```

```
function hackboxhere() {  
    docker run --rm -it --privileged --cap-add=SYS_PTRACE --entrypoint="/bin/zsh" -v ${pwd}:/root/Scratch/ -w /root/ hackbox:latest
}
```
