---
title: A Bullet list about Rust
tags:
  - Rust
date: "2024-08-27"
---

I feel like, once in a while, I stumble upon Rust programming features or something that needs to be made in Rust. This wasn't happen just once, but I have never actually got the time to sit and list down a few important Rust programming characteristics. This time was different. I decided to write it down so that I could remember later on (and if the pattern repeats!).

---

> Variables are always declared as: `<let> : <type> = <value>`.

Just an easy to grasp rule.

---

> Mut stands for _mutable_ and not for _is it indeed stored in the heap memory_.

```Rust
let a: u32 = 1;     // Goes into the stack
let mut b: u32 = 1; // Goes into the stack

let y = Box::new(10); // Goes: integer '10' in the heap, y on the stack
let mut y = Box::new(10); // Goes: integer '10' in the heap, y on the stack
```

Integers can be immutable or mutable but its size is defined beforehand, therefore the variables are stored in the stack. Dinamically created variables, with types such as `Box`, are not.

---

> Arrays are declared as [T; length].

This might look odd, but Rust always shortens the type for some reason. T stands for type and can be replaced by u32, f64, etc.

---

> Strings in Rust store their length as metadata and are not dependent of a null terminator.

As someone who comes from C, this is a big thing. Strings are stored as:

- Pointer to data (what is considered as text)
- Capacity (the maximum length of the string)
- Length (the actual length of a string)

```Rust
let mut s = String::new();

println!("Capacity -> {}", s.capacity());
```

```md
% Capacity -> 0
```


---

> Strings support emojis 🤝🤌😤

This is a weird one for me. How come? Apparently, [Strings are UTF-8 encoded](https://doc.rust-lang.org/std/string/index.html).

```Rust
let emoji = String::from("💀");
let bytes = emoji.into_bytes();

println!("Emoji {} can be read as {:?}", "💀", bytes);
```

```md
% Emoji 💀 can be read as [240, 159, 146, 128]
```

---

> Strings are moved, but integers are copied!

Due to the borrow checker rules, the Strings are actually moved to another scope, but the integers are just copied.

```Rust
fn main() {
  let text = String::from("This text");
  let number = 1;

  print_a_number(number); // Works
  print_a_number(number); // Works

  print_a_string(text); // Works
  print_a_string(text); // Doesn't work!
}

fn print_a_number(a: i32) {
  // `a` is a copy of `number`
  println!("Print the number {}", a);
}

fn print_a_string(a: String) {
  // `text` was moved to `a`
  println!("Print the string {}", a);
}
```

---

> The compiler inserts `drop(T)` at the end of the scope.

Drop does not nothing, yet matters:

```Rust
pub fn drop<T>(_x: T) {}
```

Quoting the documentation:

> This function is not magic;

And it is not, it takes an argument and does nothing. Also does't return anything. However, due to Rust borrow checker, the argument once copied, will cease to exist.

```Rust
fn main() {
  let text = String::from("This text");

  drop(text);
  print_a_string(text); // Doesn't work
}

fn print_a_string(a: String) {
  println!("Print the string {}", a);
}
```

```md
error[E0382]: use of moved value: `text`
 --> src/main.rs:7:18
  |
4 |   let text = String::from("This text");
  |       ---- move occurs because `text` has type `String`, which does not implement the `Copy` trait
5 |
6 |   drop(text);
  |        ---- value moved here
7 |   print_a_string(text); // Doesn't work
  |                  ^^^^ value used here after move
```



