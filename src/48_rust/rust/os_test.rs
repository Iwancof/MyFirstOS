#![feature(lang_items)]
#![feature(start)]
#![no_main]
#![feature(no_std)]
#![no_std]
#![feature(asm)]
#![allow(unused)]
#![feature(const_raw_ptr_deref)]

use core::panic::PanicInfo;

const BASE : u32 = 0x102F00;
const DRAWNUM : u32 = 0;

#[no_mangle]
static mut draw_num : extern fn(num : i32, x : i32, y : i32) -> () = draw_num_uninitialized;
#[no_mangle]
extern fn draw_num_uninitialized(num : i32, x : i32, y : i32) {}

#[no_mangle]
#[start]
pub unsafe extern fn init_os() -> !{
    init_func();

    draw_num(0xABCDEF, 0, 0);

    panic!();
}

#[no_mangle]
unsafe fn init_func() {
    draw_num = (DrawNumFnPointer{ ptr : *((BASE + DRAWNUM) as *mut u32) }).func
}



#[lang = "eh_personality"]
extern fn eh_personality() {}

#[panic_handler]
extern fn panic_handler(x : &PanicInfo) -> ! { loop {} }

union DrawNumFnPointer {
    func : extern fn(n : i32, x : i32,y : i32) -> (),
    ptr : u32,
}
