# Multi-stage Dockerfile for Leptos + Actix application
# Supports both 32-bit (linux/386, linux/arm/v7) and 64-bit (linux/amd64, linux/arm64) architectures

# =============================================================================
# Stage 1: Build Stage
# =============================================================================
FROM rust:slim-bookworm AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    curl \
    wget \
    binaryen \
    perl \
    make \
    gcc \
    libc-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust nightly toolchain and wasm target
RUN rustup default nightly && \
    rustup target add wasm32-unknown-unknown

# Install cargo-leptos (use system OpenSSL instead of building from source)
ENV OPENSSL_NO_VENDOR=1
RUN cargo install cargo-leptos

# Install dart-sass for SCSS compilation
RUN ARCH=$(dpkg --print-architecture) && \
    case "$ARCH" in \
    amd64) SASS_ARCH="linux-x64" ;; \
    arm64) SASS_ARCH="linux-arm64" ;; \
    i386) SASS_ARCH="linux-ia32" ;; \
    armhf) SASS_ARCH="linux-arm" ;; \
    *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    SASS_VERSION="1.69.5" && \
    wget -qO- "https://github.com/sass/dart-sass/releases/download/${SASS_VERSION}/dart-sass-${SASS_VERSION}-${SASS_ARCH}.tar.gz" | tar xz -C /usr/local && \
    ln -s /usr/local/dart-sass/sass /usr/local/bin/sass

# Set working directory
WORKDIR /app

# Copy dependency files first for caching
COPY Cargo.toml Cargo.lock* rust-toolchain.toml ./

# Create a dummy src to build dependencies (for caching)
RUN mkdir -p src && \
    echo "fn main() {}" > src/main.rs && \
    echo "pub fn lib() {}" > src/lib.rs && \
    mkdir -p style && \
    echo "" > style/main.scss

# Build dependencies only (this layer will be cached)
RUN cargo leptos build --release 2>/dev/null || true

# Remove the dummy source files
RUN rm -rf src style target/site

# Copy the actual source code
COPY . .

# Build the application with cargo-leptos
RUN cargo leptos build --release

# =============================================================================
# Stage 2: Runtime Stage
# =============================================================================
FROM debian:bookworm-slim AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user for security
RUN useradd -m -u 1001 -s /bin/bash appuser

# Set working directory
WORKDIR /app

# Copy the built binary from builder stage
COPY --from=builder /app/target/release/rust-chatbot /app/rust-chatbot

# Copy the site assets (compiled WASM, JS, CSS, and static files)
COPY --from=builder /app/target/site /app/site

# Copy Cargo.toml for leptos configuration
COPY --from=builder /app/Cargo.toml /app/Cargo.toml

# Set ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose the application port
EXPOSE 3000

# Set environment variables
ENV LEPTOS_SITE_ROOT=/app/site
ENV LEPTOS_SITE_ADDR=0.0.0.0:3000
ENV RUST_LOG=info

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Run the application
CMD ["./rust-chatbot"]
