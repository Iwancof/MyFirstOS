use core::fmt::{Write, Error};

use super:: {
    string::String,
    vec::Vec,
    keys::*,
    draw_char,
    draw_str,
    power_off,
};

pub const X_MAX : usize = 60;
pub const Y_MAX : usize = 30;

pub struct Terminal {
    writing_line : String,
    //history : Vec<String>,
    y : usize,  // cursor
    x_offset : usize,
    y_offset : usize,
    color : u16,
}

impl Terminal {
    pub fn new() -> Terminal {
        // defualt terminal at (0, 0)
        let ret = Terminal {
            writing_line : String::new(),
            //history : Vec::new(),
            y : 0,
            x_offset : 3,
            y_offset : 1,
            color : 0x000F,
        };
        ret.terminal_input_mode_init();
        ret
    }
    pub fn input_key(&mut self,mut d : u8) -> bool {
        // d is keycode.
        let is_release = (d & 0x80) == 0x80;
        d &= !0x80;
        if is_release {
            return (access_key_by_u8(d).release_func)(self);
        } else {
            let g = access_key_by_u8(d);
            let ch = (g.ch as u8 ^ unsafe { super::keys::KeyFlag }) as char;
            if g.is_char {
                write!(self, "{}", ch);
                return true;
            } else {
                return (g.control_func)(self);
            }
        }
    
    }
    pub fn terminal_enter(&mut self) -> bool {
        match self.execute_command() {
            CommandResult::Success(_) => {},
            CommandResult::Failed(_) => {},
            CommandResult::NotFound => {
                let ret = self.writing_line.iter().take_while(|x| *x != ' ' as u8).collect::<String>();
                self.new_line();
                write!(self, "{} : Command not found", ret);
                self.new_line();

            },
        }
        self.terminal_input_mode_init();
        true
    }
    pub fn execute_command(&mut self) -> CommandResult {
        // easy parse
        let cmd = self.writing_line.iter().take_while(|x| *x != ' ' as u8).collect::<String>();

        if cmd == String::from_str("") {
            self.new_line();
            return CommandResult::Success(0);
        }
        if cmd == String::from_str("help") {
            self.new_line();
            write!(self,"Command      | usage        | description");
            self.new_line();
            write!(self,"help         | help         | show help");
            self.new_line();
            write!(self,"shutdown     | shutdown     | power off this machine");
            self.new_line();
            write!(self,"clear        | clear        | clear terminal");
            self.new_line();
            return CommandResult::Success(0);
        }
        if cmd == String::from_str("shutdown") {
            power_off();
            return CommandResult::Success(0);
        }
        if cmd == String::from_str("clear") {
            // init monitor
            for i in 0..self.y+1 {
                for j in 0..X_MAX+1 {
                    draw_char(j + self.x_offset + 0, i + self.y_offset, 0x0000, ' ' as u8);
                }
            }

            // init_variables
            self.writing_line = String::new();
            self.y = 0;
            
            return CommandResult::Success(0);
        }
        CommandResult::NotFound
    }
    fn new_line(&mut self) {
        // for debug
        self.y += 1;
        self.writing_line = String::new();
    }
    fn delete(&mut self, count : usize) -> bool {
        if self.writing_line.len() < count {
            return false;
        }
        for _ in 0..count {
            self.writing_line.pop();
        }
        for _ in 0..count {
            self.writing_line.push_str(" ");
        }
        self.re_draw();
        for _ in 0..count {
            self.writing_line.pop();
        }
        self.re_draw();
        true
    }
    pub fn back_space(&mut self) -> bool {
        self.delete(1)
    }

    fn re_draw(&self) {
        for (i, v) in self.writing_line.iter().enumerate() {
            draw_char(i + self.x_offset + 1, self.y + self.y_offset, self.color, v);
        }
    }
    pub fn terminal_input_mode_init(&self) {
        draw_char(0 + self.x_offset + 0, self.y + self.y_offset, self.color, '>' as u8);
    }
}

impl Write for Terminal {
    fn write_str(&mut self, s: &str) -> Result<(),Error> {
        self.writing_line.push_str(s);
        self.re_draw();
        Ok(())
    }
}

pub enum CommandResult {
    Success(i32),
    Failed(i32),
    NotFound,
}
