use std::env;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();

    if args.is_empty() {
        println!("Hello from Rust SDK!");
    } else {
        println!("Hello from Rust SDK! Args: {:?}", args);
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_hello() {
        // Simple test to verify the package compiles
        assert_eq!(2 + 2, 4);
        println!("Rust SDK test passed!");
    }
}
