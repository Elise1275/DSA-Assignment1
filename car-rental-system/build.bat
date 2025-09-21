@echo off
echo ======================================
echo Car Rental System - Build Script
echo ======================================

echo.
echo Step 1: Generating gRPC stubs from proto file...
echo.

REM Generate server stubs
echo Generating server code...
bal grpc --input protos/carrental.proto --output carrental_service --mode service
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to generate server code
    pause
    exit /b 1
)

REM Generate client stubs
echo Generating client code...
bal grpc --input protos/carrental.proto --output carrental_client --mode client
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to generate client code
    pause
    exit /b 1
)

echo.
echo Step 2: Building server...
echo.
cd carrental_service
bal build
if %ERRORLEVEL% neq 0 (
    echo Error: Server build failed
    cd ..
    pause
    exit /b 1
)
cd ..

echo.
echo Step 3: Building client...
echo.
cd carrental_client
bal build
if %ERRORLEVEL% neq 0 (
    echo Error: Client build failed
    cd ..
    pause
    exit /b 1
)
cd ..

echo.
echo ======================================
echo Build completed successfully!
echo ======================================
echo.
echo To run the system:
echo 1. Start server: cd carrental_service ^&^& bal run
echo 2. Start client: cd carrental_client ^&^& bal run
echo.
pause