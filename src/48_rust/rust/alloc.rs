use core::mem::size_of;
use core::fmt::{self, Write};

macro_rules! print {
    ($($arg:tt)*) => ( unsafe { write!(super::MyTerminal1,"{}",format_args!($($arg)*)); } );
}

static SizePerOneBreak : u32 = 256;
static HeaderSize : u32 = size_of::<u64>() as u32;
static mut IsValid : [bool;1025] = [false;1025];
static mut ControlNumber : usize = 0;
static mut Test_Once : bool = false;

struct BlockHeaderUnAligned<'a> {
    next : *mut BlockHeader<'a>,
    size : u32,
}
impl Clone for BlockHeaderUnAligned<'_> {
    fn clone(&self) -> Self {
        BlockHeaderUnAligned {
            next : self.next,
            size : self.size,
        }
    }
}
union BlockHeader<'a> {
    block_info : BlockHeaderUnAligned<'a>,
    align : u64,     // align
}
impl<'a> BlockHeader<'a> {
    fn next(&self) -> *mut Self { unsafe { self.block_info.next } }
}
impl Clone for BlockHeader<'_> {
    fn clone(&self) -> Self { BlockHeader { block_info : unsafe { self.block_info.clone() } } }
}
#[derive(Copy,Clone)]
pub struct Pointer<T> {
    adr : *mut T,        // raw pointer.
    sz : usize,
    ctrl_num : usize,
}
impl<T> Pointer<T> {
    pub fn copy(&self) -> Self {
        Self{ adr : self.adr, sz : self.sz, ctrl_num : self.ctrl_num }
    }
    pub fn is_valid(&self) -> bool {
        //print!("index:{}",self.ctrl_num);
        //new_line(); 
        unsafe { IsValid[self.ctrl_num] }
    }
}
union ReferenceAndPointer<'a, T> {
    rf : &'a mut T,
    #[no_mangle]
    rp : *mut T,
}
impl<'a, T> Clone for ReferenceAndPointer<'a, T> {
    fn clone(&self) -> Self { unsafe { ReferenceAndPointer { rp : self.rp } } }
}
impl<T> Pointer<T> {
    pub fn at(&self,index : usize) -> &mut T {
        unsafe { ReferenceAndPointer { rp : self.adr }.rf }
    }
    fn new(rp : *mut u8, size : usize) -> Self {
        Self {
            adr : rp as *mut T,
            sz : size,
            ctrl_num : unsafe { ControlNumber }
        }
    }
}
impl<T> fmt::Display for Pointer<T> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result { 
        unsafe { write!(f, "0x{:x},len : {},Valid : {}", self.adr as u32 ,self.sz, self.is_valid()) }
    }
}

static mut BasePointer : *mut BlockHeader = 0 as *mut BlockHeader;
static mut BreakPoint : *mut BlockHeader = 0 as *mut BlockHeader;

pub unsafe fn init_memory(heap_start : *mut u8) {
    BasePointer = heap_start as *mut BlockHeader;
    *BasePointer = BlockHeader {
        block_info : BlockHeaderUnAligned {
            next : BasePointer,
            size : 1,   // header size is 1.
        }
    };
    BreakPoint = get_end_of_block(BasePointer);
}

unsafe fn get_end_of_block(block : *mut BlockHeader) -> *mut BlockHeader {
    (block as u32 + (*block).block_info.size * HeaderSize) as *mut BlockHeader
}
fn get_end_of_block_test() {
    unsafe {
        let mut b = BlockHeader{ block_info : BlockHeaderUnAligned {
            next : 0 as *mut BlockHeader,
            size : 5,
        }};
        assert_eq!(
            get_end_of_block(&mut b as *mut BlockHeader) as u32,
            &mut b as *mut BlockHeader as u32 + 5 * HeaderSize,
        );
    }
}
unsafe fn get_data_region(block : *mut BlockHeader) -> *mut u8 {
    (block as u32 + HeaderSize) as *mut u8
}

// write new block
unsafe fn assign_new_block<'a>(new_heap : *mut BlockHeader<'a>, next_pointer : *mut BlockHeader<'a>, size : u32) -> *mut BlockHeader<'a> {
    (*new_heap).block_info = BlockHeaderUnAligned {
        next : next_pointer,
        size : size,            // size includes header
    };
    //get_data_region(new_heap)
    new_heap
}

// extension heap
unsafe fn break_heap(count : u32) -> *mut BlockHeader<'static> {   // return new region
    let ret = BreakPoint;                               // we can use after it
    BreakPoint = (BreakPoint as u32 + SizePerOneBreak * count) as *mut BlockHeader;
    ret
}
// extension heap and write new header
unsafe fn break_and_assign(last : *mut BlockHeader<'static>, break_count : u32) -> *mut u8{
    // on BreakPonint(lastest point), and size is (braek_count * SizePerOneBreak),
    // so, Header's is (break_count * SizePerOneBreak / HeaderSize)
    // and next is BasePointer.
    let header = assign_new_block(break_heap(break_count), BasePointer, (break_count * SizePerOneBreak / HeaderSize));
    (*last).block_info.next = header;
    get_data_region(header)
}
// use part of block. if the block size were 0, return true.
unsafe fn cut_block(block : *mut BlockHeader, size : u32) -> (*mut BlockHeader, bool){
    (*block).block_info.size -= size;
    (get_end_of_block(block), (*block).block_info.size <= 1) 
}
// get size(header unit) convert to break count
fn calc_break_size(size : u32) -> u32 {
    (size * HeaderSize / SizePerOneBreak) + 1
}

pub fn malloc<T>(size : usize) -> Pointer<T> {
    unsafe {
        let req_size = get_alloc_size(size * size_of::<T>());

        let mut current : *mut BlockHeader = BasePointer;
        let mut prev : *mut BlockHeader = 0 as *mut BlockHeader;
        loop {
            let current_size = (*current).block_info.size;  // this value includes header size

            // Case1:found block.
            if req_size <= current_size - 1 { // match!! -1 is current header size
                // update current block header and cut block.
                let (new_block,is_empty) = cut_block(current,req_size);
                
                // write header to cut block. but dose not have next, so set to 0.
                assign_new_block(new_block, 0 as *mut BlockHeader, req_size);
                
                // if current block has no more space
                if is_empty {   // only header
                    (*prev).block_info.next = (*current).block_info.next;
                }
    
                // return .... start at new_block, max_size is size.
                ControlNumber += 1;
                IsValid[ControlNumber] = true;  // valid!!
                return Pointer::new(get_data_region(new_block), size);

            }

            // Case2:block not found.
            // there are not space of allocate. so new region assign to heap.
            if (*current).block_info.next == BasePointer as *mut BlockHeader {
                // break and write header on next to current.
                // and break count is req_size(so break size is SizePerOneBreak * req_size...)
                break_and_assign(current,calc_break_size(req_size));       // get new region

                // and next loop. we are going to case1 and use this block. 
            }

            prev = current;
            current = (*current).block_info.next;
        }
    }
}

pub fn free<T>(pointer : Pointer<T>) {
    if !unsafe { pointer.is_valid() } {
        panic!("Invalid pointer. {}", pointer);
    } else {
        //print!("valid {}", pointer.ctrl_num);
    }
    unsafe { IsValid[pointer.ctrl_num] = false; }

    // "pointer" is user space address. so create this block header
    let target = convert_blockptr_from_ptr(pointer);

    // search block before target.
    let before = unsafe { search_block_before_target(target) };

    unsafe {
        // check being able to link block which after target
        if same_pointer( get_end_of_block(target), (*before).next() ) {
            (*target).block_info.size += (*before).block_info.size;
            (*target).block_info.next = (*(*before).block_info.next).block_info.next;
        } else {
            (*target).block_info.next = (*before).block_info.next;
        }

        // check being able to link block which before target.
        if same_pointer( get_end_of_block(before), target ) {
            (*before).block_info.size += (*target).block_info.size;
            (*before).block_info.next = (*target).block_info.next;
        } else {
            (*before).block_info.next = target;
        }
    }
}

fn convert_blockptr_from_ptr<T>(ptr : Pointer<T>) -> *mut BlockHeader<'static> {
    (unsafe { ptr.adr } as u32 - HeaderSize) as *mut BlockHeader
}
fn convert_blockptr_from_ptr_test() {
    let p = Pointer { adr : 0x100 as *mut u8, sz : 0, ctrl_num : 0};
    assert_eq!(convert_blockptr_from_ptr(p) as u32 , (0x100 - HeaderSize) );
}

unsafe fn search_block_before_target(tg : *mut BlockHeader) -> *mut BlockHeader<'static> {
    let mut cur = BasePointer.clone();
    while !is_sandwitch(tg, cur) {
        // expect | cur | target | cur.next |
        // but, for instance target at last and so on, before or after must be no value. 
        // see C implement at http://mirror.fsf.org/pmon2000/2.x/src/lib/libc/malloc.c
        if let WhichBig::Right = compare_bigger_pointer((*cur).next(), cur) {
            // cur.next < cur. so target at last
            //print!("case 1 ");
            return cur;
        }
        cur = (*cur).next();
    }
    //print!("case 2 ");
    cur
}

fn search_block_before_target_test() {
    let ptr1 = malloc::<u8>(200); // break
    let ptr2 = malloc::<u8>(200); // break
    let ptr3 = malloc::<u8>(200); // break
    // create three block.

    let bef1 = unsafe { search_block_before_target(convert_blockptr_from_ptr(ptr1)) } ;
    let bef2 = unsafe { search_block_before_target(convert_blockptr_from_ptr(ptr2)) } ;
    let bef3 = unsafe { search_block_before_target(convert_blockptr_from_ptr(ptr3)) } ;
    //print!("0x{:x} ", bef1 as u32);
    //print!("0x{:x} ", bef2 as u32);
    //print!("0x{:x} ", bef3 as u32);
    assert_eq!(bef1 as u32, 0x210008);
    assert_eq!(bef2 as u32, 0x210108);
    assert_eq!(bef3 as u32, 0x210208);

}

fn is_sandwitch(ing : *mut BlockHeader, brd : *mut BlockHeader) -> bool {
    unsafe {
        if let (WhichBig::Right, WhichBig::Right) = 
            (
                compare_bigger_pointer(brd, ing),
                compare_bigger_pointer(ing, (*brd).next())
            ) { true } else { false }
    }
}

fn get_alloc_size(size : usize) -> u32 {    // usize is "pointer size". so begin return type usize is not suitable.
    (((size + size_of::<u64>() - 1) / size_of::<u64>()) + 1) as u32
    // cell(size + sizeof(header))
}

fn same_pointer<T,U>(x : *mut T, y : *mut U) -> bool {
    x as usize == y as usize
}
enum WhichBig {
    Left,
    Right,
    Equal,
}
fn compare_bigger_pointer<T,U>(x : *mut T, y : *mut U) -> WhichBig {
    let (xn, yn) : (usize, usize) = (x as usize, y as usize);
    if xn == yn {
        return WhichBig::Equal;
    } else if xn < yn {
        return WhichBig::Right;
    } else {
        return WhichBig::Left;
    }
}


pub fn memory_test() { 
    if unsafe { Test_Once } {
        return;
    }
    unsafe { Test_Once = true };
    
    convert_blockptr_from_ptr_test();
    search_block_before_target_test();  
    get_end_of_block_test();
}

pub fn malloc_free_test() {
    if unsafe { Test_Once } {
        return;
    }
    unsafe { Test_Once = true };

    let ptr1 = malloc::<u8>(200);
    let ptr2 = malloc::<u8>(200);
    let ptr3 = malloc::<u8>(200);

    free(ptr2);
}

pub fn null_pointer<T>() -> Pointer<T> {
    Pointer {
        adr : 0 as *mut T,
        sz : 0,
        ctrl_num : 0,
    }
}

fn new_line() {
    unsafe { super::MyTerminal1.new_line(); }
}

