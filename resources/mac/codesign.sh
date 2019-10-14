# Code sign stuff from Python Framework
codesign --timestamp --options runtime --sign 'Developer ID Application' --entitlements entitlements.plist YubiKey\ Manager.app/Contents/Frameworks/Python.framework/Versions/3.7/Resources/Python.app/Contents/MacOS/Python
codesign --timestamp --options runtime --sign 'Developer ID Application' --entitlements entitlements.plist YubiKey\ Manager.app/Contents/Frameworks/Python.framework/Versions/3.7/bin/python3.7
codesign --timestamp --options runtime --sign 'Developer ID Application' --entitlements entitlements.plist YubiKey\ Manager.app/Contents/Frameworks/Python.framework/Versions/3.7/bin/python3.7m
codesign --timestamp --options runtime --sign 'Developer ID Application' --entitlements entitlements.plist YubiKey\ Manager.app/Contents/Frameworks/Python.framework/Versions/3.7/lib/python3.7/lib-dynload/_ssl.cpython-37m-darwin.so
codesign --timestamp --options runtime --sign 'Developer ID Application' --entitlements entitlements.plist YubiKey\ Manager.app/Contents/Frameworks/Python.framework/Versions/3.7/lib/python3.7/site-packages/smartcard/scard/_scard.cpython-37m-darwin.so
codesign --timestamp --options runtime --sign 'Developer ID Application' --entitlements entitlements.plist YubiKey\ Manager.app/Contents/Frameworks/Python.framework/Versions/3.7/lib/python3.7/site-packages/cryptography/hazmat/bindings/_padding.abi3.so
codesign --timestamp --options runtime --sign 'Developer ID Application' --entitlements entitlements.plist YubiKey\ Manager.app/Contents/Frameworks/Python.framework/Versions/3.7/lib/python3.7/site-packages/cryptography/hazmat/bindings/_constant_time.abi3.so
codesign --timestamp --options runtime --sign 'Developer ID Application' --entitlements entitlements.plist YubiKey\ Manager.app/Contents/Frameworks/Python.framework/Versions/3.7/lib/python3.7/site-packages/cryptography/hazmat/bindings/_openssl.abi3.so
codesign --timestamp --options runtime --sign 'Developer ID Application' --entitlements entitlements.plist --deep YubiKey\ Manager.app/Contents/Frameworks/Python.framework/

# Codesign main app
codesign --timestamp --options runtime --sign 'Developer ID Application' --entitlements entitlements.plist --deep YubiKey\ Manager.app
