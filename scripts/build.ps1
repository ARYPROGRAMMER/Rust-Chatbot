# Rust Chatbot - Manual Build Script for Windows (PowerShell)
# Author: ARYPROGRAMMER
# Run: .\scripts\build.ps1

$ErrorActionPreference = "Stop"

Write-Host "🔨 Building Rust Chatbot..." -ForegroundColor Cyan

# Build WASM
Write-Host "`n[1/4] Building WASM library..." -ForegroundColor Yellow
cargo build --lib --target wasm32-unknown-unknown --features hydrate --no-default-features
Write-Host "✅ WASM built" -ForegroundColor Green

# Generate JS bindings
Write-Host "`n[2/4] Generating JS bindings..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "target/site/pkg" | Out-Null
wasm-bindgen --target web --out-dir target/site/pkg --out-name rust-chatbot target/wasm32-unknown-unknown/debug/rust_chatbot.wasm
Write-Host "✅ JS bindings generated" -ForegroundColor Green

# Copy CSS
Write-Host "`n[3/4] Copying styles..." -ForegroundColor Yellow
Copy-Item style/main.scss target/site/pkg/rust-chatbot.css -Force
if (Test-Path "assets/favicon.ico") {
    Copy-Item assets/favicon.ico target/site/ -Force
}
Write-Host "✅ Styles copied" -ForegroundColor Green

# Build server
Write-Host "`n[4/4] Building server..." -ForegroundColor Yellow
cargo build --bin rust-chatbot --features ssr --no-default-features
Write-Host "✅ Server built" -ForegroundColor Green

Write-Host "`n✨ Build complete!" -ForegroundColor Green
Write-Host "`nRun with: .\target\debug\rust-chatbot.exe" -ForegroundColor Cyan
Write-Host "Then open http://127.0.0.1:3000" -ForegroundColor Cyan
