net use Z: \\VBOXSVR\vagrant

choco install -y chocolatey
choco install -y 7zip
choco install -y nsis
choco install -y windows-sdk-10.0

REM Install NsProcess plugin for NSIS
powershell -Command "(New-Object Net.WebClient).DownloadFile('http://nsis.sourceforge.net/mediawiki/images/1/18/NsProcess.zip', 'NsProcess.zip')"
7z -y -o"C:\Program Files (x86)\NSIS\Include\" e NsProcess.zip "Include\nsProcess.nsh"
7z -y -o"C:\Program Files (x86)\NSIS\Plugins\x86-ansi\" e NsProcess.zip "Plugin\nsProcess.dll"
7z -y -o"C:\Program Files (x86)\NSIS\Plugins\x86-unicode\" e NsProcess.zip "Plugin\nsProcess.dll"
