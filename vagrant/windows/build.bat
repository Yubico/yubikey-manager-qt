SET LIBU2F_HOST_VERSION=1.1.3
SET YKPERS_VERSION=1.18.0
SET LIBUSB_VERSION=1.0.21
SET PY_VERSION=3.6.2
SET QT_VERSION=5.9.3

REM Needed for jom to work.
CALL "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC"\vcvarsall.bat x86
REM Add python and Qt to PATH
SET "PATH=%PATH%;C:\Python36\Scripts;C:\Qt\%QT_VERSION%\msvc2015\bin;C:\Qt\Tools\QtCreator\bin;"

SET RELEASE_DIR=".\ykman-gui\release"
SET CLI_RELEASE_DIR=".\ykman-cli\release"


REM Clean build
git clean -dfx --exclude .vagrant
git -C vendor\yubikey-manager reset --hard
git -C vendor\yubikey-manager clean -dfx
mkdir "%RELEASE_DIR%"

REM Build
qmake yubikey-manager-qt.pro
qmake -o ykman-gui\Makefile ykman-gui\ykman-gui.pro

REM Fix problem with symbolic link
rm .\vendor\yubikey-manager\ykman\yubicommon
xcopy /i /e .\vendor\yubikey-manager\vendor\yubicommon\yubicommon .\vendor\yubikey-manager\ykman\yubicommon
jom

jom

REM Package

wget "https://developers.yubico.com/libu2f-host/Releases/libu2f-host-%LIBU2F_HOST_VERSION%-win32.zip" -O "libu2f-host-%LIBU2F_HOST_VERSION%-win32.zip"
7z x "libu2f-host-%LIBU2F_HOST_VERSION%-win32.zip" -o".\libu2f-host"
powershell -Command "Copy-Item .\libu2f-host\bin\*.dll %RELEASE_DIR% -Force"

wget "https://developers.yubico.com/yubikey-personalization/Releases/ykpers-%YKPERS_VERSION%-win32.zip" -O "ykpers-%YKPERS_VERSION%-win32.zip"
7z x ykpers-%YKPERS_VERSION%-win32.zip -o".\ykpers"
powershell -Command "Copy-Item .\ykpers\bin\*.dll %RELEASE_DIR% -Force"

REM powershell -Command "Invoke-WebRequest \"http://prdownloads.sourceforge.net/libusb/libusb-%LIBUSB_VERSION%.7z\" -O \"libusb-%LIBUSB_VERSION%.7z\" -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome"
wget "http://prdownloads.sourceforge.net/libusb/libusb-%LIBUSB_VERSION%.7z" -O "libusb-%LIBUSB_VERSION%.7z"
7z x libusb-%LIBUSB_VERSION%.7z -o".\libusb"
powershell -Command "Copy-Item .\libusb\MS32\dll\*.dll %RELEASE_DIR% -Force"

wget "https://www.python.org/ftp/python/%PY_VERSION%/python-%PY_VERSION%-embed-win32.zip" -O "python-%PY_VERSION%-embed-win32.zip"
7z x "python-%PY_VERSION%-embed-win32.zip" -o%RELEASE_DIR%

REM Use Qt deployment tool on executable
windeployqt "%RELEASE_DIR%"\ykman-gui.exe -qmldir=.\ykman-gui\qml --no-translations --angle --release

REM Workaround:
REM Manually add pyotherside plugin to release folder.
REM Should be handled by windeployqt, but doesn't seem to be when QML Settings are used (?).
powershell -Command "Copy-Item C:\Qt\%QT_VERSION%\msvc2015\qml\io %RELEASE_DIR% -Recurse -Force"

REM Add python dependencies to release folder
powershell -Command "Copy-Item .\ykman-gui\pymodules %RELEASE_DIR% -Recurse"

REM Remove .pyc files from release folder
powershell -Command "Get-ChildItem -Path %RELEASE_DIR% -File -Include *.pyc -Recurse | Remove-Item -Force"
powershell -Command "Get-ChildItem -Path %RELEASE_DIR% -Include __pycache__ -Recurse | Remove-Item -Force"

REM Remove .cpp source files
powershell -Command "Get-ChildItem -Path %RELEASE_DIR% -Include *.cpp -Recurse | Remove-Item -Force"

REM Remove object files
powershell -Command "Get-ChildItem -Path %RELEASE_DIR% -Include *.obj -Recurse | Remove-Item -Force"

REM Add CLI executable to release folder
copy "%CLI_RELEASE_DIR%"\ykman.exe "%RELEASE_DIR%"

REM Create zip for deployment
7z a yubikey-manager-qt-dev-win.zip "%RELEASE_DIR%"\*

REM Verify that the cli tool can run
copy .\ykman-cli\test.py "%RELEASE_DIR%"
cd "%RELEASE_DIR%"
python test.py
