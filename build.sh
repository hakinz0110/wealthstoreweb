#!/bin/bash
# Vercel build script for Flutter Web

# Build Flutter web with environment variables
flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=PAYSTACK_PUBLIC_KEY="$PAYSTACK_PUBLIC_KEY" \
  --dart-define=PAYSTACK_SECRET_KEY="$PAYSTACK_SECRET_KEY"
