@echo off
if exist kernel.s (
  nasm %1 -o %~n1.bin -l %~n1.lst
  nasm kernel.s -o kernel.bin -l kernel.lst
  copy /B %~n1.bin+kernel.bin %~n1.img
) else (
  nasm %1 -o %~n1.img -l %~n1.lst
)
