qemu-system-i386.exe -rtc base=localtime -drive file=boot.img,format=raw -boot order=c -serial telnet::23,server,nowait
