@echo off
REM Keystore Backup Script for Wealth App
REM Run this script regularly to backup your keystore

echo ========================================
echo Wealth App - Keystore Backup Script
echo ========================================
echo.

REM Set backup directory
set BACKUP_DIR=%USERPROFILE%\Desktop\WealthApp_Keystore_Backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%
set KEYSTORE_FILE=c:\Users\Hakinz_Tech\upload-keystore.jks

echo Creating backup directory...
mkdir "%BACKUP_DIR%" 2>nul

echo.
echo Copying keystore file...
copy "%KEYSTORE_FILE%" "%BACKUP_DIR%\upload-keystore.jks"

echo.
echo Copying key.properties...
copy "android\key.properties" "%BACKUP_DIR%\key.properties"

echo.
echo Copying keystore info document...
copy "KEYSTORE_INFO.md" "%BACKUP_DIR%\KEYSTORE_INFO.md"

echo.
echo ========================================
echo Backup completed successfully!
echo ========================================
echo.
echo Backup location: %BACKUP_DIR%
echo.
echo IMPORTANT: 
echo 1. Store this backup in a secure location
echo 2. Consider encrypting the backup folder
echo 3. Keep multiple copies in different locations
echo.
pause
