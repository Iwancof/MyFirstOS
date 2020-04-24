
use super::vec::{Vec};
use core::fmt::{self, Write};
//use compiler_builtils::mem;
use core::iter::FromIterator;

pub struct String{
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
    pub fn len(&self) -> usize {
        self.vec.size()
    }
    pub fn pop(&mut self) -> usize {
        self.vec.pop()
    }
    pub fn erase(&mut self, index : usize) -> usize {
        self.vec.erase(index)
    }
    pub fn iter(&self) -> super::vec::VecIter<u8> {
        self.vec.iter()
    }
}

impl PartialEq for String {
    fn eq(&self, other : &Self) -> bool {
        if self.len() != other.len() {
            return false;
        }
        self.vec.iter().eq(other.vec.iter())
    }
}

impl fmt::Display for String {
    fn fmt(&self, f : &mut fmt::Formatter<'_>) -> fmt::Result {
        for c in self.vec.iter() {
            match write!(f, "{}", c as char) {
                Err(x) => return Err(x),
                _ => (),
            }
        }
        Ok(())
    }
}

impl FromIterator<u8> for String {
    fn from_iter<I : IntoIterator<Item=u8>>(iter : I) -> String {
        let mut ret = String::new();
        for c in iter {
            ret.push(c);
        }
        ret
    }
}

pub fn string_test() {
    unsafe {
        if Once {
            return;
        }
        Once = true;
    }
   
    //let mut s = String::from_str("aaaa");
    let mut s = String::from_str("abcd");
    s.erase(3);
    print!("{} ", s);

    loop {} 
}

static mut Once : bool = false;
