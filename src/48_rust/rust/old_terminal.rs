use core::fmt::Write;

use super::{draw_char, power_off};

pub const X_MAX : usize = 60;
pub const Y_MAX : usize = 30;

static mut Keys : [KeyInfo;256] = [KeyDefault;256];

static KeyDefault : KeyInfo = KeyInfo{ch : '-',is_char : true, control_func : default_key_inp};

impl Write for Terminal {
    fn write_str(&mut self, s : &str) -> Result<(),core::fmt::Error> {
        let chars = s.as_bytes();
        for i in 0..s.len() {
            draw_char(self.x + self.x_offset + 1, self.y, self.color, chars[i]);
            self.x += 1;
        };
        if X_MAX < self.x {
            Err(core::fmt::Error)
        } else {
            Ok(())
        }
    }
}
pub struct Terminal {
    writing_line : String,
    history : Vec<String>,

    //pub form : [char;X_MAX],
    pub x : usize,
    pub y : usize,
    pub x_offset : usize,
    pub y_offset : usize,
    pub color : u16,
}

impl Terminal {
    // Control keys processes here. and convert to char
    pub fn input_key(&mut self, d : u8) -> bool {
        let get = access_key_by_u8(d);  // convert
        if get.is_char {                // control or char
            return self.input_char(access_key_by_u8(d).ch);
        };
        (get.control_func)(self)        // execute this key's function
    }
    pub fn input_char(&mut self, c : char) -> bool {
        //self.form[self.x] = c;
        self.writing_line.push_char(c);
        write!(self,"{}",c);
        true
    }
    fn terminal_enter(&mut self) -> bool {
        match self.execute_command() {
            CommandResult::Success(ret) => { },
            CommandResult::Failed(ret) => { },
            CommandResult::NotFound(len) => { 
                self.new_line();
                write!(self,"{} : Command not found.", writing_line);
            },
            CommandResult::Unknown => {
                self.new_line();
                write!(self,"Unknown error eccured.");
                panic!("termianl unknown error");
            },
        }
        // execute string(array and length pair)

        // after enter
        self.new_command_line();

        true
    }
    pub fn init_terminal(term : &mut Terminal) {
        term.new_command_line();
    }
    fn execute_command(&mut self) -> CommandResult {
        /*
        let mut command_last = self.x;
        for c in 0..self.x {
            if self.form[c] == ' ' {
                command_last = c;
                break;
            }
        }
        
        let cmp_func = Self::get_compare_array_func(self.form, command_last);

        if cmp_func("") {
            return CommandResult::Success(-1);
        }
        if cmp_func("help") {
            self.new_line();
            write!(self,"Command      | usage        | description");
            self.new_line();
            write!(self,"help         | help         | show help");
            self.new_line();
            write!(self,"shutdown     | shutdown     | power off this machine");
            return CommandResult::Success(1);
        }
        if cmp_func("clear") {
            for i in 0..self.y+1 {
                for j in 0..X_MAX {
                    draw_char(j + self.x_offset + 0, i + self.y_offset , 0x0000, ' ' as u8);
                }
            }
            self.x = 0;
            self.y = 0;
            return CommandResult::Success(1);
        }
        if cmp_func("shutdown") {
            power_off();
            return CommandResult::Success(0);
        }
        //default
        CommandResult::NotFound(command_last)
        
        */
        CommandResult::Unknown
    }
    fn back_space(&mut self) -> bool {
        if self.x == 0 {
            return false;
        }
        self.x -= 1;
        write!(self,"{}",' ');
        self.x -= 1;
        self.writing_line.pop();
        true
    }
    fn get_compare_array_func(string : [char;X_MAX], lim : usize) -> impl Fn(&str) -> bool {
        move |s : &str | -> bool {
            if s.len() != lim {
                return false;                   // length not match
            }
            let mut counter = 0;
            for c in s.chars() {
                if string[counter] != c {
                    return false;               // not match
                }
                counter += 1;
            }
            true                                // match
        }
    }
    pub fn new_line(&mut self) {                    // move to new line
        self.y += 1;
        if Y_MAX < self.y {
            panic!();                           // TODO fix
        }
        self.x = 0;
        self.writing_line = String::new();
    }
    fn new_command_line(&mut self) {            // move to new line and draw '>'
        self.new_line();
        draw_char(self.x + self.x_offset + 0,self.y,self.color,'>' as u8);
    }
    fn escape(&mut self) -> bool {
        false
    }
}

enum CommandResult {
    Success(i32),
    Failed(i32),
    NotFound(usize),
    Unknown,
}

