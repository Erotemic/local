$heredoc = @'
This script is a powershell script that sets up my minimal dev environment on a
windows VM I can RDP into.
'@

winget install Microsoft.VisualStudioCode --silent --accept-package-agreements --accept-source-agreements

# Force the VM into dark mode:
$regPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-ItemProperty -Path $regPath -Name "SystemUsesLightTheme" -Value 0 -Type Dword -Force
Set-ItemProperty -Path $regPath -Name "AppsUseLightTheme" -Value 0 -Type Dword -Force

winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
winget install --id Python.Python.3.12 -e --silent --accept-package-agreements --accept-source-agreements

# If you started vscode you need to restart to get them on the path



$heredoc = @'
# Once in a project you can:

python -m pip install uv

uv venv .venv --seed --python=3.13
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1

'@
