
macro_rules! create_union {
   ( $($args:ty,)* ; $ret:ty ) => {
        union FnPointerUnion {
            func : extern fn($($args,)*) -> $ret,
            //func : fn(i32,) -> i32,
            value : u32,
        }
   };
   ( $($args:ty,)* ;) => {
        union FnPointerUnion {
            func : extern fn($($args,)*) -> (),
            value : u32,
        }
   };
   (; $ret:ty ) => {
        Union FnPointerUnion {
            func : extern fn() -> $ret,
            value : u32,
        }
   };
}

macro_rules! deref_func {
    ( $adr:expr ) => {
        FnPointerUnion { value : *(($adr) as *mut u32) }.func;
    }
}

macro_rules! vec {
    (<$arg:ty>) => (super::vec::Vec::<$arg>::new())
}
macro_rules! print {
    ($($arg:tt)*) => (
        unsafe {
            if let Some(x) = &mut super::MyTerminal1 {
                write!(x,"{}",format_args!($($arg)*));
            }
        }
    );
}
/*
macro_rules! print {
    ($($arg:tt)*) => ( );
}
*/
