use core::mem::size_of;
use core::fmt::{self, Write};

static SizePerOneBreak : u32 = 256;
static HeaderSize : u32 = size_of::<u64>() as u32;
static mut IsValid : [bool;1024] = [false;1024];
static mut ControlNumber : usize = 0;

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
impl Clone for BlockHeader<'_> {
    fn clone(&self) -> Self {
        unsafe {
            super::MyTerminal1.write_str("call clone");
        }
        BlockHeader {
            block_info : unsafe { self.block_info.clone() },
        }
    }
}
pub struct Pointer<'a, T> {
    adr : ReferenceAndPointer<'a, T>,        // raw pointer.
    sz : usize,
    ctrl_num : usize,
}
union ReferenceAndPointer<'a, T> {
    rf : &'a mut T,
    rp : *mut T,
}

impl<'a, T> Pointer<'a, T> {
    pub fn at(&self,index : usize) -> &mut T {
        unsafe {
            ReferenceAndPointer {
                rp : (self.adr.rp as usize + index * size_of::<T>()) as *mut T
            }.rf
        }
    }
    fn new(rp : *mut u8, size : usize) -> Self {
        Self {
            adr : ReferenceAndPointer { rp : rp as *mut T},
            sz : size,
            ctrl_num : unsafe { ControlNumber }
        }
    }
}
impl<'a,T> fmt::Display for Pointer<'a,T> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        unsafe {
            return write!(f, "0x{:x},len : {},Valid : {}", self.adr.rp as u32 ,self.sz, IsValid[self.ctrl_num]);
        }
    }
}


static mut BasePointer : *mut BlockHeader = 0 as *mut BlockHeader;
static mut BreakPoint : *mut BlockHeader = 0 as *mut BlockHeader;

pub unsafe fn memory_init(heap_start : *mut u8) {
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

pub fn malloc<T>(size : usize) -> Pointer<'static, T> {
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
    if !unsafe {IsValid[pointer.ctrl_num] } {
        panic!("The pointer had been freed. {}", pointer);
    }
    // free
   
    unsafe {
        // find near space
        let target = pointer.adr.rp;
        let target_block = target as *mut BlockHeader;
        let (before, after) : (*mut BlockHeader,*mut BlockHeader);
        let last : bool;
        let (can_link_before, can_link_after) : (bool, bool);
        let (mut current,mut prev) = (BasePointer,0 as *mut BlockHeader);
        loop {
            match compare_bigger_pointer(current, target) {
                WhichBig::Equal => {
                    // target had beed already freed.
                    panic!("Target had beed already freed.");
                },
                WhichBig::Right => {
                    // not yet
                },
                WhichBig::Left => {
                    // found!
                    
                    current = (*current).block_info.next;
                    // now, prev is before, current is after.
                    
                    can_link_before = 
                        !same_pointer(prev, 0 as *mut BlockHeader) &&
                        // prev at 0, target at first position. so, if same, can_link = false.
                        same_pointer(get_end_of_block(prev), target);
                        // and prev must be next to target.

                    can_link_after = 
                        !same_pointer(current, BasePointer) &&
                        // "next is base" indicates, target at last potision
                        same_pointer(get_end_of_block(target_block), current);
                    last = false;
                    break;
                }
            }

            if same_pointer((*current).block_info.next, BasePointer) {
                // target at last position
                can_link_before = 
                    !same_pointer(prev, 0 as *mut BlockHeader) &&
                    // prev at 0, target at first position. so, if same, can_link = false.
                    same_pointer(get_end_of_block(prev), target);
                    // and prev must be next to target.
                
                can_link_after = false;
                last = true;
                break;
            }
            
            prev = current;
            current = (*current).block_info.next;
        }
    
        //write!(super::MyTerminal1, "free...{},{}",can_link_before, can_link_after); 
        write!(super::MyTerminal1,"{:x},{:x}",prev as u32,current as u32);
        super::MyTerminal1.new_line();


        if can_link_before && can_link_after {
            (*prev).block_info.size += (*target_block).block_info.size + (*current).block_info.size;
            (*prev).block_info.next = (*current).block_info.next;
        } else if can_link_before {
            (*prev).block_info.size += (*target_block).block_info.size;
        } else if can_link_after {
            (*prev).block_info.next = target_block;
            (*target_block).block_info.size += (*current).block_info.size;
        } else if last {
            (*current).block_info.next = target_block;
            (*target_block).block_info.next = BasePointer;
        } else {
            (*prev).block_info.next = target_block;
            (*target_block).block_info.next = current;
        }
        IsValid[pointer.ctrl_num] = false;
    }
}
pub fn get_alloc_size(size : usize) -> u32 {    // usize is "pointer size". so begin return type usize is not suitable.
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




