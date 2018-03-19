#
# Copyright (C) 2018 Ali Abdulkadir <autostart.ini@gmail.com> <sgeto@ettercap-project.org>
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sub-license, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# TODO
# ----
# - next level shit:
# https://www.autoitconsulting.com/site/scripting/autoit-cmdlets-for-windows-powershell/
# - integrate into AppVeyor's Build Worker API
#
# Variables

# Resolve-Path  "C:\Program Files (x86)\Microsoft SDKs\Windows\*\inf2cat.exe"
# Resolve-Path  "C:\Program Files*\Npcap\NPFInstall.exe"
# Resolve-Path  "C:\Windows\System32\Npcap\*.dll"

# Install-time detection
# ======================

# You can check the existence of C:\Program Files\Npcap\NPFInstall.exe to detect Npcap's existence. If Npcap exists, you can check the file version of C:\Program Files\Npcap\NPFInstall.exe to detect Npcap e-version. The e-version also gives you the version. The NSIS code is shown below. $inst_ver is an e-version string like “5.0.7.424”

# GetDllVersion "C:\Program Files\Npcap\NPFInstall.exe" $R0 $R1
# IntOp $R2 $R0 / 0x00010000
# IntOp $R3 $R0 & 0x0000FFFF
# IntOp $R4 $R1 / 0x00010000
# IntOp $R5 $R1 & 0x0000FFFF
# StrCpy $inst_ver "$R2.$R3.$R4.$R5"
# You can check the installation options of an already installed Npcap by reading the registry key: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\npcap\Parameters. The entries like AdminOnly, Loopback, DltNull,Dot11Support, VlanSupport, WinPcapCompatible, etc. show the installation options. Loopback is REG_SZ type. A non-NULL value indicates the option is CHECKED. All other entries are REG_DWORD type. A 0x00000001 value indicates the option is CHECKED.

# Note: Prior to Npcap 0.93, these values were stored in the Services\npcap key directly.



# Get-ChildItem -Path "Cert:\CurrentUser\Root" | ? Subject -eq "CN=@sgeto"


$urlPath = "https://nmap.org/npcap/dist/latest-npcap-installer.exe"
$autoit = 'Run ("latest-npcap-installer.exe /disable_restore_point=yes /npf_startup=yes /loopback_support=yes /dlt_null=no /admin_only=no /dot11_support=yes /vlan_support=yes /winpcap_mode=yes")
WinWait ("Npcap", "License Agreement")
If Not WinActive ("Npcap", "License Agreement") Then WinActivate ("Npcap", "License Agreement")
WinWaitActive ("Npcap", "License Agreement")
Send ("!a")
Send ("!i")
WinWaitActive ("Npcap", "Installation Complete")
Send ("!n")
Send("{Enter}")'

############

echo "Install AutoIT"
choco install -y -r --no-progress autoit.commandline > $null

echo "Generate InstallNpcap.au3"
$autoit | Out-File $PSScriptRoot"\InstallNpcap.au3"

echo "Download the latest Npcap installer"

# https://www.reddit.com/r/PowerShell/comments/3qndf4/not_sure_if_possible_want_to_check_if_file_from/
# https://github.com/ratchetnclank/NSClient-Checks/blob/master/check-screenconnectupdate.ps1
# $LocalDirectory = $PSScriptRoot
# _________
# $LocalFile = "latest-npcap-installer.exe"

# $Variable = $urlPath

# $Response = (Invoke-WebRequest -Uri $Variable -UseBasicParsing).Links

# $Response.Href -Match 'exe' | ForEach-Object { If(($_ -Split '/')[3] -eq $LocalFile){ $NewFile = ($_).Split('/')[3] ; Invoke-WebRequest -Uri $_ -OutFile $LocalDirectory\$NewFile }}

# $LocalFile = $NewFile
# -------
wget $urlPath -UseBasicParsing -OutFile $PSScriptRoot"\latest-npcap-installer.exe"

############

echo "Generate InstallNpcap.exe from InstallNpcap.au3"
Start-Process -FilePath "Aut2exe.exe" -ArgumentList "/in .\contrib\InstallNpcap.au3 /out .\contrib\InstallNpcap.exe /nopack /comp 2 /Console" -NoNewWindow -Wait
# Invoke-Expression "cmd.exe /c Aut2exe.exe /in InstallNpcap.au3 /out InstallNpcap.exe /nopack /comp 2 /Console"

# Aut2exe.exe /in InstallNpcap.au3 /out InstallNpcap.exe /nopack /comp 2 /Console

echo "Run InstallNpcap.exe"
Start-Process -FilePath $PSScriptRoot"\InstallNpcap.exe" -NoNewWindow -wait

# Success!
echo "Npcap installation completed"

# echo Cleanup
# Remove-Item *.exe, *.au3