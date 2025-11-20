@echo off
echo ============================================================
echo  BYPASSING WINDOWS COMMAND LIMIT FOR FLUTTER RUN
echo ============================================================

echo [1/2] Building APK directly with Gradle...
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
cd android
call .\gradlew.bat assembleDebug
if %errorlevel% neq 0 (
    echo BUILD FAILED!
    cd ..
    exit /b %errorlevel%
)
cd ..

echo [2/2] Installing and Running App...
flutter run --debug --use-application-binary="build/app/outputs/apk/debug/app-debug.apk"
