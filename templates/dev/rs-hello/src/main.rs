fn main() {                                              
    println!("Hello, world!");
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_hello_world() {
        assert!(true);
    }
}
