use core::ops::{self, Index, IndexMut};
use super::alloc::{Pointer,NullPointer,malloc};
use core::fmt::Write;

macro_rules! print {
    ($($arg:tt)*) => ( unsafe { write!(super::MyTerminal1,"{}",format_args!($($arg)*)); } );
}

pub struct Vec<'a, T> {
    head : VecElement<'a, T>,
    count : usize,
}

pub enum VecElement<'a, T> {
    HasElement(RawVecElement<'a, T>),
    NoElement,
}

struct RawVecElement<'a, T> {
    item : VecItem<T>,
    next : Pointer<VecElement<'a, T>>,
}

enum VecItem<T> {
    HasValue(T),
    NoValue,
}

impl<'a, T> Vec<'a, T> {
    pub fn new() -> Self {
        Vec{ head : VecElement::NoElement, count : 0 }
    }
    pub fn at(&self, index : usize) -> Result<Pointer<VecElement<'a, T>>, usize> {
        // return .. Pointer or error code.
        let mut crt = &self.head;
        
        for i in 0..index {
            match crt.next() {
                Ok(n) => crt = n,
                Err(_) => return Err(123),
            }
        }
        if let VecElement::HasElement(n) = crt { Ok(n.copy()) } else { Err(index) }
    }
    pub fn push(&mut self, elm : T) -> usize {
        if self.count == 0 {
            (*self).head = VecElement::new(elm);
            (*self).count += 1;
            return self.count
        }

        // return pushed index
        let tail = match self.at(self.count - 1) {
            Ok(n) => n,
            Err(code) => return code,
        };
        let ptr = malloc::<VecElement<T>>(1);
        *(ptr.at(0)) = VecElement::new(elm);
        (*(tail.at(0))).set_next(ptr);
        self.count += 1;
        self.count
    }
}
impl<'a, T> VecElement<'a, T> {
    pub fn new(elm : T) -> Self {
        // this methot dose not create on heap. only create VecElement
        Self::HasElement(
            RawVecElement { 
                item : VecItem::HasValue(elm),
                next : NullPointer::<VecElement<'a, T>>(),
            }
        )
    }
    pub fn set_next(&mut self, next : Pointer<VecElement<'a, T>>) {
        match self {
            Self::HasElement(v) => { v.next = next },
            Self::NoElement => { panic!("Cound not set next"); },
        }
    }
    pub fn next(&self) -> Result<&Self,()> {
        match self {
            Self::HasElement(n) => { Ok(n.next.at(0)) },
            Self::NoElement => { Err(()) },
        }
    }
}

pub fn vec_test() {
    unsafe {
        if Once { return; }
        Once = true;
    }

    let mut v = Vec::<u8>::new();
    print!("{} ",v.push(0x12) );
    print!("{} ",v.push(0x12) );
    print!("{} ",v.push(0x12) );
    unsafe { super::MyTerminal1.new_line(); }
    match v.head {
        VecElement::HasElement(_) => { print!("Has element "); },
        VecElement::NoElement => { print!("No element "); },
    }
    unsafe { super::MyTerminal1.new_line(); }
    for i in 0..2 {
        match v.at(i) {
            Ok(_) => { print!("has {} ", i); }
            Err(_) => { print!("no has {} ", i); }
        }
        unsafe { super::MyTerminal1.new_line(); }
    }
    //print!("value = {} ", v.at(0).unwrap());
}

static mut Once : bool = false;

