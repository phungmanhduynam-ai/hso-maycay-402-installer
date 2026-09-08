@echo off
setlocal DisableDelayedExpansion
set "TGN_REPO=phungmanhduynam-ai/hso-maycay-402-installer"
set "TGN_BRANCH=main"
set "TGN_TEMP=%TEMP%\TGN-MayCay402-GitHub-%RANDOM%%RANDOM%"
set "TGN_SETUP_VERIFY=0"
set "TGN_SETUP_QUIET=0"
if /i "%~1"=="/verify" set "TGN_SETUP_VERIFY=1"
if /i "%~1"=="/quiet" set "TGN_SETUP_QUIET=1"

mkdir "%TGN_TEMP%" >nul 2>&1
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; function Get-Sha256([string]$Path){$stream=[IO.File]::OpenRead($Path);try{$sha=New-Object Security.Cryptography.SHA256Managed;try{return ([BitConverter]::ToString($sha.ComputeHash($stream))).Replace('-','')}finally{$sha.Dispose()}}finally{$stream.Dispose()}}; function Expand-Zip([string]$ZipPath,[string]$Destination){Add-Type -AssemblyName System.IO.Compression.FileSystem;[IO.Compression.ZipFile]::ExtractToDirectory($ZipPath,$Destination)}; try{[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;$root='https://raw.githubusercontent.com/'+$env:TGN_REPO+'/'+$env:TGN_BRANCH+'/';Write-Host 'Dang tai thong tin phien ban tu GitHub...';$manifest=(Invoke-WebRequest -UseBasicParsing -Uri ($root+'version.json')).Content|ConvertFrom-Json;$name=[string]$manifest.package;$sha=[string]$manifest.package_sha256;if($name -notmatch '^[A-Za-z0-9._-]+\.zip$' -or $sha -notmatch '^[A-Fa-f0-9]{64}$'){throw 'Manifest GitHub khong hop le.'};$zip=Join-Path $env:TGN_TEMP $name;Write-Host ('Dang tai bo cai '+[string]$manifest.display_version+' tu GitHub...');Invoke-WebRequest -UseBasicParsing -Uri ($root+$name) -OutFile $zip;Write-Host 'Dang kiem tra SHA-256...';if((Get-Sha256 $zip) -ne $sha.ToUpperInvariant()){throw 'SHA-256 cua goi tai ve khong khop GitHub.'};$package=Join-Path $env:TGN_TEMP 'package';Expand-Zip $zip $package;& (Join-Path $package 'Install-MayCay.ps1') -PackageRoot $package -VerifyOnly:($env:TGN_SETUP_VERIFY -eq '1');if(-not $?) { throw 'Trinh cai dat tra ve loi.'};if($env:TGN_SETUP_VERIFY -eq '1'){Write-Host 'GOI GITHUB DA XAC MINH.'};exit 0}catch{Write-Host ('CAI DAT THAT BAI: '+$_.Exception.Message) -ForegroundColor Red;Write-Host ('Thu muc chan doan: '+$env:TGN_TEMP);exit 1}"
set "TGN_SETUP_RESULT=%errorlevel%"
if not "%TGN_SETUP_QUIET%"=="1" pause
exit /b %TGN_SETUP_RESULT%
