# Rust Chatbot

A full-stack web application built with [Leptos](https://leptos.dev/) and [Actix Web](https://actix.rs/), featuring server-side rendering (SSR) with client-side hydration.

## Features

- 🦀 **Rust Full-Stack** - Both server and client written in Rust
- ⚡ **Server-Side Rendering** - Fast initial page loads with SSR
- 💧 **Hydration** - Seamless client-side interactivity via WebAssembly
- 🎨 **SCSS Styling** - Modern styling with Sass
- 🔄 **Reactive UI** - Fine-grained reactivity with Leptos signals

## Prerequisites

- [Rust](https://rustup.rs/) (stable)
- [cargo-leptos](https://github.com/leptos-rs/cargo-leptos): `cargo install cargo-leptos`
- [wasm-bindgen-cli](https://rustwasm.github.io/wasm-bindgen/): `cargo install wasm-bindgen-cli`
- WASM target: `rustup target add wasm32-unknown-unknown`

## Quick Start

### Option 1: Using cargo-leptos (Recommended)

```bash
cd rust-chatbot
cargo leptos serve
```

This builds both WASM and server, then runs the dev server with hot reload at http://127.0.0.1:3000

For production build:

```bash
cargo leptos build --release
```

### Option 2: Manual Build

If cargo-leptos has issues, use these steps:

```bash
# 1. Build WASM
cargo build --lib --target wasm32-unknown-unknown --features hydrate --no-default-features

# 2. Generate JS bindings
wasm-bindgen --target web --out-dir target/site/pkg --out-name rust-chatbot target/wasm32-unknown-unknown/debug/rust_chatbot.wasm

# 3. Copy CSS
cp style/main.scss target/site/pkg/rust-chatbot.css

# 4. Build server
cargo build --bin rust-chatbot --features ssr --no-default-features

# 5. Run
./target/debug/rust-chatbot
```

Then open http://127.0.0.1:3000

## Project Structure

```
rust-chatbot/
├── src/
│   ├── app.rs      # Main application component
│   ├── lib.rs      # WASM hydration entry point
│   └── main.rs     # Server entry point
├── style/
│   └── main.scss   # Styles
├── assets/         # Static assets
├── end2end/        # Playwright e2e tests
├── Cargo.toml      # Dependencies and metadata
└── README.md
```

## Running Tests

```bash
cd end2end
npm install
npx playwright test
```

## Troubleshooting

**wasm-bindgen version mismatch:**

Make sure the CLI version matches your `Cargo.toml` dependency:

```bash
wasm-bindgen --version
cargo tree -p wasm-bindgen
```

If they differ, install the matching CLI version:

```bash
cargo install wasm-bindgen-cli --version <VERSION>
```

## Author

**ARYPROGRAMMER**

## License

This project is released into the public domain under the [Unlicense](LICENSE).

See the [LICENSE](LICENSE) file for details.
