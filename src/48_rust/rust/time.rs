use core::fmt::Write;
use super::vec::{Vec, VecElement};
use super::alloc::{Pointer};

macro_rules! print {
    ($($arg:tt)*) => (unsafe { write!(super::MyTerminal1,"{}",format_args!($($arg)*)) } );
}
fn new_line() {
    unsafe { super::MyTerminal1.new_line(); }
}

#[derive(Copy,Clone)]
struct Task {
    proc : fn() -> (),
    frec : u128,
}

struct Timer {
    tasks : Vec<Task>,
    count : u128,
}

impl Timer {
    pub fn subscribe(&mut self, task : Task) {
        self.tasks.push(task);
    }
    pub fn subscribe_with_task(&mut self, func : fn() -> (), frec : u128) {
        self.tasks.push( Task { proc : func, frec : frec } );
    }
    pub fn front(&mut self) {
        // execute per timer.
        self.count += 1;
        for p in self.tasks.to_iter() {
            if self.count % p.frec == 0 {
                (p.proc)();
            }
        }
    }
}

static mut main_timer : Option<Timer> = None;

pub fn init_timer() {
    unsafe {
        main_timer = Some(Timer {
            tasks : Vec::new(),
            count : 0,
        });
    }
    unsafe {
        //*super::RustTimerAddress = (main_timer.unwrap().front) as &fn() -> ();
    }
    return main_timer.unwrap().front;

}

fn test() {
}
