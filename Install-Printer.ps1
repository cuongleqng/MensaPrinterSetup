$GithubRepo = "https://github.com/cuongleqng/MensaPrinterSetup/main"
if ([Environment]::Is64BitOperatingSystem)
{
    $Architecture = "x64"
}
else
{
    $Architecture = "x86"
}
$DriverName = "TOSHIBA Universal PS3"
$DriverZipUrl = "$GithubRepo/Drivers/TOSHIBA_Universal_PS3_$Architecture.zip"
$ConfigUrl = "$GithubRepo/Config/TOSHIBA_e-STUDIO_6506AC_PS3_$Architecture.dat"

Write-Host ""
Write-Host "Detected Operating System : $Architecture" -ForegroundColor Green

do
{
    $PrinterIP = Read-Host "Nhap dia chi IP may photo"
}
until ($PrinterIP)

$TempFolder = Join-Path $env:TEMP "PrinterInstaller"

if (Test-Path $TempFolder)
{
    Remove-Item $TempFolder -Recurse -Force
}

New-Item -ItemType Directory -Path $TempFolder | Out-Null

$DriverZip = "$TempFolder\Driver.zip"
$ConfigFile = "$TempFolder\Config.dat"

Write-Host ""
Write-Host "Downloading driver..." -ForegroundColor Yellow

Invoke-WebRequest -Uri $DriverZipUrl -OutFile $DriverZip -UseBasicParsing

Write-Host "Extracting driver..." -ForegroundColor Yellow

Expand-Archive -Path $DriverZip -DestinationPath "$TempFolder\Driver" -Force

Write-Host "Downloading configuration..." -ForegroundColor Yellow

Invoke-WebRequest -Uri $ConfigUrl -OutFile $ConfigFile -UseBasicParsing

$PortName = "IP_$PrinterIP"

if (-not (Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue))
{
    Add-PrinterPort -Name $PortName -PrinterHostAddress $PrinterIP
}

$InfFile = Get-ChildItem -Path "$TempFolder\Driver" -Filter *.inf -Recurse | Select-Object -First 1

if (-not $InfFile)
{
    Write-Host "INF file not found." -ForegroundColor Red
    Pause
    exit
}

pnputil.exe /add-driver $InfFile.FullName /install

Start-Sleep -Seconds 3

if (-not (Get-PrinterDriver -Name $DriverName -ErrorAction SilentlyContinue))
{
    try
    {
        Add-PrinterDriver -Name $DriverName
    }
    catch
    {
    }
}

$Random = Get-Random -Minimum 1000 -Maximum 9999
$PrinterName = "TOSHIBA_$Random"

Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PortName

Start-Process rundll32.exe -ArgumentList "printui.dll,PrintUIEntry /Sr /n "$PrinterName" /a "$ConfigFile" f u g d p" -Wait -NoNewWindow

$Rename = Read-Host "Ban co muon doi ten may in? (Y/N)"

if ($Rename -match "^[Yy]$")
{
    $NewName = Read-Host "Nhap ten may in"

    if ($NewName)
    {
        Rename-Printer -Name $PrinterName -NewName $NewName
        $PrinterName = $NewName
    }
}

rundll32 printui.dll,PrintUIEntry /Sr /n "$PrinterName" /a "$ConfigFile" f u g d p
rundll32 printui.dll,PrintUIEntry /y /n "$PrinterName"

Remove-Item $TempFolder -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Installation completed." -ForegroundColor Green
Write-Host "Printer : $PrinterName"
Write-Host "IP      : $PrinterIP"
Write-Host "Driver  : $DriverName"
Write-Host "OS      : $Architecture"

Pause
