@echo	off
cd rust
rustc .\main.rs --crate-type=staticlib -C lto -C opt-level=1 -C no-prepopulate-passes -C no-stack-check -Z verbose -Z no-landing-pads --target=i686-unknown-linux-gnu -o .\main.o --emit=obj -Ctarget-feature=+soft-float
cd ..
nasm	boot.s -o boot.bin -l boot.lst
nasm	kernel.s -o kernel.bin -l kernel.lst
nasm	space.s -o space.bin -l space.lst
echo "i686-unknown-linux-gnu-ld main.o -o ../main.bin -nostdlib -T linker.ld -e init_os"
pause
copy	/B boot.bin+kernel.bin+main.bin+space.bin boot.img
