# OMNITRACKER REST API Anbindung

PowerShell-Skripte zur Verbindung mit der OMNITRACKER REST API (OData).

## Voraussetzungen

- Windows mit **PowerShell 5.1** oder höher (oder PowerShell 7+)
- Netzwerkzugriff auf den OMNITRACKER-Server
- OMNITRACKER-Benutzerkonto mit REST-API-Berechtigung

## Einrichtung

### 1. Konfiguration erstellen

Kopieren Sie die Beispiel-Konfiguration und passen Sie die Werte an:

```powershell
Copy-Item config\config.example.json config\config.json
```

Bearbeiten Sie `config\config.json` mit Ihren Zugangsdaten:

```json
{
  "BaseUrl": "https://ihr-omnitracker-server/odata",
  "Username": "ihr_benutzername",
  "Password": "ihr_passwort"
}
```

> **Hinweis:** Die Datei `config/config.json` ist in `.gitignore` eingetragen und wird nicht ins Repository übertragen.

### 2. Verbindung testen

Führen Sie den Verbindungstest aus:

```powershell
.\scripts\Test-OmnitrackerConnection.ps1
```

Bei erfolgreicher Verbindung wird eine Log-Nachricht ausgegeben:

```
[2026-03-19 12:00:00] [INFO] OMNITRACKER REST API Verbindungstest gestartet
[2026-03-19 12:00:00] [INFO] Verbinde mit OMNITRACKER: https://ihr-server/odata
[2026-03-19 12:00:00] [INFO] Verbindung erfolgreich hergestellt!
[2026-03-19 12:00:00] [INFO] Verbindungstest abgeschlossen.
```

### 3. Ticket erstellen (zukünftig)

Das Skript `New-OmnitrackerTicket.ps1` dient als Vorlage für die zukünftige Ticket-Erstellung:

```powershell
.\scripts\New-OmnitrackerTicket.ps1 -Subject "Testticket" -Description "Beschreibung"
```

> **Hinweis:** Die Ticket-Erstellung muss an die spezifische OMNITRACKER-Konfiguration (Entitäten, Felder) angepasst werden.

## Projektstruktur

```
OMNITRACKER/
├── config/
│   ├── config.example.json    # Konfigurations-Vorlage
│   └── config.json            # Ihre Konfiguration (nicht im Repo)
├── scripts/
│   ├── Test-OmnitrackerConnection.ps1  # Verbindungstest
│   └── New-OmnitrackerTicket.ps1       # Ticket-Erstellung (Vorlage)
├── .gitignore
└── README.md
```

## Fehlerbehebung

| Fehler | Lösung |
|--------|--------|
| `401 Unauthorized` | Benutzername oder Passwort prüfen |
| `403 Forbidden` | API-Berechtigungen im OMNITRACKER prüfen |
| `404 Not Found` | BaseUrl in der Konfiguration prüfen |
| Verbindungsfehler | Netzwerkverbindung und Servererreichbarkeit prüfen |