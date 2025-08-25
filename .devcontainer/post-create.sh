#!/bin/bash

# Post-create script for MoonBit MariaDB dev container
echo "🚀 Running post-create setup..."
echo "📁 Current directory: $(pwd)"

# Initialize MariaDB
echo "📊 Initializing MariaDB..."
~/init-mariadb.sh

# Allow direnv if .envrc exists
if [ -f .envrc ]; then
    echo "🔧 Setting up direnv..."
    direnv allow
    echo "✅ direnv configured"
else
    echo "⚠️  No .envrc file found, skipping direnv setup"
fi

echo "🎉 Post-create setup completed!"
