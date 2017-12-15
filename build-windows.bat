SET "PATH=%PATH%;C:\Program Files (x86)\Windows Kits\10\bin\x86"
SET "PATH=%PATH%;C:\Program Files (x86)\NSIS"

SET "ZIPFILE=%1"
SET "VERSION=%2"

echo "Deleting Z:\ykman-gui\release\"

Z:
rm -rf Z:\ykman-gui\release

echo "Extracting %ZIPFILE% to Z:\ykman-gui\release\"

7z -oykman-gui\release x "%ZIPFILE%"

echo "Signing executables"

signtool sign /fd SHA256 /t http://timestamp.verisign.com/scripts/timstamp.dll ykman-gui\release\ykman.exe
signtool sign /fd SHA256 /t http://timestamp.verisign.com/scripts/timstamp.dll ykman-gui\release\ykman-gui.exe

echo "Making installer"
makensis -D"VERSION=%VERSION%" resources\win\win-installer.nsi
signtool sign /fd SHA256 /t http://timestamp.verisign.com/scripts/timstamp.dll yubikey-manager-qt-%VERSION%-win.exe


echo "Please also sign the installer with PGP."
