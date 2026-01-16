# Rust Chatbot - Setup Script for Windows (PowerShell)
# Author: ARYPROGRAMMER
# Run: .\scripts\setup.ps1

$ErrorActionPreference = "Stop"

Write-Host "🦀 Rust Chatbot Setup Script" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

# Check if Rust is installed
Write-Host "`n📦 Checking Rust installation..." -ForegroundColor Yellow
if (!(Get-Command rustc -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Rust not found. Please install from https://rustup.rs/" -ForegroundColor Red
    exit 1
}

$rustVersion = rustc --version
Write-Host "✅ Found: $rustVersion" -ForegroundColor Green

# Install nightly toolchain and WASM target
Write-Host "`n📦 Setting up Rust nightly toolchain..." -ForegroundColor Yellow
rustup install nightly
rustup default nightly
rustup target add wasm32-unknown-unknown

# Get wasm-bindgen version from Cargo.toml
Write-Host "`n📦 Checking wasm-bindgen version..." -ForegroundColor Yellow
$cargoLock = Get-Content "Cargo.lock" -Raw -ErrorAction SilentlyContinue
if ($cargoLock -match 'name = "wasm-bindgen"\nversion = "([^"]+)"') {
    $wasmBindgenVersion = $matches[1]
} else {
    # Resolve from cargo tree
    $wasmBindgenVersion = (cargo tree -p wasm-bindgen 2>$null | Select-String "wasm-bindgen v" | Select-Object -First 1) -replace ".*wasm-bindgen v([0-9.]+).*", '$1'
}

if ($wasmBindgenVersion) {
    Write-Host "📌 wasm-bindgen version in project: $wasmBindgenVersion" -ForegroundColor Cyan
} else {
    $wasmBindgenVersion = "0.2.108"
    Write-Host "⚠️  Could not detect version, using default: $wasmBindgenVersion" -ForegroundColor Yellow
}

# Install wasm-bindgen-cli
Write-Host "`n📦 Installing wasm-bindgen-cli v$wasmBindgenVersion..." -ForegroundColor Yellow
$installedVersion = (wasm-bindgen --version 2>$null) -replace "wasm-bindgen ", ""
if ($installedVersion -eq $wasmBindgenVersion) {
    Write-Host "✅ wasm-bindgen-cli v$wasmBindgenVersion already installed" -ForegroundColor Green
} else {
    cargo install wasm-bindgen-cli --version $wasmBindgenVersion --force
    Write-Host "✅ wasm-bindgen-cli v$wasmBindgenVersion installed" -ForegroundColor Green
}

# Install cargo-leptos
Write-Host "`n📦 Installing cargo-leptos..." -ForegroundColor Yellow
if (Get-Command cargo-leptos -ErrorAction SilentlyContinue) {
    $leptosVersion = cargo leptos --version
    Write-Host "✅ Found: $leptosVersion" -ForegroundColor Green
} else {
    Write-Host "Installing cargo-leptos (this may take a few minutes)..." -ForegroundColor Yellow
    cargo install cargo-leptos
    Write-Host "✅ cargo-leptos installed" -ForegroundColor Green
}

# Install Node.js dependencies for e2e tests (optional)
Write-Host "`n📦 Setting up e2e tests (optional)..." -ForegroundColor Yellow
if (Test-Path "end2end/package.json") {
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Push-Location end2end
        npm install
        npx playwright install
        Pop-Location
        Write-Host "✅ E2E test dependencies installed" -ForegroundColor Green
    } else {
        Write-Host "⚠️  npm not found, skipping e2e setup" -ForegroundColor Yellow
    }
}

# Create necessary directories
Write-Host "`n📁 Creating build directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "target/site/pkg" | Out-Null
Write-Host "✅ Directories created" -ForegroundColor Green

Write-Host "`n✨ Setup complete!" -ForegroundColor Green
Write-Host "`nTo run the project:" -ForegroundColor Cyan
Write-Host "  cargo leptos serve" -ForegroundColor White
Write-Host "`nOr manually:" -ForegroundColor Cyan
Write-Host "  .\scripts\build.ps1" -ForegroundColor White
Write-Host "  .\target\debug\rust-chatbot.exe" -ForegroundColor White
Write-Host "`nThen open http://127.0.0.1:3000" -ForegroundColor Cyan
