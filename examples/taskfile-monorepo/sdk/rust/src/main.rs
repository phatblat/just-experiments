use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() > 1 {
        println!("Hello from Rust SDK! Args: {:?}", &args[1..]);
    } else {
        println!("Hello from Rust SDK!");
    }
    println!("Version: 1.0.0");
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
