@echo	off
cd rust
rustc .\os_test.rs --crate-type=staticlib -C lto -C opt-level=0 -C no-prepopulate-passes -C no-stack-check -Z verbose -Z no-landing-pads --target=i686-unknown-linux-gnu -o .\os_test.o --emit=obj
cd ..
nasm	boot.s -o boot.bin -l boot.lst
nasm	kernel.s -o kernel.bin -l kernel.lst
nasm	space.s -o space.bin -l space.lst
echo "i686-unknown-linux-gnu-ld os_test.o -e init_os -o os_test.bin -Ttext 0x1000"
pause
copy	/B boot.bin+kernel.bin+rust\os_test.bin+space.bin boot.img
