#![feature(lang_items)]
#![feature(start)]
#![no_main]
#![feature(no_std)]
#![no_std]
//#![feature(no_core)]
#![feature(asm)]
#![allow(unused)]
#![feature(const_raw_ptr_deref)]

use core::panic::PanicInfo;

const BASE : u32 = 0x102F00;
const DRAWNUM : u32 = 0 * 4;
const TESTFUNC : u32 = 1 * 4;
const DRAWSTR : u32 = 2 * 4;

#[no_mangle]
static mut draw_num : extern fn(num : i32, x : i32, y : i32) -> () = draw_num_uninitialized;
#[no_mangle]
extern fn draw_num_uninitialized(num : i32, x : i32, y : i32) {}
#[no_mangle]
static mut test_func : extern fn() -> () = test_func_uninitialized;
#[no_mangle]
extern fn test_func_uninitialized() {}
#[no_mangle]
static mut draw_str : extern fn(x : i32, y : i32, color : u16, msg : &str) = draw_str_uninitialized;
#[no_mangle]
extern fn draw_str_uninitialized(x : i32, y: i32, color : u16, msg : &str) {}

static mut value : i32 = 0x11223344;
static mut value2 : i32 = 0x22446688;

union test {
    fp : &'static extern fn() -> (),
    ptr : i32,
}


#[no_mangle]
#[start]
pub unsafe extern fn init_os() -> () {
    value = 0x55667788;
    value2 = 0x55667788;

    init_func();

    //draw_num(0x1234,0,0);
    // *((BASE + DRAWNUM) as *mut u32) as i32

    //DrawNumFnPointer{func : draw_num}.ptr
    //test{fp : &draw_num}.ptr
    //test {fp : &test_func}.ptr + 1
    //draw_str(0, 0, 0x010F, "Hello from Rust");
    //draw_num(0xABCDEF, 20, 0);
    
    draw_str(0, 1, 0x010F, "Hello world");
    //value
    //panic!();
    
}

#[no_mangle]
unsafe fn init_func() {
    draw_num = (DrawNumFnPointer{ ptr : *((BASE + DRAWNUM) as *mut u32) }).func;
    test_func = (TestFuncFnPointer{ ptr : *((BASE + TESTFUNC) as *mut u32) }).func;
    draw_str = (DrawStrFnPointer{ ptr : *((BASE + DRAWSTR) as *mut u32) }).func;
}



#[lang = "eh_personality"]
extern fn eh_personality() {}

#[panic_handler]
extern fn panic_handler(x : &PanicInfo) -> ! { loop {} }

union DrawNumFnPointer {
    func : extern fn(n : i32, x : i32,y : i32) -> (),
    ptr : u32,
}
union TestFuncFnPointer {
    func : extern fn() -> (),
    ptr : u32,
}
union DrawStrFnPointer {
    func : extern fn(x : i32, y : i32, color : u16, msg : &str) -> (),
    ptr : u32,
}

