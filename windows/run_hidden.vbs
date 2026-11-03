Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
WindowsDir = fso.GetParentFolderName(WScript.ScriptFullName)
RootDir = fso.GetParentFolderName(WindowsDir)

WshShell.CurrentDirectory = RootDir
WshShell.Run "cmd.exe /c call """ & WindowsDir & "\run.bat""", 0, False
