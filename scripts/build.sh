#!/bin/bash
# Rust Chatbot - Manual Build Script for Unix/Linux/macOS
# Author: ARYPROGRAMMER
# Run: chmod +x scripts/build.sh && ./scripts/build.sh

set -e

echo "🔨 Building Rust Chatbot..."

# Build WASM
echo -e "\n[1/4] Building WASM library..."
cargo build --lib --target wasm32-unknown-unknown --features hydrate --no-default-features
echo "✅ WASM built"

# Generate JS bindings
echo -e "\n[2/4] Generating JS bindings..."
mkdir -p target/site/pkg
wasm-bindgen --target web --out-dir target/site/pkg --out-name rust-chatbot target/wasm32-unknown-unknown/debug/rust_chatbot.wasm
echo "✅ JS bindings generated"

# Copy CSS
echo -e "\n[3/4] Copying styles..."
cp style/main.scss target/site/pkg/rust-chatbot.css
if [ -f "assets/favicon.ico" ]; then
    cp assets/favicon.ico target/site/
fi
echo "✅ Styles copied"

# Build server
echo -e "\n[4/4] Building server..."
cargo build --bin rust-chatbot --features ssr --no-default-features
echo "✅ Server built"

echo -e "\n✨ Build complete!"
echo -e "\nRun with: ./target/debug/rust-chatbot"
echo "Then open http://127.0.0.1:3000"
