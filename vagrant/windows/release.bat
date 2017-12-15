SET VERSION="%1"

ECHO "Building release of version: %VERSION%"

SET RELEASE_DIR=".\ykman-gui\release"

CALL "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC"\vcvarsall.bat x86
SET "PATH=%PATH%;C:\Program Files (x86)\NSIS"

REM Download Appveyor build
REM powershell -Command "(New-Object Net.WebClient).DownloadFile('https://yubico-builds.s3-eu-west-1.amazonaws.com/yubikey-manager-qt/yubikey-manager-qt-yubikey-manager-qt-%VERSION%-win.zip', 'C:\Users\vagrant\Downloads\yubikey-manager-qt-%VERSION%-win.zip')"
REM 7z x -o"%RELEASE_DIR%" C:\Users\vagrant\Downloads\yubikey-manager-qt-%VERSION%-win.zip

signtool sign /fd SHA256 /t http://timestamp.verisign.com/scripts/timstamp.dll "%RELEASE_DIR%"\ykman-gui.exe
makensis -D"VERSION=%VERSION%" resources\win\win-installer.nsi
signtool sign /fd SHA256 /t http://timestamp.verisign.com/scripts/timstamp.dll "yubikey-manager-qt-%VERSION%-win.exe"
gpg --detach-sign "yubikey-manager-qt-%VERSION%-win.exe"
