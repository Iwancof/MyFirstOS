
use super::alloc::{malloc, free, null_pointer, Pointer};
use core::fmt::{Write, Display};
use core::ops::{Index, IndexMut};
use core::clone::Clone;
use core::iter::FromIterator;

pub struct Vec<T : core::clone::Clone> {
    // Vector front
    head : Pointer<VecElement<T>>,
    count : usize,
}
pub struct VecElement<T> {
    item : T,
    next : Pointer<VecElement<T>>,
}

impl<T : Clone> Vec<T> {
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
            if !ret.is_valid() {
                panic!("invalid at {} ", i);
            }
            ret = (*ret).next.copy();
        }
        ret
    }
    pub fn push(&mut self, elm : T) {
        //print!("{}", elm);
        if self.count == 0 {
            // if no vec has no element. we must overwrite head.

            let ptr = malloc::<VecElement<T>>(1);
            *ptr.deref() = VecElement::new(elm);
            self.head = ptr;
            self.count += 1;
            return;
        }
        let tail = self.at(self.count - 1);
        (*tail.deref()).next = VecElement::new_inheap(elm);
        self.count += 1;
    }
    pub fn pop(&mut self) -> usize {
        self.erase(self.count - 1)
    }
    pub fn erase(&mut self, index : usize) -> usize {
        if self.count == 0 {
            panic!("vec erase. but len is 0");
        }
        if index == 0 { // self.head moves and have someone.
            self.head = (*self.head).next.copy();
            self.count -= 1;
            return self.count
        }
        let mut crt = self.head.copy();
        for i in 0..index-1 { // crt moves to before element will be erase
            crt = (*crt).next.copy();
        }
        let erase_elm = (*crt).next.copy();
        (*crt).next = (*erase_elm).next.copy();
        //free(erase_elm);
        self.count -= 1;
        self.count
    }
    pub fn get(&self, index : usize) -> T {
        (*self.at(index)).item.clone()
    }
    pub fn set(&mut self, index : usize, item : T) {
        (*self.at(index).deref()).item = item;
    }
    pub fn iter(&self) -> VecIter<T> {
        VecIter{ now : self.head.copy() }
    }
    pub fn size(&self) -> usize {
        self.count
    }
}
impl<T : Clone> Drop for Vec<T> {
    fn drop(&mut self) {
        let mut crt = self.head.copy();
        for i in 0..self.count {
            let tmp = (*crt).next.copy();
            //free(crt);
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
        let mut ptr = malloc::<Self>(1);
        *ptr = obj;
        ptr

    }
}
pub struct VecIter<T> {
    now : Pointer<VecElement<T>>,
}
impl<T : Clone> Iterator for VecIter<T> {
    type Item = T;
    fn next(&mut self) -> Option<T> {
        //print!("{}", self.now);
        if !self.now.is_valid() {
            return None;
        } else {
            let ret = (*self.now).item.clone();
            self.now = (*self.now).next.copy();
            Some(ret)
        }
    }
}
impl<T : Clone> FromIterator<T> for Vec<T> {
    fn from_iter<I : IntoIterator<Item=T>>(iter : I) -> Self {
        let mut ret = Vec::<T>::new();
        for e in iter {
            ret.push(e);
        }
        ret
    }
}



pub fn vec_test() {
    unsafe {
        if Once == true {
            return;
        }
        Once = true;
    }
    let mut primes = vec!(<u32>);
    primes.push(2);
    for i in 3..100 {
        let mut prime = true;
        for p in primes.iter() {
            if i % p == 0 {
                prime = false;
                break;
            }
        }
        if prime {
            primes.push(i)
        }
    }
    for p in primes.iter().map(|x| x + 1) {
        print!("{} ",p);
        //new_line();
    }

}


static mut Once : bool = false;


