use super::terminal::{Terminal};
use core::fmt::Write;

static mut Keys : [KeyInfo;256] = [KeyDefault;256];
pub static mut KeyFlag : u8 = 0;
static KeyDefault : KeyInfo = KeyInfo{ch : '-',is_char : true, control_func : default_key_inp, release_func : default_key_inp };

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
pub struct KeyInfo {
    pub ch : char,
    pub is_char : bool,     // or control key
    pub control_func : fn(&mut Terminal) -> bool,    // control terminal
    pub release_func : fn(&mut Terminal) -> bool,
}
impl KeyInfo {
    fn new(x : char) -> KeyInfo {
        KeyInfo {ch : x, is_char : true, control_func : default_key_inp , release_func : default_key_inp }
    }
}
fn default_key_inp(_ : &mut Terminal) -> bool { true }
pub fn init_keys() {
    unsafe {
        let length = KEYMAP.len();
        let mut counter = 0;
        for c in KEYMAP.chars() {
            unsafe {
                Keys[counter] = KeyInfo::new(c);
                // convert to char from keycode by KEYMAP string
            }
            counter += 1;
        }
        
        /*
        //Escape
        Keys[0x01].is_char = false;
        Keys[0x01].control_func = Terminal::escape;
        */
        // Shift
        Keys[0x2A].is_char = false;
        Keys[0x2A].control_func = code_convert_big;
        Keys[0x2A].release_func = code_convert_small;

        // back space
        Keys[0x0E].is_char = false;
        Keys[0x0E].control_func = Terminal::back_space;

        // enter
        Keys[0x1C].is_char = false;
        Keys[0x1C].control_func = Terminal::terminal_enter;
    }
}
pub fn access_key_by_u8(i : u8) -> KeyInfo {
    // unsafe wrapper
    unsafe { Keys[i as usize] }
}
pub fn access_key_by_usize(i : usize) -> KeyInfo {
    // unsafe wrapper
    unsafe { Keys[i] }
}

pub fn code_convert_big(_ : &mut Terminal) -> bool {
    unsafe {
        KeyFlag = 0x20;
    }
    true
}
pub fn code_convert_small(_ : &mut Terminal) -> bool {
    unsafe {
        KeyFlag = 0x0;
    }
    true
}

