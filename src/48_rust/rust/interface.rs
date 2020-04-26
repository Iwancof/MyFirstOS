
use super::{outb, inb};
use core::fmt::Write;

const COM1 : u16 = 0x3F8;
const COM2 : u16 = 0x2F8;
const COM3 : u16 = 0x3E8;
const COM4 : u16 = 0x2E8;

const StatusRegisterOffset : u16 = 5;

pub static mut PortBuffer : RingBuffer = RingBuffer { buff : [0;256], rp : 0, wp : 0 };
const BufferSize : usize = 256;

pub struct RingBuffer {
    buff : [u8;BufferSize],
    rp : usize,
    wp : usize,
}
impl RingBuffer {
    pub fn write(&mut self, d : u8) -> Result<(), usize> {
        if self.wp + 1 % BufferSize == self.rp {
            return Err(self.wp);
        }
        self.buff[self.wp] = d;
        self.wp += 1;
        self.wp %= BufferSize;
        Ok(())
    }
    pub fn read(&mut self) -> Result<u8, usize> {
        if self.wp == self.rp {
            return Err(self.wp);
        }
        let ret = self.buff[self.rp];
        self.rp += 1;
        self.rp %= BufferSize;
        Ok(ret)
    }
}



pub fn polling_comport() {
    if inb(COM1 + StatusRegisterOffset) & 0x01 == 0 {
        return;
    }
    unsafe {
        PortBuffer.write(inb(COM1));
    }
}

pub fn stdio_test() {
     while inb(COM1 + StatusRegisterOffset) & 0x1 == 0 { ; }
     let data = inb(COM1);
     print!("{}",data as char);

     while inb(COM1 + StatusRegisterOffset) & 0x20 == 0 { ; }
     outb(COM1, data ^ 0x20) ;
}
