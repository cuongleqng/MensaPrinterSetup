$GithubRepo = "https://raw.githubusercontent.com/cuongleqng/MensaPrinterSetup/main"
if ([Environment]::Is64BitOperatingSystem)
{
    $Architecture = "x64"
}
else
{
    $Architecture = "x86"
}
$DriverName = "TOSHIBA Universal PS3"

Write-Host "$GithubRepo/Drivers/TOSHIBA_Universal_PS3_$Architecture.zip"
Write-Host ""
Write-Host "Detected Operating System : $Architecture" -ForegroundColor Green

Write-Host ""
Write-Host "========================================"
Write-Host "      MSA Printer Installer"
Write-Host "========================================"
Write-Host ""
Write-Host "1. Xerox C8145 - MSA Office"
Write-Host "   PRT-TED-003 # 172.16.11.251"
Write-Host ""
Write-Host "2. Toshiba 6506 - MSA Beta"
Write-Host "   PRT-TED-004 # 172.16.21.251"
Write-Host ""
Write-Host "3. Fuji C7071 - MSA Office"
Write-Host "   PRT-TED-005 # 172.16.11.252"
Write-Host ""
Write-Host "4. Toshiba 6506 - MSA Alpha"
Write-Host "   PRT-TED-006 # 172.16.31.251"
Write-Host ""
Write-Host "5. Toshiba 6506 - MSA Warehouse"
Write-Host "   PRT-TED-007 # 172.16.41.251"
Write-Host ""
Write-Host "6. Toshiba 6506 - MSA Beta Office"
Write-Host "   PRT-TED-008 # 172.16.21.252"
Write-Host ""

$Choice = Read-Host "Select a printer (1-6)"

switch ($Choice)
{
    "1"
    {
        $PrinterIP   = "PRT-TED-003"
        $PrinterName = "Xerox C8145 - MSA Office"
        $DriverName = "Xerox Universal PS3"
        $DriverZipUrl = "$GithubRepo/Drivers/Xerox_Global_Print_Driver_PS_C8_$Architecture.zip"
        $ConfigUrl = "$GithubRepo/Config/Xerox_DefaultBlackWhite_C8_PS_$Architecture.dat"
    }

    "2"
    {
        $PrinterIP   = "PRT-TED-004"
        $PrinterName = "Toshiba 6506 - MSA Beta"
        $DriverName = "TOSHIBA Universal PS3"
        $DriverZipUrl = "$GithubRepo/Drivers/TOSHIBA_Universal_PS3_$Architecture.zip"
        $ConfigUrl = "$GithubRepo/Config/TOSHIBA_e-STUDIO_6506AC_PS3_$Architecture.dat"
    }

    "3"
    {
        $PrinterIP   = "PRT-TED-005"
        $PrinterName = "Fuji C7071 - MSA Office"
        $DriverName  = "Fuji Apeos C7071"
        $DriverZipUrl = "$GithubRepo/Drivers/Fuji_Driver_PCL_C7071_$Architecture.zip"
        $ConfigUrl = "$GithubRepo/Config/Fuji_C7071_PCL_$Architecture.dat"
    }

    "4"
    {
        $PrinterIP   = "PRT-TED-006"
        $PrinterName = "Toshiba 6506 - MSA Alpha"
        $DriverName = "TOSHIBA Universal PS3"
        $DriverZipUrl = "$GithubRepo/Drivers/TOSHIBA_Universal_PS3_$Architecture.zip"
        $ConfigUrl = "$GithubRepo/Config/TOSHIBA_e-STUDIO_6506AC_PS3_$Architecture.dat"
    }

    "5"
    {
        $PrinterIP   = "PRT-TED-007"
        $PrinterName = "Toshiba 6506 - MSA Warehouse"
        $DriverName = "TOSHIBA Universal PS3"
        $DriverZipUrl = "$GithubRepo/Drivers/TOSHIBA_Universal_PS3_$Architecture.zip"
        $ConfigUrl = "$GithubRepo/Config/TOSHIBA_e-STUDIO_6506AC_PS3_$Architecture.dat"
    }

    "6"
    {
        $PrinterIP   = "PRT-TED-008"
        $PrinterName = "Toshiba 6506 - MSA Beta Office"
        $DriverName = "TOSHIBA Universal PS3"
        $DriverZipUrl = "$GithubRepo/Drivers/TOSHIBA_Universal_PS3_$Architecture.zip"
        $ConfigUrl = "$GithubRepo/Config/TOSHIBA_e-STUDIO_6506AC_PS3_$Architecture.dat"
    }

    default
    {
        Write-Host ""
        Write-Host "Invalid selection." -ForegroundColor Red
        Pause
        exit
    }
}

Write-Host ""
Write-Host "Printer Name : $PrinterName"
Write-Host "Printer Host : $PrinterIP"
Write-Host ""

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

Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PortName

Start-Process `
    -FilePath "rundll32.exe" `
    -ArgumentList "printui.dll,PrintUIEntry /Sr /n `"$PrinterName`" /a `"$ConfigFile`" f u g d p" `
    -Wait `
    -NoNewWindow

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
