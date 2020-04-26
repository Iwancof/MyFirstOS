using namespace System.Linq;

cd rust
rustc .\main.rs --crate-type=staticlib -C lto -C opt-level=1 -C no-prepopulate-passes -C no-stack-check -Z verbose -Z no-landing-pads --target=i686-unknown-linux-gnu -o .\main.o --emit=obj -Ctarget-feature=+soft-float
cd ..
nasm	boot.s -o boot.bin -l boot.lst
nasm	kernel.s -o kernel.bin -l kernel.lst
nasm	fat.s -o fat.bin

[System.Console]::WriteLine("i686-unknown-linux-gnu-ld main.o -o ../main.bin -nostdlib -T linker.ld -e init_os");
[System.Console]::ReadLine();

# padding until 0x320000(HEAP_END)

$other_size = (Get-Item boot.bin).Length;
$other_size += (Get-Item kernel.bin).Length;
$other_size += (Get-Item main.bin).Length;
$pad_size = (0x320000 - $other_size)

Remove-Item padding.bin
fsutil file createnew padding.bin $pad_size

cmd /C copy /B boot.bin+kernel.bin+main.bin+padding.bin+fat.bin boot.img

