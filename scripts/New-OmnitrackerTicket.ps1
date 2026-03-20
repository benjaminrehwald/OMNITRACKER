<#
.SYNOPSIS
    Erstellt ein neues Ticket im OMNITRACKER ueber die REST API.

.DESCRIPTION
    Dieses Skript erstellt ein neues Ticket (Objekt) im OMNITRACKER
    ueber die OData REST API. Dies ist ein Platzhalter fuer die zukuenftige
    Implementierung - im aktuellen Stand wird nur die Struktur vorbereitet.

.PARAMETER ConfigPath
    Pfad zur Konfigurationsdatei (config.json).

.PARAMETER Subject
    Betreff des Tickets.

.PARAMETER Description
    Beschreibung des Tickets.

.EXAMPLE
    .\scripts\New-OmnitrackerTicket.ps1 -Subject "Testticket" -Description "Dies ist ein Test"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath,

    [Parameter(Mandatory = $true)]
    [string]$Subject,

    [Parameter(Mandatory = $false)]
    [string]$Description = ""
)

# --- Logging-Hilfsfunktion ---
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "WARN", "ERROR")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN"  { Write-Host $logMessage -ForegroundColor Yellow }
        default { Write-Host $logMessage -ForegroundColor Green }
    }
}

# --- Konfiguration laden ---
if (-not $ConfigPath) {
    $ConfigPath = Join-Path $PSScriptRoot "..\config\config.json"
}

$ConfigPath = [System.IO.Path]::GetFullPath($ConfigPath)

if (-not (Test-Path $ConfigPath)) {
    Write-Log "Konfigurationsdatei nicht gefunden: $ConfigPath" -Level "ERROR"
    Write-Log "Bitte zuerst Test-OmnitrackerConnection.ps1 ausfuehren." -Level "ERROR"
    exit 1
}

try {
    $config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
} catch {
    Write-Log "Fehler beim Lesen der Konfigurationsdatei: $_" -Level "ERROR"
    exit 1
}

if (-not $config.BaseUrl -or -not $config.Username -or -not $config.Password) {
    Write-Log "Konfiguration unvollstaendig." -Level "ERROR"
    exit 1
}

$baseUrl = $config.BaseUrl.TrimEnd('/')

# --- Auth-Header erstellen ---
$pair = "$($config.Username):$($config.Password)"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{
    "Authorization" = "Basic $base64"
    "Accept"        = "application/json"
    "Content-Type"  = "application/json"
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# --- Ticket erstellen ---
Write-Log "Ticket-Erstellung gestartet"
Write-Log "Betreff: $Subject"

# TODO: Anpassen an die tatsaechliche OMNITRACKER OData-Entitaet und Felder.
# Die Feldnamen muessen an die spezifische OMNITRACKER-Konfiguration angepasst werden.
# Beispiel-Payload (muss an die jeweilige Instanz angepasst werden):
$body = @{
    "Title"       = $Subject
    "Description" = $Description
} | ConvertTo-Json

Write-Log "Sende Ticket an OMNITRACKER..." -Level "INFO"

try {
    # TODO: Den korrekten Endpunkt-Pfad fuer die Ticket-Entitaet eintragen.
    # Beispiel: "$baseUrl/Incidents" oder "$baseUrl/ServiceRequests"
    $ticketUrl = "$baseUrl/Objects"

    $response = Invoke-RestMethod -Uri $ticketUrl -Headers $headers -Method Post -Body $body -ErrorAction Stop

    Write-Log "Ticket erfolgreich erstellt!"
    if ($response) {
        Write-Log "Antwort: $($response | ConvertTo-Json -Depth 3)"
    }
} catch {
    $statusCode = $null
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
    }

    Write-Log "Fehler beim Erstellen des Tickets: $($_.Exception.Message)" -Level "ERROR"
    if ($statusCode) {
        Write-Log "HTTP-Statuscode: $statusCode" -Level "ERROR"
    }
    exit 1
}
