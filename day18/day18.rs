use lazy_static::lazy_static;
use regex::Regex;

use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;
use std::ptr;

pub struct Data {
    last_number: *mut Value,
    add_to_number: u8,
    modified: bool
}

impl Data {
    pub fn new() -> Data {
        Data {
            last_number: ptr::null_mut(),
            add_to_number: 0,
            modified: false
        }
    }
}

#[derive(Clone)] 
pub enum Value {
    Number(u8),
    Pair(Pair),
}

impl Value {
    pub fn to_int(&self) -> u8 {
        match self {
            Value::Number(i) => *i,
            Value::Pair(_) => panic!("Not an u8."),
        }
    }

    pub fn get_left_num(&self) -> u8 {
        match self {
            Value::Number(_) => panic!("Not a pair."),
            Value::Pair(p) => p.left_value.to_int(),
        }
    }

    pub fn get_right_num(&self) -> u8 {
        match self {
            Value::Number(_) => panic!("Not a pair."),
            Value::Pair(p) => p.right_value.to_int(),
        }
    }

    pub fn add(&mut self, val: u8) {
        match self {
            Value::Number(i) => {
                *i += val;
            },
            Value::Pair(_) => panic!("Not an u8."),
        }
    }

    pub fn explode(&mut self, info: &mut Data) -> bool {
        match self {
            Value::Number(_) => panic!("Cannot explode a number."),
            Value::Pair(p) => p.explode(info),
        }
    }

    pub fn split(&mut self, info: &mut Data) -> bool {
        match self {
            Value::Number(_) => panic!("Cannot call split method on a number."),
            Value::Pair(p) => p.split(info),
        }
    }

    pub fn fix_depth(&mut self, depth: u8) {
        match self {
            Value::Number(_) => panic!("Cannot call fix_depth method on a number."),
            Value::Pair(p) => {
                p.depth = depth + 1;
                p.fix_depth();
            }
        }
    }

    pub fn calc(&self) -> u32 {
        match self {
            Value::Number(_) => panic!("Cannot call calc method on a number."),
            Value::Pair(p) => p.calc(),
        }
    }

}

pub fn to_string(val: &Value) -> String {
    match val {
        Value::Number(n) => n.to_string(),
        Value::Pair(p) => p.to_string(),
    }
}

pub fn is_pair(val: &Value) -> bool {
    match val {
        Value::Number(_) => false,
        Value::Pair(_) => true,
    }
}

pub fn is_num(val: &Value) -> bool {
    match val {
        Value::Number(_) => true,
        Value::Pair(_) => false,
    }
}

pub fn is_pair_of_nums(val: &Value) -> bool {
    match val {
        Value::Number(_) => false,
        Value::Pair(p) => is_num(&p.left_value) && is_num(&p.right_value),
    }
}

#[derive(Clone)] 
pub struct Pair {
    left_value: Box<Value>,
    right_value: Box<Value>,
    depth: u8
}

impl Pair {
    pub fn to_string(&self) -> String {
        return String::from("[") + &to_string(&*(self.left_value)) + &String::from(",") + &to_string(&*(self.right_value)) + &String::from("]");
    }

    pub fn explode(&mut self, info: &mut Data ) -> bool {
        /*
         * Left Side
         */
        let mut ret_value = false;
        if !info.modified && self.depth == 4 {
            if is_pair_of_nums(&*(self.left_value)) {
                if info.last_number != ptr::null_mut() {
                    unsafe { (*(info.last_number)).add(self.left_value.get_left_num().into()) };
                }

                info.add_to_number = self.left_value.get_right_num();
                info.modified = true;
                self.left_value = Box::new(Value::Number(0));
                info.last_number = &mut *(self.left_value);
                ret_value = true;
            } 
        }

        // if left side is a number, add to it, otherwise keep cascading
        if !ret_value {
            if info.add_to_number > 0 && is_num(&*(self.left_value)) {
                self.left_value.add(info.add_to_number);
                info.add_to_number = 0;
            }

            if is_num(&*(self.left_value)) {
                info.last_number = &mut *(self.left_value);
            } else {
                ret_value |= (*(self.left_value)).explode(info);
            }
        }

        /*
         * Right Side
         */
        if !info.modified && self.depth == 4 {
            if is_pair_of_nums(&*(self.right_value)) {
                if info.last_number != ptr::null_mut() {
                    unsafe { (*(info.last_number)).add( self.right_value.get_left_num().into() ) };
                }

                info.add_to_number = self.right_value.get_right_num();
                info.modified = true;
                self.right_value = Box::new(Value::Number(0));
                info.last_number = &mut *(self.right_value);
                // rhs, nothing else to do in this pair.
                return true;
            }
        }

        // if there's still anything to add, do it to the right side.
        if info.add_to_number > 0 && is_num(&*(self.right_value)) {
            self.right_value.add(info.add_to_number);
            info.add_to_number = 0;
        }

        if is_num(&*(self.right_value)) {
            info.last_number = &mut *(self.right_value);
        } else {
            ret_value |= self.right_value.explode(info);
        }

        return ret_value;
    }

    pub fn split(&mut self, info: &mut Data ) -> bool {
        /*
         * Left Side
         */
        let mut ret_value = false;
        if !info.modified && is_num(&*(self.left_value)) {
            let num = self.left_value.to_int() as f32;
            if num > 9.0 {
                self.left_value = Box::new(Value::Pair( Pair{
                    left_value: Box::new(Value::Number((num / 2.0).floor() as u8)),
                    right_value: Box::new(Value::Number((num / 2.0).ceil() as u8)),
                    depth: self.depth + 1,
                }));
                ret_value = true;
                info.modified = true;
            }
        }

        if !info.modified && is_pair(&*(self.left_value)) {
            ret_value |= self.left_value.split(info);
        }

        if !info.modified && is_num(&*(self.right_value)) {
            let num = self.right_value.to_int() as f32;
            if num > 9.0 {
                self.right_value = Box::new(Value::Pair( Pair{
                    left_value: Box::new(Value::Number((num / 2.0).floor() as u8)),
                    right_value: Box::new(Value::Number((num / 2.0).ceil() as u8)),
                    depth: self.depth + 1,
                }));
                ret_value = true;
                info.modified = true;
            }
        }

        if !info.modified && is_pair(&*(self.right_value)) {
            ret_value |= self.right_value.split(info);
        }

        return ret_value;
    }

    pub fn fix_depth(&mut self) {
        if is_pair(&*(self.left_value)) {
            self.left_value.fix_depth(self.depth);
        }

        if is_pair(&*(self.right_value)) {
            self.right_value.fix_depth(self.depth);
        }
    }

    pub fn calc(&self) -> u32 {
        let mut total : u32 = 0;
        if is_num(&*(self.left_value)) {
            total += (3 * self.left_value.to_int()) as u32;
        }

        if is_pair(&*(self.left_value)) {
            total += 3 * self.left_value.calc();
        }

        if is_num(&*(self.right_value)) {
            total += (2 * self.right_value.to_int()) as u32;
        }

        if is_pair(&*(self.right_value)) {
            total += 2 * self.right_value.calc();
        }

        return total;
    }
}


fn parse(text: String, level: Option<u8>) -> Pair {
    lazy_static! {
        static ref RE: Regex = Regex::new(r"^\[([\[\]0-9,]+),([\[\]0-9,]+)\]$").unwrap();
    }

    if !RE.is_match(&text[..]) {
        panic!("This is no goddam pair: '{}'", text);
    }

    let pair_depth = level.unwrap_or(1);

    let left_is_value: bool = text.chars().nth(1).unwrap() != '[';
    let right_is_value: bool = text.chars().nth(text.len() - 2).unwrap() != ']';
    let mut middle: usize = 0;
    let mut depth: u8 = 0;
    for (i, c) in text.chars().enumerate() {
        if c == '[' {
            depth += 1;
        }

        if c == ']' {
            depth -= 1;
        }

        if c == ',' && depth == 1 {
            middle = i;
            break;
        }
    }

    let first = &text[1..middle];
    let last = &text[middle + 1..text.len() - 1];

    Pair {
        left_value: Box::new(
            if left_is_value {
                Value::Number(first.parse::<u8>().unwrap())
            } else {
                Value::Pair(parse(String::from(first), Some(pair_depth + 1)))
            }),
        right_value: Box::new(
            if right_is_value {
                Value::Number(last.parse::<u8>().unwrap())
            } else {
                Value::Pair(parse(String::from(last), Some(pair_depth + 1)))
            }),
        depth: pair_depth
    }
}

fn reduce(pair: &mut Pair) {
    loop {
        if pair.explode(&mut Data::new()) {
            continue;
        }

        if pair.split(&mut Data::new()) {
            continue;
        }

        break;
    }

}
fn add(lhs: &Pair, rhs: &Pair) -> Pair {
    let mut new_pair = Pair {
        left_value: Box::new(Value::Pair(lhs.clone())),
        right_value: Box::new(Value::Pair(rhs.clone())),
        depth: 1
    };

    new_pair.fix_depth();
    return new_pair;
}

// The output is wrapped in a Result to allow matching on errors
// Returns an Iterator to the Reader of the lines of the file.
fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where P: AsRef<Path>, {
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}

fn main() {
    let mut v: Vec<Pair> = Vec::new();

    if let Ok(lines) = read_lines("input.txt") {
        // Consumes the iterator, returns an (Optional) String
        for line in lines {
            if let Ok(ip) = line {
                v.push(parse(ip, None));
            }
        }
    }

    let mut pair: Pair = v[0].clone();
    for n in 1..v.len() {
        pair = add(&pair, &v[n]);
        reduce(&mut pair);
    }

    println!("Day 18, part 1: {}", pair.calc());

    let mut max: u32 = 0;
    for i in 0..v.len() {
        for j in 0..v.len() {
            if i == j {
                continue;
            }

            pair = add(&v[i], &v[j]);
            reduce(&mut pair);
            if pair.calc() > max {
                max = pair.calc();
            }
        }
    }

    println!("Day 18, part 2: {}", max);

    /*
    println!("\nExample #1");
    let mut l = parse(String::from("[[[[[9,8],1],2],3],4]"), None);
    println!("-> {}", l.to_string());
    l.explode(&mut Data::new());
    println!("-> {}", l.to_string());

    println!("\nExample #2");
    l = parse(String::from("[7,[6,[5,[4,[3,2]]]]]"), None);
    println!("-> {}", l.to_string());
    l.explode(&mut Data::new());
    println!("-> {}", l.to_string());

    println!("\nExample #3");
    l = parse(String::from("[[6,[5,[4,[3,2]]]],1]"), None);
    println!("-> {}", l.to_string());
    l.explode(&mut Data::new());
    println!("-> {}", l.to_string());

    println!("\nExample #4");
    l = parse(String::from("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]"), None);
    println!("-> {}", l.to_string());
    l.explode(&mut Data::new());
    println!("-> {}", l.to_string());

    println!("\nExample #5");
    l = parse(String::from("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]"), None);
    println!("-> {}", l.to_string());
    l.explode(&mut Data::new());
    println!("-> {}", l.to_string());

    println!("\nExample #6");
    l = parse(String::from("[[15,2],23]"), None);

    let mut flag: bool = true;
    while flag {
        let mut modified = l.explode(&mut Data::new());
        if modified { continue; }
        modified = l.split(&mut Data::new());
        if modified { continue; }

        flag = false;
        
    }
    println!("-> {}", l.to_string());

    l = add(parse(String::from("[1,[2,[3,4]]]"), None),
            parse(String::from("[[[6,7],8],9]"), None));
    println!("-> {}", l.to_string());
*/
}
