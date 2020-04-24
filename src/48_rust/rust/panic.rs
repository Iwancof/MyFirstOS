use core::fmt::{Write,write};
use core::panic::PanicInfo;


union StringToPointer<'a> {
    string : &'a str,
    pointer : *mut u8,
}
struct WrapOfMemcpyToGlobal { }
impl<'a> Write for WrapOfMemcpyToGlobal {
    fn write_str(&mut self, s : &str) -> Result<(),core::fmt::Error> {
        unsafe {
            super::memcpy(super::PanicMessagePointer,StringToPointer{string : s}.pointer,s.len());
        }
        Ok(())
    }
}
unsafe fn write_default_panic_message() {
    let panic_message = "Unknown panic\0";
    super::memcpy(super::PanicMessagePointer,StringToPointer{string : panic_message}.pointer, panic_message.len());
}

// asm_panic is implement by assembly in kernel. show panic_handler.s
#[panic_handler]
unsafe extern fn panic_handler(info : &PanicInfo<'_>) -> ! { 
    match info.message() {
        Some(args) => {
            print!("{}", args);
            match write( &mut WrapOfMemcpyToGlobal{}, *args) {
                Ok(_) => {} ,
                Err(_) => { write_default_panic_message() },
            }
        },
        None => { write_default_panic_message() },
    }
    //let mut panic_message : TestStruct = TestStruct { };
    //fmt::write(&mut panic_message, info.message());
    super::asm_panic()
}
