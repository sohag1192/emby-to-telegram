Set WshShell = CreateObject("WScript.Shell")
SCRIPT_DIR = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
WshShell.CurrentDirectory = SCRIPT_DIR
WshShell.Run "cmd /c """ & SCRIPT_DIR & "\run.bat""", 0, False
