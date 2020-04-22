
use super::alloc::{malloc, free, null_pointer, Pointer};
use core::fmt::Write;
use core::ops::{Index, IndexMut};
use core::clone::Clone;

macro_rules! print {
    ($($arg:tt)*) => (unsafe { write!(super::MyTerminal1,"{}",format_args!($($arg)*)) } );
}

struct Vec<T : core::clone::Clone> {
    // Vector front
    head : Pointer<VecElement<T>>,
    count : usize,
}
struct VecElement<T> {
    item : T,
    next : Pointer<VecElement<T>>,
}

impl<T : core::clone::Clone> Vec<T> {
    pub fn new() -> Self {
        // return no element vector
        Self {
            head : null_pointer::<VecElement<T>>(),
            count : 0
        }
    }
    fn at(&self, index : usize) -> Pointer<VecElement<T>>{
        // this func require only reference. but element is mut because return Pointer.
        let mut ret = self.head.copy();
        for i in 0..index {
            // if ret == invalid { error }
            ret = (*ret.at(0)).next.copy();
        }
        ret
    }
    fn push(&mut self, elm : T) {
        if self.count == 0 {
            // if no vec has no element. we must overwrite head.

            let ptr = malloc::<VecElement<T>>(1);
            (*ptr.at(0)) = VecElement::new(elm);
            self.head = ptr;
            self.count += 1;
            return;
        }
        let tail = self.at(self.count - 1);
        (*tail.at(0)).next = VecElement::new_inheap(elm);
        self.count += 1;
    }
    pub fn get(&self, index : usize) -> T {
        self.at(index).at(0).item.clone()
    }
    pub fn set(&mut self, index : usize, item : T) {
        self.at(index).at(0).item = item;
    }
    pub fn to_iter(&mut self) -> VecIter<T> {
        VecIter{ now : self.head.copy() }
    }
}
impl<T : Clone> Drop for Vec<T> {
    fn drop(&mut self) {
        let mut crt = self.head.copy();
        for i in 0..self.count {
            let tmp = crt.at(0).next.copy();
            free(crt);
            crt = tmp;
        }
    }
}
impl<T> VecElement<T> {
    pub fn new(elm : T) -> Self {
        Self {
            item : elm,
            next : null_pointer::<Self>(),
        }
    }
    pub fn new_inheap(elm : T) -> Pointer<Self> {
        let obj = Self::new(elm);
        let ptr = malloc::<Self>(1);
        *ptr.at(0) = obj;
        ptr

    }
}
pub struct VecIter<T> {
    now : Pointer<VecElement<T>>,
}
impl<T : Clone> Iterator for VecIter<T> {
    type Item = T;
    fn next(&mut self) -> Option<T> {
        if !self.now.is_valid() {
            return None;
        } else {
            let ret = self.now.at(0).item.clone();
            self.now = self.now.at(0).next.copy();
            Some(ret)
        }
    }
}


pub fn vec_test() {
    unsafe {
        if Once == true {
            return;
        }
        Once = true;
    }
    let mut primes = Vec::<u32>::new();
    primes.push(2);
    for i in 3..100 {
        let mut prime = true;
        for p in primes.to_iter() {
            if i % p == 0 {
                prime = false;
                break;
            }
        }
        if prime {
            primes.push(i)
        }
    }
    for p in primes.to_iter() {
        print!("{} ",p);
        new_line();
    }

}

fn new_line() {
    unsafe { super::MyTerminal1.new_line(); }
}

static mut Once : bool = false;
