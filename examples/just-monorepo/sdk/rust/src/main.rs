use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() > 1 {
        println!("Hello from Rust SDK! You said: {}", args[1]);
    } else {
        println!("Hello from Rust SDK!");
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_example() {
        let want = "test";
        let got = "test";
        assert_eq!(got, want);
    }
}
