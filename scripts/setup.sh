#!/bin/bash
# Rust Chatbot - Setup Script for Unix/Linux/macOS
# Author: ARYPROGRAMMER
# Run: chmod +x scripts/setup.sh && ./scripts/setup.sh

set -e

echo "🦀 Rust Chatbot Setup Script"
echo "============================="

# Check if Rust is installed
echo -e "\n📦 Checking Rust installation..."
if ! command -v rustc &> /dev/null; then
    echo "❌ Rust not found. Please install from https://rustup.rs/"
    exit 1
fi

rust_version=$(rustc --version)
echo "✅ Found: $rust_version"

# Install nightly toolchain and WASM target
echo -e "\n📦 Setting up Rust nightly toolchain..."
rustup install nightly
rustup default nightly
rustup target add wasm32-unknown-unknown

# Get wasm-bindgen version from Cargo.lock or cargo tree
echo -e "\n📦 Checking wasm-bindgen version..."
if [ -f "Cargo.lock" ]; then
    wasm_bindgen_version=$(grep -A1 'name = "wasm-bindgen"' Cargo.lock | grep version | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
fi

if [ -z "$wasm_bindgen_version" ]; then
    wasm_bindgen_version=$(cargo tree -p wasm-bindgen 2>/dev/null | grep "wasm-bindgen v" | head -1 | sed 's/.*v\([0-9.]*\).*/\1/')
fi

if [ -z "$wasm_bindgen_version" ]; then
    wasm_bindgen_version="0.2.108"
    echo "⚠️  Could not detect version, using default: $wasm_bindgen_version"
else
    echo "📌 wasm-bindgen version in project: $wasm_bindgen_version"
fi

# Install wasm-bindgen-cli
echo -e "\n📦 Installing wasm-bindgen-cli v$wasm_bindgen_version..."
installed_version=$(wasm-bindgen --version 2>/dev/null | sed 's/wasm-bindgen //' || echo "")
if [ "$installed_version" = "$wasm_bindgen_version" ]; then
    echo "✅ wasm-bindgen-cli v$wasm_bindgen_version already installed"
else
    cargo install wasm-bindgen-cli --version "$wasm_bindgen_version" --force
    echo "✅ wasm-bindgen-cli v$wasm_bindgen_version installed"
fi

# Install cargo-leptos
echo -e "\n📦 Installing cargo-leptos..."
if command -v cargo-leptos &> /dev/null; then
    leptos_version=$(cargo leptos --version)
    echo "✅ Found: $leptos_version"
else
    echo "Installing cargo-leptos (this may take a few minutes)..."
    cargo install cargo-leptos
    echo "✅ cargo-leptos installed"
fi

# Install Node.js dependencies for e2e tests (optional)
echo -e "\n📦 Setting up e2e tests (optional)..."
if [ -f "end2end/package.json" ]; then
    if command -v npm &> /dev/null; then
        cd end2end
        npm install
        npx playwright install
        cd ..
        echo "✅ E2E test dependencies installed"
    else
        echo "⚠️  npm not found, skipping e2e setup"
    fi
fi

# Create necessary directories
echo -e "\n📁 Creating build directories..."
mkdir -p target/site/pkg
echo "✅ Directories created"

echo -e "\n✨ Setup complete!"
echo -e "\nTo run the project:"
echo "  cargo leptos serve"
echo -e "\nOr manually:"
echo "  ./scripts/build.sh"
echo "  ./target/debug/rust-chatbot"
echo -e "\nThen open http://127.0.0.1:3000"
