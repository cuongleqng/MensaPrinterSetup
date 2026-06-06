#Requires -RunAsAdministrator

$Repo = "https://raw.githubusercontent.com/<username>/<repo>/main"

Write-Host ""
Write-Host "======================================="
Write-Host " Toshiba Online Printer Installer"
Write-Host "======================================="
Write-Host ""

$PrinterIP = Read-Host "Nhap IP may photo"

if ([string]::IsNullOrWhiteSpace($PrinterIP))
{
    Write-Host "IP khong hop le."
    exit
}

$TempFolder = "$env:TEMP\PrinterInstall"

if(Test-Path $TempFolder)
{
    Remove-Item $TempFolder -Recurse -Force
}

New-Item -ItemType Directory -Path $TempFolder | Out-Null

Write-Host ""
Write-Host "Downloading driver..."

$DriverZip = "$TempFolder\driver.zip"

Invoke-WebRequest `
    -Uri "https://github.com/<username>/<repo>/raw/main/Drivers/TOSHIBA_Universal_PS3.zip" `
    -OutFile $DriverZip

Expand-Archive `
    -Path $DriverZip `
    -DestinationPath "$TempFolder\Driver" `
    -Force

Write-Host "Download driver completed."

# Download config
Invoke-WebRequest `
    -Uri "https://github.com/<username>/<repo>/raw/main/Config/TOSHIBA_e-STUDIO_6506AC_PS3_x64.dat" `
    -OutFile "$TempFolder\Config.dat"

$PortName = "IP_$PrinterIP"

Write-Host ""
Write-Host "Creating TCP/IP port..."

if (-not (Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue))
{
    Add-PrinterPort `
        -Name $PortName `
        -PrinterHostAddress $PrinterIP
}

Write-Host "Port created."

$DriverName = "TOSHIBA Universal PS3"

Write-Host ""
Write-Host "Installing driver..."

$InfFile = Get-ChildItem `
    "$TempFolder\Driver" `
    -Filter *.inf `
    -Recurse |
    Select-Object -First 1

pnputil /add-driver $InfFile.FullName /install

Add-PrinterDriver -Name $DriverName

Write-Host "Driver installed."

$PrinterName = "TOSHIBA_$PrinterIP"

Write-Host ""
Write-Host "Creating printer..."

if (-not (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue))
{
    Add-Printer `
        -Name $PrinterName `
        -DriverName $DriverName `
        -PortName $PortName
}

Write-Host "Printer created."

Write-Host ""
$Rename = Read-Host "Ban co muon dat ten khac? (Y/N)"

if ($Rename -match '^[Yy]$')
{
    $NewName = Read-Host "Nhap ten may in"

    Rename-Printer `
        -Name $PrinterName `
        -NewName $NewName

    $PrinterName = $NewName
}

Set-Printer `
    -Name $PrinterName `
    -IsDefault $true

Write-Host ""
Write-Host "======================================="
Write-Host " Cai dat hoan tat"
Write-Host " May in: $PrinterName"
Write-Host " IP: $PrinterIP"
Write-Host "======================================="
Pause
