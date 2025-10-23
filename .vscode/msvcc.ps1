# Compile C++ source with MSVC toolchain via Developer Powershell.
# Copyright (C) 2025 Corna. All rights reserved.

param(
	[string]$file,
	[string]$workspaceFolder,
	[string]$fileBasenameNoExtension
)

C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -noe -c `
"&{Import-Module ""C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"";
Enter-VsDevShell 2d932850;
cl.exe ""$file"" /Fe:${workspaceFolder}/bin/${fileBasenameNoExtension}.exe /arch:AVX2 /std:c++20 /Zi /EHac /Wall /D_CRT_SECURE_NO_WARNINGS;
exit `$LastExitCode}"

exit $LastExitCode