@echo off
rem chcp 65001
@echo on
qemu-system-i386.exe -rtc base=localtime -drive file=%1,format=raw -boot order=c
