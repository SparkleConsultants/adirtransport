#!/bin/bash

# Adir Transport Backend Setup Script
echo "🚗 Setting up Adir Transport Backend..."

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found. Installing..."
    npm install -g supabase
else
    echo "✅ Supabase CLI found"
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and run this script again."
    exit 1
else
    echo "✅ Docker is running"
fi

# Initialize Supabase if not already done
if [ ! -f "supabase/config.toml" ]; then
    echo "📁 Initializing Supabase project..."
    supabase init
else
    echo "✅ Supabase project already initialized"
fi

# Start Supabase services
echo "🚀 Starting Supabase services..."
supabase start

# Get the local Supabase credentials
echo "📋 Getting Supabase credentials..."
supabase status

# Create .env.local file if it doesn't exist
if [ ! -f ".env.local" ]; then
    echo "📝 Creating .env.local file..."
    cp .env.example .env.local
    echo "⚠️  Please update .env.local with your actual Supabase credentials shown above"
else
    echo "✅ .env.local already exists"
fi

# Apply database migrations
echo "🗄️  Setting up database schema..."
supabase db reset --debug

echo ""
echo "🎉 Backend setup complete!"
echo ""
echo "📍 Services running at:"
echo "   • Database: http://localhost:54322"
echo "   • API: http://localhost:54321"
echo "   • Studio: http://localhost:54323"
echo "   • Email testing: http://localhost:54324"
echo ""
echo "📝 Next steps:"
echo "   1. Update .env.local with your Supabase credentials"
echo "   2. Visit http://localhost:54323 to explore your database"
echo "   3. Test the API endpoints using the provided examples"
echo ""
echo "📚 Check README.md for detailed documentation"