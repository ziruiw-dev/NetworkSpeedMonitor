#!/bin/bash
set -e

echo "=== Building Network Speed monitor ==="

# Clean up previous build artifacts
rm -rf SimpleApp 2>/dev/null || true
mkdir -p SimpleApp

# Copy the source file
cp NetworkSpeedMonitor.swift SimpleApp/main.swift

# Compile the Swift file directly
cd SimpleApp
swiftc -o "Network Speed" main.swift

# Check if compilation succeeded
if [ $? -eq 0 ]; then
    echo "=== Starting Network Speed ==="
    echo "The application should appear in your menu bar"
    echo "Press Ctrl+C to quit"

    # Run the application
    ./"Network Speed"
else
    echo "Compilation failed."
fi 