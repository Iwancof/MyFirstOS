use core::fmt::Write;
use super::vec::{Vec, VecElement};
use super::alloc::{Pointer};

static mut MainTimer : Option<Timer> = None;


#[derive(Copy,Clone)]
pub struct Task {
    proc : fn() -> (),
    frec : u128,
}

pub struct Timer {
    tasks : Vec<Task>,
    count : u128,
}

impl Timer {
    fn subscribe_with_task(&mut self, task : Task) {
        self.tasks.push(task);
    }
    fn subscribe(&mut self, func : fn() -> (), frec : u128) {
        self.tasks.push( Task { proc : func, frec : frec } );
    }
    fn front(&mut self) {
        // execute per timer.
        self.count += 1;
        for p in self.tasks.iter() {
            //print!("{}", self.count % p.frec);
            if (self.count % p.frec) == 0 {
                (p.proc)();
            }
        }
    }
}


pub fn init_timer() {
    unsafe {
        MainTimer = Some(Timer {
            tasks : Vec::new(),
            count : 0,
        });
        *super::RustTimerAddress = kernel_timeint_front;
    }
}

fn kernel_timeint_front() {
    unsafe {
        if let Some(x) = &mut MainTimer {
            x.front();
        }
    }
}

#[no_mangle]
extern fn __umodti3(mut diend : u128, mut disor : u128) -> u128 {
    while disor <= diend {
        diend -= disor
    }

    diend
}
#[no_mangle]
extern fn __udivti3(mut diend : u128, mut disor : u128) -> u128 {
    panic!("Call udivti3");
    0
}

/*
#[no_mangle]
extern fn __udivti3(mut diend : u128, mut disor : u128) -> u128 {
    if disor ==  0 {
        panic!("0 div");
        unsafe {
            asm!("int   eax" : "={eax}"(0) : : : "intel" );
        }
    }
    let mut ret : u128 = 0;
    loop {
        if diend < disor {
            //return ret;
            return 1234;
        }
        
        diend -= disor;
        ret += 1;
    }
}
*/

pub fn subscribe_with_task(task : Task) {
    unsafe {
        if let Some(x) = &mut MainTimer {
            x.tasks.push(task);
        } else {
            panic!("rust timer uninitialized");
        }
    }
}
pub fn subscribe(func : fn() -> (), frec : u128) {
    unsafe {
        if let Some(x) = &mut MainTimer {
            x.tasks.push( Task { proc : func, frec : frec } );
        } else {
            panic!("rust timer uninitialized");
        }
    }
}
