set objWSHShell = CreateObject("WScript.Shell")
set objFso = CreateObject("Scripting.FileSystemObject")

' command line arguments
' TODO: error checking
sShortcut   = objWSHShell.ExpandEnvironmentStrings(WScript.Arguments.Item(0))
sTargetPath = objWSHShell.ExpandEnvironmentStrings(WScript.Arguments.Item(1))

sWorkingDirectory = "" 'objFso.GetAbsolutePathName(sShortcut)
sTargetArgs = ""

if WScript.Arguments.Length > 3 then
  sWorkingDirectory = objWSHShell.ExpandEnvironmentStrings(WScript.Arguments.Item(3))
end if
if WScript.Arguments.Length > 2 then
  sTargetArgs = objWSHShell.ExpandEnvironmentStrings(WScript.Arguments.Item(2))
end if

WScript.StdOut.Write "-----------sShortcut="
WScript.StdOut.WriteLine sShortcut
WScript.StdOut.Write "---------sTargetPath="
WScript.StdOut.WriteLine sTargetPath
WScript.StdOut.Write "---------sTargetArgs="
WScript.StdOut.WriteLine  sTargetArgs
WScript.StdOut.Write "---sWorkingDirectory="
WScript.StdOut.WriteLine  sWorkingDirectory

'http://www.informit.com/articles/article.aspx?p=1187429&seqNum=5
'IconLocation

set objSC = objWSHShell.CreateShortcut(sShortcut) 
objSC.TargetPath       = sTargetPath 
objSC.Arguments        = sTargetArgs
objSC.WorkingDirectory = sWorkingDirectory
objSC.Save

