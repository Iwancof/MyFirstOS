#![feature(lang_items)]
#![feature(start)]
#![no_main]
//#![feature(no_std)]
#![no_std]
//#![feature(no_core)]
#![feature(asm)]
#![allow(unused)]
#![feature(const_raw_ptr_deref)]
#![allow(non_upper_case_globals)]
#![feature(panic_info_message)]
#![feature(fmt_internals)]
#![feature(coerce_unsized)]
#![feature(const_fn)]
#![feature(unsize)]
#![feature(negative_impls)]
#![feature(untagged_unions)]

#[macro_use]
mod rmacro;

mod panic;
mod alloc;
mod vec;
mod string;
mod time;
//mod old_terminal;
mod keys;
mod terminal;

use core::mem::size_of;
use core::fmt::{self,Write,write,Error};
//#[allow(deprecated)] use nonzero::NonZero;
//use core::iter::IntoIterator::into_iter;
use time::{subscribe_with_task, subscribe};
use terminal::{Terminal};

const BASE : u32                = 0x102F00;
const DRAWNUM : u32             = 0  * 4;
const TESTFUNC : u32            = 1  * 4;
const DRAWSTR : u32             = 2  * 4;
const WAITTICK : u32            = 3  * 4;
const DRAWPIXEL : u32           = 4  * 4;
const RINGITEMSIZE : u32        = 5  * 4;
const KEYBUFF : u32             = 6  * 4;
const PANICHANDLER : u32        = 7  * 4;
const RINGRD : u32              = 8  * 4;
const DRAWCHAR : u32            = 9  * 4;
const POWEROFF : u32            = 10 * 4;
const PANICMESSAGE : u32        = 11 * 4;
const HEAPSTART : u32           = 12 * 4;
const RUSTTIMERADDRESS : u32    = 13 * 4;


//static mut _KEY_BUFF : 
static mut ItemSize : u32 = 0;
static mut KeyBuff : *mut u8 = 0 as *mut u8;
static mut Initialized : bool = false;
static mut Key : u8 = 0;
static mut MyTerminal1 : Option<Terminal> = None; // Uninitialized;
//static mut MyTerminal1 : Terminal = Terminal {form : [' ';terminal::X_MAX],x : 0, y : 0, x_offset : 1, y_offset : 0, color : 0x010F};
static mut PanicMessagePointer : *mut u8 = 0 as *mut u8;
static mut HeapStart : *mut u8 = 0 as *mut u8;
static mut RustTimerAddress : *mut fn() -> () = 0 as *mut fn() -> ();


macro_rules! print {
    ($($arg:tt)*) => (unsafe {write!(MyTerminal1,"{}",format_args!($($arg)*)) });
}


#[no_mangle]
#[start]
pub unsafe fn init_os() -> fn() -> () {
    if Initialized {
        panic!()
    }

    init_func();
    keys::init_keys();
    //Terminal::init_terminal(&mut MyTerminal1);
    alloc::init_memory(HeapStart);
    time::init_timer();

    MyTerminal1 = Some(Terminal::new());

    Initialized = true;
   
    //subscribe(test_timer, 1000);

    //string::string_test
    //vec::vec_test
    rust_entry
    //rust_test_code

    }


pub fn rust_entry() -> () {
    if ring_rd(unsafe { KeyBuff },unsafe {&mut Key }) != 0 {
        let mut inp_key = unsafe {Key};
        // key pressed
        unsafe {
            if let Some(x) = &mut MyTerminal1 {
                x.input_key(inp_key);
            }
        }
    }
}

// from rust 
#[no_mangle]
pub unsafe extern fn memset(s: *mut u8, c: i32, n: usize) -> *mut u8 {
    let mut i = 0;
    while i < n {
        *s.offset(i as isize) = c as u8;
        i += 1;
    }
    return s;
}
#[no_mangle]
pub unsafe extern fn memcpy(dest: *mut u8, src: *const u8,
                            n: usize) -> *mut u8 {
    let mut i = 0;
    while i < n {
        *dest.offset(i as isize) = *src.offset(i as isize);
        i += 1;
    }
    return dest;
}

#[no_mangle]
pub unsafe extern fn memcmp(s1: *const u8, s2: *const u8, n: usize) -> i32 {
    let mut i = 0;
    while i < n {
        let a = *s1.offset(i as isize);
        let b = *s2.offset(i as isize);
        if a != b {
            return a as i32 - b as i32
        }
        i += 1;
    }
    return 0;
}

#[no_mangle]
pub unsafe extern fn memmove(dest: *mut u8, src: *const u8,
                             n: usize) -> *mut u8 {
    if src < dest as *const u8 { // copy from end
        let mut i = n;
        while i != 0 {
            i -= 1;
            *dest.offset(i as isize) = *src.offset(i as isize);
        }
    } else { // copy from beginning
        let mut i = 0;
        while i < n {
            *dest.offset(i as isize) = *src.offset(i as isize);
            i += 1;
        }
    }
    return dest;
}

fn rust_test_code() -> () {
    draw_num(0x1234, 0, 0);
    test_func();
    draw_str(0, 1, 0x010F,"TESTING");
    wait_tick(1000);
    draw_pixel(100,100, 0x010F);
    draw_char(0,3,0x010F,'T' as u8);
}


unsafe fn init_func() {
    // this function uses type panning and unsafe memory dereference
    draw_num_unsafe = {
        create_union!(i32,usize,usize, ; );
        deref_func!(BASE + DRAWNUM)
    };
    test_func_unsafe = {
        create_union!( ; );
        deref_func!(BASE + TESTFUNC)
    };
    draw_str_unsafe = {
        create_union!(usize,usize,u16,&str, ; );
        deref_func!(BASE + DRAWSTR)
    };
    wait_tick_unsafe = {
        create_union!(usize, ; );
        deref_func!(BASE + WAITTICK)
    };
    draw_pixel_unsafe = {
        create_union!(usize, usize, u16, ; );
        deref_func!(BASE + DRAWPIXEL)
    };
    asm_panic = {
        create_union!( ; !);
        deref_func!(BASE + PANICHANDLER)
    };
    ring_rd_unsafe = {
        create_union!(*mut u8,*mut u8, ; i32);
        deref_func!(BASE + RINGRD)
    };
    draw_char_unsafe = {
        create_union!(usize,usize,u16,u8, ; );
        deref_func!(BASE + DRAWCHAR)
    };
    power_off_unsafe = {
        create_union!( ; !);
        deref_func!(BASE + POWEROFF)
    };
    KeyBuff = *((BASE + KEYBUFF) as *mut u32) as *mut u8;
    ItemSize = *((BASE + RINGITEMSIZE) as *mut u32);
    PanicMessagePointer = *((BASE + PANICMESSAGE) as *mut u32) as *mut u8;
    HeapStart = *((BASE + HEAPSTART) as *mut u32) as *mut u8;
    RustTimerAddress = *((BASE + RUSTTIMERADDRESS) as *mut u32) as *mut fn() -> ();
}

#[lang = "eh_personality"]
extern fn eh_personality() {}



static mut draw_num_unsafe : extern fn(num : i32, x : usize, y : usize) -> () = draw_num_uninitialized;
extern fn draw_num_uninitialized(num : i32, x : usize, y : usize) {}
extern fn draw_num(num : i32, x: usize, y : usize) -> () { unsafe {draw_num_unsafe(num,x,y);}  }

static mut test_func_unsafe : extern fn() -> () = test_func_uninitialized;
extern fn test_func_uninitialized() {}
extern fn test_func() -> () { unsafe{test_func_unsafe(); } }

static mut draw_str_unsafe : extern fn(x : usize, y : usize, color : u16, msg : &str) = draw_str_uninitialized;
extern fn draw_str_uninitialized(x : usize, y: usize, color : u16, msg : &str) {}
extern fn draw_str(x : usize, y : usize, color : u16, msg : &str) { unsafe{draw_str_unsafe(x,y,color,msg);} }

static mut wait_tick_unsafe : extern fn(t : usize) -> () = wait_tick_uninitialized;
extern fn wait_tick_uninitialized(t : usize) {}
extern fn wait_tick(t : usize) -> () { unsafe{ wait_tick_unsafe(t); }}

static mut draw_pixel_unsafe : extern fn(x : usize, y : usize, col : u16) -> () = draw_pixel_uninitialized;
extern fn draw_pixel_uninitialized(x : usize, y : usize, col : u16) {}
extern fn draw_pixel(x : usize, y : usize, col : u16) -> () { unsafe{draw_pixel_unsafe(x,y,col); }}

static mut asm_panic : extern fn() -> ! = asm_panic_uninitialized;
extern fn asm_panic_uninitialized() -> ! { loop{} }

static mut ring_rd_unsafe : extern fn(buf : *mut u8, dst : *mut u8) -> i32 = ring_rd_uninitialized;
extern fn ring_rd_uninitialized(buf : *mut u8, dst : *mut u8) -> i32 { -1 }
extern fn ring_rd(buf : *mut u8, dst : *mut u8) -> i32 { unsafe{ring_rd_unsafe(buf, dst) } }

static mut draw_char_unsafe : extern fn(x : usize, y : usize, col : u16, ch : u8) -> () = draw_char_uninitialized;
extern fn draw_char_uninitialized(x : usize, y : usize, col : u16, ch : u8) -> () {}
extern fn draw_char(x : usize, y : usize, col : u16, ch : u8) { unsafe{draw_char_unsafe(x,y,col,ch); } }

static mut power_off_unsafe : extern fn() -> ! = power_off_uninitialized;
extern fn power_off_uninitialized() -> ! { loop {} }
extern fn power_off() -> ! { unsafe{ power_off_unsafe() } }


