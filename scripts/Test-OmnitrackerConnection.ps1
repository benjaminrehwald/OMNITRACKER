<#
.SYNOPSIS
    Testet die Verbindung zur OMNITRACKER REST API.

.DESCRIPTION
    Dieses Skript stellt eine Verbindung zur OMNITRACKER REST API (OData) her
    und gibt eine Log-Nachricht aus, ob die Verbindung erfolgreich war.

.PARAMETER ConfigPath
    Pfad zur Konfigurationsdatei (config.json). Standard: config/config.json
    relativ zum Repository-Root.

.EXAMPLE
    .\scripts\Test-OmnitrackerConnection.ps1

.EXAMPLE
    .\scripts\Test-OmnitrackerConnection.ps1 -ConfigPath "C:\mein\pfad\config.json"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath
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
    $repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    if (-not $repoRoot) {
        $repoRoot = Split-Path -Parent $PSScriptRoot
    }
    $ConfigPath = Join-Path $PSScriptRoot "..\config\config.json"
}

$ConfigPath = [System.IO.Path]::GetFullPath($ConfigPath)

Write-Log "OMNITRACKER REST API Verbindungstest gestartet"
Write-Log "Konfigurationsdatei: $ConfigPath"

if (-not (Test-Path $ConfigPath)) {
    Write-Log "Konfigurationsdatei nicht gefunden: $ConfigPath" -Level "ERROR"
    Write-Log "Bitte erstellen Sie die Datei basierend auf config/config.example.json" -Level "ERROR"
    exit 1
}

try {
    $config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
} catch {
    Write-Log "Fehler beim Lesen der Konfigurationsdatei: $_" -Level "ERROR"
    exit 1
}

# --- Konfiguration validieren ---
if (-not $config.BaseUrl -or -not $config.Username -or -not $config.Password) {
    Write-Log "Konfiguration unvollstaendig. BaseUrl, Username und Password muessen gesetzt sein." -Level "ERROR"
    exit 1
}

$baseUrl = $config.BaseUrl.TrimEnd('/')

Write-Log "Verbinde mit OMNITRACKER: $baseUrl"
Write-Log "Benutzer: $($config.Username)"

# --- Verbindungstest ---
try {
    # Basic-Auth-Header erstellen
    $pair = "$($config.Username):$($config.Password)"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $headers = @{
        "Authorization" = "Basic $base64"
        "Accept"        = "application/json"
    }

    # TLS 1.2 erzwingen (empfohlen fuer OMNITRACKER)
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Verbindungstest: GET-Anfrage an die Basis-URL
    $response = Invoke-RestMethod -Uri $baseUrl -Headers $headers -Method Get -ErrorAction Stop

    Write-Log "Verbindung erfolgreich hergestellt!"
    Write-Log "OMNITRACKER REST API ist erreichbar unter: $baseUrl"

    if ($response) {
        Write-Log "API-Antwort erhalten. Die Verbindung funktioniert."
    }
} catch {
    $statusCode = $null
    if ($_.Exception.Response) {
        $statusCode = [int]$_.Exception.Response.StatusCode
    }

    if ($statusCode) {
        Write-Log "HTTP-Fehler: Statuscode $statusCode" -Level "ERROR"
        switch ($statusCode) {
            401 { Write-Log "Authentifizierung fehlgeschlagen. Bitte Benutzername und Passwort pruefen." -Level "ERROR" }
            403 { Write-Log "Zugriff verweigert. Bitte Berechtigungen pruefen." -Level "ERROR" }
            404 { Write-Log "API-Endpunkt nicht gefunden. Bitte BaseUrl pruefen." -Level "ERROR" }
            default { Write-Log "Unerwarteter Fehler: $_" -Level "ERROR" }
        }
    } else {
        Write-Log "Verbindungsfehler: $($_.Exception.Message)" -Level "ERROR"
        Write-Log "Bitte pruefen Sie, ob der OMNITRACKER-Server erreichbar ist." -Level "ERROR"
    }
    exit 1
}

Write-Log "Verbindungstest abgeschlossen."
