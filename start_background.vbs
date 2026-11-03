' Silent Background Launcher for Emby to Telegram Notifier
Set WshShell = CreateObject("WScript.Shell")
strDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
WshShell.CurrentDirectory = strDir

' Run with pythonw.exe (window style 0 = completely hidden)
strPython = strDir & "\venv\Scripts\pythonw.exe"
strScript = strDir & "\emby_to_telegram.py"

WshShell.Run """" & strPython & """ """ & strScript & """", 0, False
