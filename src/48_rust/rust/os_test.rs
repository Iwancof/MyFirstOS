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
#![allow(private_in_public)]

#[macro_use]
mod rmacro;

mod panic;
//mod vec;
mod alloc;
//mod vector;
mod vec3;

use core::mem::size_of;
use core::fmt::{self,Write,write,Error};
//#[allow(deprecated)] use nonzero::NonZero;
//use core::iter::IntoIterator::into_iter;

const BASE : u32 = 0x102F00;
const DRAWNUM : u32 = 0 * 4;
const TESTFUNC : u32 = 1 * 4;
const DRAWSTR : u32 = 2 * 4;
const WAITTICK : u32 = 3 * 4;
const DRAWPIXEL : u32 = 4 * 4;
const RINGITEMSIZE : u32 = 5 * 4;
const KEYBUFF : u32 = 6 * 4;
const PANICHANDLER : u32 = 7 * 4;
const RINGRD : u32 = 8 * 4;
const DRAWCHAR : u32 = 9 * 4;
const POWEROFF : u32 = 10 * 4;
const PANICMESSAGE : u32 = 11 * 4;
const HEAPSTART : u32 = 12 * 4;

const X_MAX : usize = 60;
const Y_MAX : usize = 30;

//static mut _KEY_BUFF : 
static mut ItemSize : u32 = 0;
static mut KeyBuff : *mut u8 = 0 as *mut u8;
static mut Initialized : bool = false;
static mut Key : u8 = 0;
static mut MyTerminal1 : Terminal = Terminal {form : [' ';X_MAX],x : 0, y : 0, x_offset : 1, y_offset : 0, color : 0x010F};
static mut Keys : [KeyInfo;256] = [KeyDefault;256];
static mut PanicMessagePointer : *mut u8 = 0 as *mut u8;
static mut HeapStart : *mut u8 = 0 as *mut u8;

static KeyDefault : KeyInfo = KeyInfo{ch : '-',is_char : true, control_func : default_key_inp};


macro_rules! print {
    ($($arg:tt)*) => (write!(MyTerminal1,"{}",format_args!($($arg)*)));
}


#[no_mangle]
#[start]
pub unsafe fn init_os() -> fn() -> () {
    if Initialized {
        panic!()
    }

    init_func();
    init_keys();
    Terminal::init_terminal(&mut MyTerminal1);
    alloc::memory_init(HeapStart);


    Initialized = true;

    vec3::vec_test
    //rust_entry
    //rust_test_code
}

pub fn rust_entry() -> () {
    if ring_rd(unsafe { KeyBuff },unsafe {&mut Key }) != 0 {
        let mut inp_key = unsafe {Key};
        // key pressed
        let is_release = (inp_key & 0x80) == 0x80;
        inp_key &= !0x80;
        if is_release {
            //draw_char(0,0,0x010F,'r' as u8);
        } else {
            unsafe {
                if !MyTerminal1.input_key(inp_key) {
                    print!("Heap start at {}", HeapStart as u32);
                }
            }
        }
    }
}



impl Write for Terminal {
    fn write_str(&mut self, s : &str) -> Result<(),core::fmt::Error> {
        let chars = s.as_bytes();
        for i in 0..s.len() {
            draw_char(self.x + self.x_offset + 1, self.y, self.color, chars[i]);
            self.x += 1;
        };
        if X_MAX < self.x {
            Err(core::fmt::Error)
        } else {
            Ok(())
        }
    }
}

struct Terminal {
    form : [char;X_MAX],
    x : usize,
    y : usize,
    x_offset : usize,
    y_offset : usize,
    color : u16,
}

impl Terminal {
    // Control keys processes here. and convert to char
    fn input_key(&mut self, d : u8) -> bool {
        let get = access_key_by_u8(d);  // convert
        if get.is_char {                // control or char
            return self.input_char(access_key_by_u8(d).ch);
        };
        (get.control_func)(self)        // execute this key's function
    }
    fn input_char(&mut self, c : char) -> bool {
        self.form[self.x] = c;
        write!(self,"{}",c);
        true
    }
    fn terminal_enter(&mut self) -> bool {
        match self.execute_command() {
            CommandResult::Success(ret) => { },
            CommandResult::Failed(ret) => { },
            CommandResult::NotFound(len) => { 
                self.new_line();
                for i in 0..len {
                    write!(self,"{}",self.form[i].clone());
                }
                write!(self," : Command not found.");
            },
            CommandResult::Unknown => {
                self.new_line();
                write!(self,"Unknown error eccured.");
                panic!();
            },
        }
        // execute string(array and length pair)

        // after enter
        self.new_command_line();

        true
    }
    fn init_terminal(term : &mut Terminal) {
        term.new_command_line();
    }
    fn execute_command(&mut self) -> CommandResult {
        let mut command_last = self.x;
        for c in 0..self.x {
            if self.form[c] == ' ' {
                command_last = c;
                break;
            }
        }
        
        let cmp_func = Self::get_compare_array_func(self.form, command_last);

        if cmp_func("") {
            return CommandResult::Success(-1);
        }
        if cmp_func("help") {
            self.new_line();
            write!(self,"Command      | usage        | description");
            self.new_line();
            write!(self,"help         | help         | show help");
            self.new_line();
            write!(self,"shutdown     | shutdown     | power off this machine");
            return CommandResult::Success(1);
        }
        if cmp_func("clear") {
            for i in 0..self.y+1 {
                for j in 0..X_MAX {
                    draw_char(j + self.x_offset + 0, i + self.y_offset , 0x0000, ' ' as u8);
                }
            }
            self.x = 0;
            self.y = 0;
            return CommandResult::Success(1);
        }
        if cmp_func("shutdown") {
            power_off();
            return CommandResult::Success(0);
        }
        //default
        CommandResult::NotFound(command_last)
        
        //CommandResult::Unknown
    }
    fn back_space(&mut self) -> bool {
        if self.x == 0 {
            return false;
        }
        self.x -= 1;
        write!(self,"{}",' ');
        self.x -= 1;
        true
    }
    fn get_compare_array_func(string : [char;X_MAX], lim : usize) -> impl Fn(&str) -> bool {
        move |s : &str | -> bool {
            if s.len() != lim {
                return false;                   // length not match
            }
            let mut counter = 0;
            for c in s.chars() {
                if string[counter] != c {
                    return false;               // not match
                }
                counter += 1;
            }
            true                                // match
        }
    }
    fn new_line(&mut self) {                    // move to new line
        self.y += 1;
        if Y_MAX < self.y {
            panic!();                           // TODO fix
        }
        self.x = 0;
    }
    fn new_command_line(&mut self) {            // move to new line and draw '>'
        self.new_line();
        draw_char(self.x + self.x_offset + 0,self.y,self.color,'>' as u8);
    }
    fn escape(&mut self) -> bool {
        false
    }
}

enum CommandResult {
    Success(i32),
    Failed(i32),
    NotFound(usize),
    Unknown,
}
const KEYMAP : &str = "__1234567890-^__qwertyuiop@[__asdfghjkl;:__]zxcvbnm,./_*_ ________________-_~_+___0.__________";
/*
   E : BackSpace
   F : Tab
   1C: Enter
   1D: Ctrl
   29: Hennkann
   2A: Left Shift
   36: Right Shift
   38: Alt
   3A: Caps Lock
   3B ~ 44: F1 ~ F10
   45: Num Lock
   46: Insert
   47: Home
   48: Up
   49: Page Up
   4A: Minus
   4B: Left
   4C: 5
   4D: Right
   4E: Plus
   4F: End
   50: Down
   51: Page Down
   52: Zero
   53: Dot
   ??
   57: F11
   58: F12
   ??
   5D: Dictionary
*/

#[derive(Copy,Clone)]
struct KeyInfo {
    ch : char,
    is_char : bool,     // or control key
    control_func : fn(&mut Terminal) -> bool    // control terminal
}
impl KeyInfo {
    fn new(x : char) -> KeyInfo {
        KeyInfo {ch : x, is_char : true, control_func : default_key_inp}
    }
}
fn default_key_inp(_ : &mut Terminal) -> bool { true }
//fn terminal_enter(t : &mut Terminal) -> bool { true }

unsafe fn init_keys() {
    let length = KEYMAP.len();
    let mut counter = 0;
    for c in KEYMAP.chars() {
        unsafe {
            Keys[counter] = KeyInfo::new(c);
            // convert to char from keycode by KEYMAP string
        }
        counter += 1;
    }

    //Escape
    Keys[0x01].is_char = false;
    Keys[0x01].control_func = Terminal::escape;

    // back space
    Keys[0x0E].is_char = false;
    Keys[0x0E].control_func = Terminal::back_space;

    // enter
    Keys[0x1C].is_char = false;
    Keys[0x1C].control_func = Terminal::terminal_enter;
}
fn access_key_by_u8(i : u8) -> KeyInfo {
    // unsafe wrapper
    unsafe { Keys[i as usize] }
}
fn access_key_by_usize(i : usize) -> KeyInfo {
    // unsafe wrapper
    unsafe { Keys[i] }
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


