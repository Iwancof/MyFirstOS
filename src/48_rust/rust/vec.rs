use core::ops::{self,Index,IndexMut};


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
    next : &'a mut VecElement<'a, T>,
}

enum VecItem<T> {
    HasValue(T),
    NoValue,
}

impl<'a, T> Vec<'a, T> {
    pub fn new() -> Self {
        // create empty vec
        Vec{ head : VecElement::NoElement, count : 0}
    }
    pub fn at_mut(&mut self, index : usize) -> Result<&mut VecElement<'a, T>, i32> {
        let mut current = &mut self.head;
        for i in 0..index {
            match current {
                VecElement::HasElement(raw_vec) => {
                    current = raw_vec.next;
                },
                VecElement::NoElement => {
                    return Err(i as i32);
                }
            }
        }
        let (flag, code) : (bool, i32);
        match current {
            VecElement::HasElement(raw_vec) => {
                match raw_vec.item {
                    VecItem::HasValue(_) => { Ok(current) }
                    VecItem::NoValue => { Err(-1) }
                }
            },
            VecElement::NoElement => {
                Err(index as i32)
            }
        }
    }
    pub fn at(&self, index : usize) -> Result<&VecElement<'a, T>, i32> {
        let mut current = &self.head;
        for i in 0..index {
            match current {
                VecElement::HasElement(raw_vec) => {
                    current = raw_vec.next;
                },
                VecElement::NoElement => {
                    return Err(i as i32);
                }
            }
        }
        let (flag, code) : (bool, i32);
        match current {
            VecElement::HasElement(raw_vec) => {
                match raw_vec.item {
                    VecItem::HasValue(_) => { Ok(current) }
                    VecItem::NoValue => { Err(-1) }
                }
            },
            VecElement::NoElement => {
                Err(index as i32)
            }
        }
    }
    pub fn push(&mut self, item : T) -> Result<usize, i32> {
        match self.at_mut(self.count) {
            Ok(rf) => {
                match *rf {
                    VecElement::HasElement(elm) => {
                        elm.next = &VecElement::HasValue(RawVecElement {} );
                    },
                    VecElement::NoElement => {
                        panic!("Unexpected error");
                    }
                };
                self.count += 1;
                Ok(self.count)
            },
            Err(code) => {
                Err(code)
            }
        }
    }
}

impl<'a, T> core::ops::Index<usize> for Vec<'a, T> {
    type Output = VecElement<'a, T>;
    fn index(&self, index: usize) -> &Self::Output {
        match self.at(index) {
            Ok(vec_ref) => vec_ref,
            Err(code) => panic!("Index access error:{}", code)
        }
    }
}

impl<'a, T> core::ops::IndexMut<usize> for Vec<'a, T> {
    fn index_mut(&mut self, index: usize) -> &mut Self::Output {
        match self.at_mut(index) {
            Ok(vec_ref) => vec_ref,
            Err(code) => panic!("Index access error:{}", code),
        }
    }
}


