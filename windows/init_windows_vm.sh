#!/bin/bash
__doc__="
TODO: At some point I did this with Virtual Box, but I didn't seem to write
down the instructions in a place I could find them. Need to get instructions to
setup the virtualbox machine.
"

on_host_linux_machine(){

    # List VMs
    VBoxManage list vms

    VM_NAME=WinDev2407Eval
    VBoxManage controlvm "$VM_NAME" poweroff
    #
    VM_NAME=WinDev2407Eval
    VBoxManage modifyvm "$VM_NAME" --natpf1 "ssh,tcp,,2222,,22"

    VBoxManage modifyvm "$VM_NAME" --clipboard bidirectional
    VBoxManage modifyvm "$VM_NAME" --draganddrop bidirectional

    # Enable nested VMs to allow for android emulation in the VM
    VBoxManage modifyvm "$VM_NAME" --nested-hw-virt on

    VM_NAME=WinDev2407Eval
    VBoxManage startvm "$VM_NAME"


}

manual_vm_setup(){
    # login to the vm
    # start powershell in admin mode
    Get-Service sshd

    keyboardputstring

    VM_NAME=WinDev2407Eval
    # With the shell open, can send the command like this:
    INSTALL_SSH_COMMAND="Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0"
    VBoxManage controlvm "$VM_NAME" keyboardputstring "$INSTALL_SSH_COMMAND"
    # Press Enter twice
    VBoxManage controlvm "$VM_NAME" keyboardputscancode 1c 9c
    VBoxManage controlvm "$VM_NAME" keyboardputscancode 1c 9c
    # Takes a minute to install.

    VBoxManage controlvm "$VM_NAME" keyboardputstring "Start-Service sshd"
    VBoxManage controlvm "$VM_NAME" keyboardputscancode 1c 9c
    VBoxManage controlvm "$VM_NAME" keyboardputscancode 1c 9c
    VBoxManage controlvm "$VM_NAME" keyboardputstring "Set-Service -Name sshd -StartupType Automatic"
    VBoxManage controlvm "$VM_NAME" keyboardputscancode 1c 9c
    VBoxManage controlvm "$VM_NAME" keyboardputscancode 1c 9c

    VBoxManage controlvm "$VM_NAME" keyboardputstring "Test-NetConnection -ComputerName localhost -Port 22"
    VBoxManage controlvm "$VM_NAME" keyboardputscancode 1c 9c
    VBoxManage controlvm "$VM_NAME" keyboardputscancode 1c 9c

    VBoxManage controlvm "$VM_NAME" keyboardputstring 'New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -DisplayName "OpenSSH-Server-In-TCP" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22'
    VBoxManage controlvm "$VM_NAME" keyboardputscancode 1c 9c
    VBoxManage controlvm "$VM_NAME" keyboardputscancode 1c 9c


    VBoxManage controlvm "$VM_NAME" keyboardputstring 'Restart-Service sshd'
    VBoxManage controlvm "$VM_NAME" keyboardputscancode 1c 9c
    VBoxManage controlvm "$VM_NAME" keyboardputscancode 1c 9c

    # Optional: Test that you can ssh in
    # ssh -o PreferredAuthentications=password -vvv -p 2222 user@127.0.0.1

    # copy your ssh key over (Weird, does not wseem to work)
    ssh-copy-id \
        -p 2222 \
        -o PreferredAuthentications=password \
        -i ~/.ssh/id_erotemic_ed25519 \
        user@127.0.0.1

    ssh user@127.0.0.1

    # Weird that didn't work. But if we can login try this to force the authorized keys
    SSH_PUBLIC_KEY=$(cat ~/.ssh/id_erotemic_ed25519.pub)

    POWERSHELL_SCRIPT=$(codeblock '
    # 1) Make sure the admins-only authorized_keys file exists and holds your keys
    $dst = "C:\ProgramData\ssh\administrators_authorized_keys"

    # If you already have keys in your user file, copy them over; otherwise paste one key manually
    $src = "$env:USERPROFILE\.ssh\authorized_keys"
    if (Test-Path $src) {
      Get-Content $src | Set-Content $dst -Encoding ascii   # ensure no UTF-16/BOM
    } else {
      # Paste ONE of your public keys below (replace the example) and remove this line after pasting
      "'"$SSH_PUBLIC_KEY"'" | Set-Content $dst -Encoding ascii
    }

    # 2) Apply strict ACLs (must be exactly Administrators + SYSTEM, nothing else)
    icacls $dst /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"

    # (Optional) Tighten the directory too
    # icacls "C:\ProgramData\ssh" /inheritance:r /grant "Administrators:(OI)(CI)F" "SYSTEM:(OI)(CI)F"

    # 3) Restart sshd (good practice after auth changes)
    Restart-Service sshd
    ')

    # Paste this into the windows powershell
    echo "$POWERSHELL_SCRIPT"

    # Now this should work
    ssh -p 2222 user@127.0.0.1



}


build_powershell_init_script(){
# Run in an elevated PowerShell window (Administrator)

powershell_init_script_text='
$ErrorActionPreference = "Stop"

# Define a helper for consistent logging
function Step {
    param([string]$Message)
    $time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host "[$time] [INFO] $Message" -ForegroundColor Cyan
}

# Make powershell the default shell
New-ItemProperty `
  -Path "HKLM:\SOFTWARE\OpenSSH" `
  -Name DefaultShell `
  -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
  -PropertyType String -Force


# Make sure we dont hibernate
$plan = powercfg -duplicatescheme SCHEME_MIN  # duplicates the "High performance" plan

# 2. Set AC power settings to never sleep or turn off display
powercfg /change standby-timeout-ac 0
powercfg /change monitor-timeout-ac 0
powercfg /change hibernate-timeout-ac 0

# (optional) also disable on battery, in case VM reports "battery"
powercfg /change standby-timeout-dc 0
powercfg /change monitor-timeout-dc 0
powercfg /change hibernate-timeout-dc 0

# 3. Disable hibernation file entirely (frees disk space too)
powercfg /hibernate off

# 4. Activate the high-performance plan
powercfg -setactive SCHEME_MIN
#


Step "1) Prep: let this session run scripts and use winget non-interactively"
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

Step "Ensure winget source is ready (first-run quirks)"
winget source update --disable-interactivity | Out-Null

Step "2) Core dev tools (non-interactive as possible)"
$packages = @(
  # Git
  @{ id = "Git.Git" },
  # VS Code (system-wide)
  @{ id = "Microsoft.VisualStudioCode" },
  # .NET 8 SDK LTS
  @{ id = "Microsoft.DotNet.SDK.8" },
  # Windows App SDK for MAUI Windows target
  @{ id = "Microsoft.WindowsAppSDK" },
  # Microsoft OpenJDK 17 (needed for Android toolchain)
  @{ id = "Microsoft.OpenJDK.17" }
)

foreach ($p in $packages) {
  Step "Installing $($p.id)"
  winget install --id $p.id --accept-source-agreements --accept-package-agreements --disable-interactivity
}

Step "3) Enable Developer Mode (helps with Windows app deployment)"
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1

Step "4) Put VS Code CLI on PATH for this session (new shells will have it automatically)"
$codeCmd = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
if (Test-Path $codeCmd) { $env:Path += ";" + (Split-Path $codeCmd) }

Step "5) Install VS Code extensions for .NET dev"
# C# Dev Kit (includes language server + nice project views)
code --install-extension ms-dotnettools.csdevkit --force
# .NET runtime helper (lets Code fetch runtimes when needed)
code --install-extension ms-dotnettools.vscode-dotnet-runtime --force
# IntelliCode (optional but handy)
code --install-extension VisualStudioExptTeam.vscodeintellicode --force

Step "6) Install MAUI workloads + prerequisites"

Step "6a) Ensure dotnet is resolvable now"
$env:Path += ";" + (Get-ChildItem "C:\Program Files\dotnet" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)

Step  "6b) Install the redth MAUI-check tool"
dotnet tool update -g redth.net.maui.check | Out-Null

Step  "6c) Run MAUI-check to auto-fix prerequisites (Android SDKs, emulators optional)"
#   --non-interactive avoids prompts; --fix auto-applies; --skip androidemulator speeds up headless setup
maui-check --non-interactive --fix --skip androidemulator

Step   "6d) Install the MAUI workloads (covers windows + android)"
dotnet workload update
dotnet workload install maui


## Double check git exists
winget install "Git.Git"

# Rebuild the current process PATH from Machine + User + current
$machinePath = [Environment]::GetEnvironmentVariable("Path","Machine")
$userPath    = [Environment]::GetEnvironmentVariable("Path","User")
$env:Path = ($env:Path + ";" + $machinePath + ";" + $userPath) -split ";" |
            Where-Object { $_ -and (Test-Path $_) } |
            Select-Object -Unique |
            ForEach-Object { $_.TrimEnd("\") } |
            -join ";"

# Also add common CLI locations just in case (idempotent)
$commonCli = @(
  "C:\Program Files\Git\cmd",
  "C:\Program Files\Git\bin",
  "$env:LOCALAPPDATA\Programs\Git\cmd",
  "C:\Program Files\dotnet",
  "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin",
  "C:\Program Files\Microsoft VS Code\bin"
) | Where-Object { Test-Path $_ }

foreach ($p in $commonCli) {
  if (-not ($env:Path -split ";" | Where-Object { $_ -ieq $p })) {
    $env:Path += ";$p"
  }
}


Step "7) Verify versions (prints but doesnt block)"
Step "`n=== Versions ==="
git --version
dotnet --info
code --version
Step "OpenSSH Server state:" (Get-Service sshd).Status

Step "`nBootstrap complete. You can SSH to this VM now."


# Settings for nested VM
dism /online /enable-feature /featurename:HypervisorPlatform /all /norestart
dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
systeminfo | find "Hyper-V"

# Will require a system reboot



'

# Reboot machine
VM_NAME=WinDev2407Eval
VBoxManage controlvm "$VM_NAME" reboot

echo "$powershell_init_script_text" > /tmp/init_win.ps1
# Copy script to the windows machine
scp -P 2222 /tmp/init_win.ps1 "user@127.0.0.1":init_win.ps1
# Run it.
ssh -p 2222 user@127.0.0.1 'powershell -ExecutionPolicy Bypass -File C:\Users\User\init_win.ps1'

# Can now ssh and do stuff
ssh -p 2222 user@127.0.0.1


# Now we can get a code repo on the other system
mkdir -p code
cd ~/code
git clone https://github.com/Erotemic/shitspotter.git
cd ~/code/shitspotter

# Handle changes to submodules made remotely
git pull
git submodule sync --recursive

git submodule update --init
git submodule update --init --recursive

}


broken_android_emulator(){

    ps_script='
# Optional install android emulator on windows VM
$SdkRoot = "$env:LOCALAPPDATA\Android\Sdk"
& "$SdkRoot\cmdline-tools\latest\bin\sdkmanager.bat" --sdk_root=$SdkRoot "system-images;android-34;google_apis;x86_64"
& "$SdkRoot\cmdline-tools\latest\bin\avdmanager.bat" create avd -n Pixel_6_API_34 -k "system-images;android-34;google_apis;x86_64" --device "pixel_6"

# Start the emulator
$SdkRoot = "$env:LOCALAPPDATA\Android\Sdk"
& "$SdkRoot\emulator\emulator.exe" -avd Pixel_6_API_34 -gpu host -no-boot-anim -no-snapshot

### Install android tools
winget install --id Google.AndroidSDK.PlatformTools -e
'
    echo "ps_script = $ps_script"

}
