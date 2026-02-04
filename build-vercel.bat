@echo off
REM Vercel build script for Flutter Web (Windows)
REM This script builds the Flutter web app with environment variables

echo Starting Flutter web build for Vercel...

REM Build Flutter web with environment variables from Vercel
flutter build web --release --dart-define=SUPABASE_URL=%SUPABASE_URL% --dart-define=SUPABASE_ANON_KEY=%SUPABASE_ANON_KEY% --dart-define=PAYSTACK_PUBLIC_KEY=%PAYSTACK_PUBLIC_KEY% --dart-define=PAYSTACK_SECRET_KEY=%PAYSTACK_SECRET_KEY%

echo Flutter web build completed!
