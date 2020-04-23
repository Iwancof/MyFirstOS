
use super::vec::{Vec};
use core::fmt::{self, Write};
//use compiler_builtils::mem;

macro_rules! print {
    ($($arg:tt)*) => (unsafe { write!(super::MyTerminal1,"{}",format_args!($($arg)*)) } );
}

struct String{
    vec : Vec<u8>,    
}

impl String {
    pub fn new() -> String {
        String { vec: Vec::new() }
    }
    pub fn from_str(s : &str) -> String{
        let mut ret = Self::new();
        for c in s.chars() {
            ret.vec.push(c as u8);
        }
        ret
    }
    pub fn push(&mut self, elm : u8) {
        self.vec.push(elm);
    }
    pub fn push_char(&mut self, elm : char) {
        self.vec.push(elm as u8);
    }
    pub fn push_str(&mut self, s : &str) {
        for c in s.chars() {
            self.vec.push(c as u8);
        }
    }
}

impl fmt::Display for String {
    fn fmt(&self, f : &mut fmt::Formatter<'_>) -> fmt::Result {
        for c in self.vec.to_iter() {
            match write!(f, "{}", c as char) {
                Err(x) => return Err(x),
                _ => (),
            }
        }
        Ok(())
    }
}


pub fn string_test() {
    unsafe {
        if Once {
            return;
        }
        Once = true;
    }
   
    let mut s = String::from_str("aaaa");
    print!("{} ", s);

    loop {} 
}

static mut Once : bool = false;

fn new_line() {
    unsafe { super::MyTerminal1.new_line(); }
}
