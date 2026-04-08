---

# Konzept: IT Service Management – Neuaufbau Kategorien, Services & Priorisierung im OMNITRACKER

**Firma:** SCHUNK GmbH & Co. KG – Interne IT-Abteilung  
**Stand:** April 2026  
**Version:** 1.0  
**Autor:** IT-Abteilung SCHUNK  
**Status:** Entwurf zur internen Abstimmung

---

## Inhaltsverzeichnis

1. [Ausgangssituation & Problemanalyse](#1-ausgangssituation--problemanalyse)
2. [Zielbild & Leitprinzipien](#2-zielbild--leitprinzipien)
3. [Neue Ticket-Dimensionen im Überblick](#3-neue-ticket-dimensionen-im-überblick)
4. [Services – Neues Service-Modell (15 Services)](#4-services--neues-service-modell-15-services)
5. [Applikationsfeld – Neues abhängiges Dropdown](#5-applikationsfeld--neues-abhängiges-dropdown)
6. [Kategorienbaum – Neuer strukturierter Baum (33 Kategorien)](#6-kategorienbaum--neuer-strukturierter-baum-33-kategorien)
7. [Incident-Symptome (10 standardisierte Symptome)](#7-incident-symptome-10-standardisierte-symptome)
8. [Service Request Offerings & Servicekatalog-Integration](#8-service-request-offerings--servicekatalog-integration)
9. [Priorisierung – Matrix & neuer Prozess](#9-priorisierung--matrix--neuer-prozess)
10. [Routing & Teamzuordnung](#10-routing--teamzuordnung)
11. [Backlog-Bereinigung (1.470 offene Tickets)](#11-backlog-bereinigung-1470-offene-tickets)
12. [Reporting & KPIs](#12-reporting--kpis)
13. [Systemseitige Änderungen im OMNITRACKER](#13-systemseitige-änderungen-im-omnitracker)
14. [Umsetzungsfahrplan (14 Wochen, 4 Phasen)](#14-umsetzungsfahrplan-14-wochen-4-phasen)
15. [Offene Punkte & Entscheidungsbedarf](#15-offene-punkte--entscheidungsbedarf)

---

## 1. Ausgangssituation & Problemanalyse

### 1.1 Kontext

SCHUNK betreibt eine **interne IT-Abteilung** ohne externe Kunden. Das Ticketsystem OMNITRACKER wird für alle IT-Anfragen genutzt – von einfachen Bestellungen bis hin zu kritischen Systemausfällen. Klassische SLAs gegenüber externen Kunden sind nicht notwendig, interne Orientierungswerte jedoch sinnvoll.

### 1.2 Datengrundlage der Ist-Analyse

Die Analyse basiert auf echten Ticketdaten aus dem Zeitraum ca. Q4/2025–Q1/2026:

| Datenbasis | Menge |
|---|---|
| Incidents (INC) | 621 |
| Service Requests (SR) | 1.974 |
| Teams im Statistik-Snapshot | ~40 |
| Offene Tickets (Backlog, Stand 03.04.2026) | **~1.470** |
| Verschiedene Kategorie-Pfade (aktuell) | **326** |

### 1.3 Identifizierte Probleme

#### Problem 1: Priorisierung faktisch nicht vorhanden

- Ca. **95 % aller Tickets** stehen auf Priorität „Mittel" (Standard-Default)
- Die Felder **Auswirkung**, **Dringlichkeit** und **Priorität** existieren im System, werden aber nicht genutzt
- Die Checkbox **„Nicht SLA-relevant"** wird missbraucht, um Tickets der Priorisierung zu entziehen
- Konsequenz: Keine echte Steuerungsmöglichkeit – jedes Ticket ist gleich wichtig

#### Problem 2: Nur ein einziger Service für alle Tickets

- Alle ~2.600 analysierten Tickets laufen unter dem Service **„Standard Service"**
- Keine Möglichkeit zur Auswertung nach IT-Bereich oder Service-Verantwortlichem
- Kein Service-Routing möglich

#### Problem 3: Kategorienbaum ist dysfunktional

- **326 verschiedene Kategorie-Pfade** bei 2.595 Tickets – viel zu granular und inkonsistent
- **60 %+ aller Tickets** landen in der Catch-All-Kategorie **„Dienstleistung / Beratung"**
- Der Baum vermischt verschiedene Konzepte auf derselben Ebene:
  - Tickettypen (z. B. „Störung")
  - Applikationsnamen (z. B. „VPN", „SAP")
  - Symptome (z. B. „defekt", „Fehler")
  - Leistungsarten (z. B. „Beratung", „Schulung")
- Der 2nd-Level-Support ignoriert die Kategorie – sie wird nur vom 1st Level gepflegt und hat keinen Nutzen

#### Problem 4: Keine Applikationszuordnung

- Es ist nicht auswertbar, wie viele Tickets es pro Applikation (z. B. KISSsoft, SAP MM, Teams) gibt
- Fehlt als eigenes Feld komplett im System

#### Problem 5: Backlog von 1.470 offenen Tickets

- Keine systematische Priorisierung oder Bereinigungsstrategie
- Alte Tickets blockieren die Übersicht und verfälschen Reportings

---

## 2. Zielbild & Leitprinzipien

### 2.1 Leitprinzipien

| Prinzip | Beschreibung |
|---|---|
| **Einfach & wartbar** | Kein Over-Engineering – lieber 15 Services als 150 |
| **Pragmatisch statt akademisch** | Kein ITIL-Lehrbuch, sondern funktionierende Praxis für SCHUNK |
| **Minimaler Entwicklungsaufwand** | Vorhandene OMNITRACKER-Felder nutzen, nur 1 neues Feld |
| **Sofort umsetzbar** | Keine monatelange Projektvorbereitung – 14-Wochen-Plan |
| **Auswertbar** | Multi-dimensionale Berichte nach Service, Applikation, Kategorie |
| **Stabiler Rahmen** | Strukturen bleiben langfristig stabil, Inhalt (Applikationen) erweiterbar |

### 2.2 Kernziele

1. **Priorisierung einführen** – aus 95 % „Mittel" wird eine echte Verteilung
2. **Services strukturieren** – 15 klare IT-Services statt 1 „Standard Service"
3. **Applikation erfassen** – neues Pflichtfeld für Auswertungen
4. **Kategoriensystem bereinigen** – von 326 Pfaden auf 33 stabile Kategorien
5. **Backlog abbauen** – strukturierte 3-Stufen-Bereinigung
6. **Servicekatalog integrieren** – automatisches Ticket-Routing via Mapping-Tabelle
7. **Reporting ermöglichen** – KPIs ohne SLA-Zwang, aber mit echter Datenbasis

---

## 3. Neue Ticket-Dimensionen im Überblick

Jedes Ticket wird künftig durch folgende unabhängige Dimensionen beschrieben:

| Feld | Frage | Quelle / Pflege | Neu? |
|---|---|---|---|
| **Tickettyp** | Incident oder Service Request? | Melder / 1st Level | Nein – bleibt |
| **Service** | Welcher IT-Service ist betroffen? | Melder / 1st Level | Ja – 15 Services |
| **Applikation** | Welches Produkt / Modul konkret? | Melder / 1st Level | **Neu – Dropdown** |
| **Kategorie** | Welcher technische Bereich? | 1st Level | Ja – neuer Baum |
| **Symptom** (INC) | Was genau ist das Problem? | 1st Level | Über Kategorie L2 |
| **Offering** (SR) | Was wird bestellt / angefragt? | Servicekatalog-Mapping | Automatisch |
| **Priorität** | Auswirkung × Dringlichkeit | Berechnet (Matrix) | Prozessänderung |

### Trennungsprinzip

Die vier Hauptdimensionen sind **orthogonal** – jede beantwortet eine andere Frage:

```
Service    → WER ist zuständig? (IT-Bereich)
Applikation → WAS ist betroffen? (konkretes System)
Kategorie  → WIE zeigt es sich? (technischer Bereich)
Priorität  → WIE DRINGEND? (Auswirkung × Dringlichkeit)
```

---

## 4. Services – Neues Service-Modell (15 Services)

### 4.1 Übersicht der 15 Services

Die 15 Services sind in 5 Gruppen organisiert:

#### Gruppe A: Arbeitsplatz & Endgeräte

| # | Service | Beschreibung | Beispiel-Tickets |
|---|---|---|---|
| 1 | **Workplace Hardware** | PC, Laptop, Monitor, Drucker, Zubehör | Laptop kaputt, Tastatur defekt |
| 2 | **Workplace Software** | Betriebssystem, Standardsoftware, Client-Konfiguration | Windows-Update-Problem, Office-Lizenz |
| 3 | **Mobile Devices** | Smartphones, Tablets, MDM | iPhone einrichten, MDM-Profil |

#### Gruppe B: Kommunikation & Zusammenarbeit

| # | Service | Beschreibung | Beispiel-Tickets |
|---|---|---|---|
| 4 | **Telefonie & UC** | Festnetz, Softphone, Conferencing | Cisco-Telefon kein Ton, Teams-Meeting |
| 5 | **E-Mail & Groupware** | Exchange, Outlook, Kalender, Verteiler | Postfach voll, Verteiler anlegen |
| 6 | **Collaboration Tools** | Microsoft Teams, SharePoint, OneDrive | Teams-Kanal anlegen, SharePoint-Rechte |

#### Gruppe C: Business Applications

| # | Service | Beschreibung | Beispiel-Tickets |
|---|---|---|---|
| 7 | **SAP** | Alle SAP-Module (ERP, CRM, BW, etc.) | SAP-Login, Buchungsfehler MM |
| 8 | **Engineering & Konstruktion** | CAD/CAM, PDM, Simulation | KISSsoft Lizenzfehler, EPLAN Absturz |
| 9 | **Business Applications** | Alle anderen Fachapplikationen | CRM-Fehler, DMS-Zugriff |

#### Gruppe D: Infrastruktur & Betrieb

| # | Service | Beschreibung | Beispiel-Tickets |
|---|---|---|---|
| 10 | **Netzwerk & Konnektivität** | LAN, WLAN, VPN, Firewall | VPN trennt sich, WLAN kein Signal |
| 11 | **Server & Virtualisierung** | Windows Server, VMware, Hyper-V | Server nicht erreichbar, VM-Fehler |
| 12 | **Storage & Backup** | NAS, SAN, Backup-Systeme | Backup fehlgeschlagen, Laufwerk voll |
| 13 | **Security & Identity** | AD, IAM, Zertifikate, Antivirus | Passwort zurücksetzen, Zertifikat abgelaufen |

#### Gruppe E: Übergreifend

| # | Service | Beschreibung | Beispiel-Tickets |
|---|---|---|---|
| 14 | **IT-Projekte & Consulting** | Projektarbeit, Beratungsleistungen, Schulungen | Schulungsanfrage, Projektkoordination |
| 15 | **Sonstige IT-Leistungen** | Alles nicht anderweitig zuordenbare | Sonstige Anfragen |

### 4.2 Migration: „Standard Service" → neue Services

Alle offenen Tickets mit „Standard Service" werden im Zuge der Backlog-Bereinigung (Kapitel 11) auf die neuen Services migriert. Neue Tickets erhalten ab Go-Live zwingend einen der 15 Services.

---

## 5. Applikationsfeld – Neues abhängiges Dropdown

### 5.1 Konzept

Das neue Feld **„Applikation"** ist ein **abhängiges Dropdown**: Der Inhalt der Auswahlliste ändert sich dynamisch in Abhängigkeit vom gewählten **Service**. Dies verhindert eine unüberschaubar lange, flache Applikationsliste.

```
Service: "SAP"
  └─ Applikation: [SAP ERP, SAP S/4HANA, SAP BW, SAP CRM, SAP MM, SAP SD, SAP FI, SAP HR, Sonstige SAP-Komponente]

Service: "Engineering & Konstruktion"
  └─ Applikation: [KISSsoft, EPLAN, AutoCAD, SolidWorks, Catia, PDM/Windchill, Sonstige Engineering-App]

Service: "Netzwerk & Konnektivität"
  └─ Applikation: [Cisco Switches, Cisco WLAN, Fortinet VPN, Palo Alto Firewall, Sonstige Netzwerk-Komponente]
```

### 5.2 Vorteile gegenüber alternativen Ansätzen

| Ansatz | Problem |
|---|---|
| Applikation im Kategorienbaum | Vermischung von Konzepten (wie bisher) |
| Flache Applikationsliste (1 Dropdown) | 100+ Einträge, unübersichtlich |
| **Abhängiges Dropdown (gewählt)** | **Überschaubar, erweiterbar, sauber getrennt** |

### 5.3 Pflege & Erweiterung

- Neue Applikationen können jederzeit **ohne Änderung** an Services oder Kategorien ergänzt werden
- Pflege durch den **Service Owner** des jeweiligen Services
- Eintrag „Sonstige [Service]-Applikation" bleibt immer als Fallback erhalten

---

## 6. Kategorienbaum – Neuer strukturierter Baum (33 Kategorien)

### 6.1 Designprinzipien des neuen Baums

- **Max. 2 Ebenen** (Hauptkategorie + Unterkategorie)
- **Beschreibt den technischen Bereich**, nicht die Applikation oder den Tickettyp
- **Stabil** – Kategorien ändern sich selten, neue Applikationen kommen ins Applikationsfeld
- **Universell** – funktioniert für alle Services

### 6.2 Die 33 Kategorien (9 Hauptgruppen)

#### 1. Zugang & Berechtigungen
| L1 | L2 |
|---|---|
| Zugang & Berechtigungen | Account / Login |
| | Berechtigungen / Rollen |
| | Passwort / Reset |
| | Zertifikate / Token |

#### 2. Hardware & Endgeräte
| L1 | L2 |
|---|---|
| Hardware & Endgeräte | Defekt / Störung |
| | Einrichtung / Austausch |
| | Zubehör / Peripherie |

#### 3. Software & Applikationen
| L1 | L2 |
|---|---|
| Software & Applikationen | Installation / Update |
| | Fehler / Absturz |
| | Konfiguration / Einstellung |
| | Lizenz |

#### 4. Netzwerk & Konnektivität
| L1 | L2 |
|---|---|
| Netzwerk & Konnektivität | Verbindungsausfall |
| | Performance / Latenz |
| | VPN / Remote Access |
| | WLAN |

#### 5. E-Mail & Kommunikation
| L1 | L2 |
|---|---|
| E-Mail & Kommunikation | Senden / Empfangen |
| | Postfach / Speicher |
| | Verteiler / Kontakte |
| | Telefonie |

#### 6. Server & Infrastruktur
| L1 | L2 |
|---|---|
| Server & Infrastruktur | Dienst / Service ausgefallen |
| | Performance / Last |
| | Storage / Speicher |
| | Backup / Recovery |

#### 7. Daten & Dokumente
| L1 | L2 |
|---|---|
| Daten & Dokumente | Dateizugriff / Laufwerk |
| | Datenimport / -export |
| | Drucken / Scannen |

#### 8. Bestellung & Bereitstellung
| L1 | L2 |
|---|---|
| Bestellung & Bereitstellung | Neues Gerät / Arbeitsplatz |
| | Software-Beschaffung |
| | Lizenz-Bestellung |
| | Onboarding / Offboarding |

#### 9. Beratung & Projekt
| L1 | L2 |
|---|---|
| Beratung & Projekt | Anfrage / Konzept |
| | Schulung / Training |
| | Projektunterstützung |

### 6.3 Vergleich: Alt vs. Neu

| Kriterium | Aktuell | Neu |
|---|---|---|
| Anzahl Kategorie-Pfade | 326 | **33** |
| Ebenen | Bis zu 4 | **Max. 2** |
| Catch-All-Quote | 60 %+ | **Ziel: < 5 %** |
| Applikationen im Baum | Ja (falsch) | **Nein – eigenes Feld** |
| Tickettypen im Baum | Ja (falsch) | **Nein – eigenes Feld** |

---

## 7. Incident-Symptome (10 standardisierte Symptome)

Für **Incidents** wird das Symptom über die **Kategorie L2** abgebildet – kein separates Zusatzfeld notwendig. Die L2-Kategorien sind so gewählt, dass sie universell die häufigsten Symptome abdecken:

| # | Symptom (via L2) | Beispiel |
|---|---|---|
| 1 | Defekt / Störung | Hardware physisch kaputt |
| 2 | Fehler / Absturz | Applikation zeigt Fehlermeldung |
| 3 | Verbindungsausfall | Netzwerk / VPN nicht erreichbar |
| 4 | Zugriff verweigert | Login funktioniert nicht |
| 5 | Dienst ausgefallen | Server-Service nicht verfügbar |
| 6 | Performance-Problem | System langsam, hohe Latenz |
| 7 | Datenverlust / -fehler | Datei fehlt, Daten fehlerhaft |
| 8 | Backup fehlgeschlagen | Backup-Job mit Fehler |
| 9 | Senden / Empfangen | E-Mail kommt nicht an |
| 10 | Sonstiges Incident-Symptom | Fallback |

---

## 8. Service Request Offerings & Servicekatalog-Integration

### 8.1 Konzept

Service Requests kommen künftig primär aus dem **Servicekatalog**. Jedes Offering im Servicekatalog hat eine hinterlegte **Mapping-Tabelle**, die bei Ticket-Erstellung automatisch alle Felder vorausfüllt.

### 8.2 Mapping-Tabelle (Auszug)

| Offering (Servicekatalog) | Service | Applikation | Kategorie L1 | Kategorie L2 | Team | Prio (Default) |
|---|---|---|---|---|---|---|
| Neuer Benutzer anlegen (FB 501) | Security & Identity | Active Directory | Zugang & Berechtigungen | Account / Login | IT-IAM | Mittel |
| Laptop-Bestellung (FB 604) | Workplace Hardware | – | Bestellung & Bereitstellung | Neues Gerät / Arbeitsplatz | IT-Workplace | Gering |
| VPN-Zugang einrichten (FB 251) | Netzwerk & Konnektivität | Fortinet VPN | Zugang & Berechtigungen | VPN / Remote Access | IT-Network | Mittel |
| SAP-Berechtigung (FB 312) | SAP | SAP ERP | Zugang & Berechtigungen | Berechtigungen / Rollen | SAP-Basis | Mittel |
| Software-Installation | Workplace Software | (Auswahl) | Software & Applikationen | Installation / Update | IT-Workplace | Gering |
| Schulungsanfrage | IT-Projekte & Consulting | – | Beratung & Projekt | Schulung / Training | IT-Projekte | Gering |

### 8.3 FB-Formulare umstellen

Folgende bestehende Formularblätter (FB) werden auf neue Offerings im Servicekatalog umgestellt:

- **FB 501** – Benutzeranlage → Offering: „Neuer Benutzer anlegen"
- **FB 604** – Hardware-Bestellung → Offering: „Gerät bestellen"
- **FB 251** – VPN-Zugang → Offering: „VPN-Zugang einrichten"
- Weitere FBs werden im Umsetzungsfahrplan identifiziert und migriert

---

## 9. Priorisierung – Matrix & neuer Prozess

### 9.1 Bestehende Matrix nutzen

Die Prioritätsmatrix (Auswirkung × Dringlichkeit) existiert bereits im OMNITRACKER und wird aktiviert:

| | **Dringlichkeit: Hoch** | **Dringlichkeit: Mittel** | **Dringlichkeit: Gering** |
|---|---|---|---|
| **Auswirkung: Hoch** | 🔴 Priorität 1 – Kritisch | 🟠 Priorität 2 – Hoch | 🟡 Priorität 3 – Mittel |
| **Auswirkung: Mittel** | 🟠 Priorität 2 – Hoch | 🟡 Priorität 3 – Mittel | 🟢 Priorität 4 – Gering |
| **Auswirkung: Gering** | 🟡 Priorität 3 – Mittel | 🟢 Priorität 4 – Gering | 🟢 Priorität 4 – Gering |

### 9.2 Definitionen

**Auswirkung:**
- **Hoch** – Mehrere Abteilungen / produktionskritischer Prozess betroffen
- **Mittel** – Ein Team / eine Abteilung eingeschränkt
- **Gering** – Einzelner Mitarbeiter betroffen, Workaround vorhanden

**Dringlichkeit:**
- **Hoch** – Muss sofort gelöst werden (kein Aufschub möglich)
- **Mittel** – Lösung innerhalb von 1-2 Werktagen sinnvoll
- **Gering** – Lösung kann bis zur nächsten Woche warten

### 9.3 Prozessänderungen

| Änderung | Alt | Neu |
|---|---|---|
| **Default-Priorität** | Mittel | **Gering** |
| **Priorität-Feld** | Manuell wählbar | **Schreibgeschützt – nur berechnet** |
| **Auswirkung & Dringlichkeit** | Nicht genutzt (Default) | **Pflichtfelder** |
| **Checkbox „Nicht SLA-relevant"** | Wird missbraucht | **Entfernen** |

### 9.4 Orientierungswerte (keine formalen SLAs)

| Priorität | Erstreaktion | Angestrebte Lösung |
|---|---|---|
| 1 – Kritisch | < 30 Minuten | < 4 Stunden |
| 2 – Hoch | < 2 Stunden | < 1 Werktag |
| 3 – Mittel | < 1 Werktag | < 5 Werktage |
| 4 – Gering | < 2 Werktage | < 15 Werktage |

> ⚠️ **Diese Werte sind Orientierungswerte, keine vertraglich zugesicherten SLAs.** Sie dienen der internen Steuerung und dem Reporting.

---

## 10. Routing & Teamzuordnung

### 10.1 Routing-Prinzip

Das primäre Routing erfolgt über den **Service**:

```
Service → zuständiges Team (Service Owner)
```

### 10.2 Service-Owner-Tabelle

| Service | Service Owner / Team |
|---|---|
| Workplace Hardware | IT-Workplace |
| Workplace Software | IT-Workplace |
| Mobile Devices | IT-Workplace |
| Telefonie & UC | IT-Kommunikation |
| E-Mail & Groupware | IT-Kommunikation |
| Collaboration Tools | IT-Kommunikation |
| SAP | SAP-Team (Dispatcher-Modell) |
| Engineering & Konstruktion | IT-Engineering |
| Business Applications | IT-Applications |
| Netzwerk & Konnektivität | IT-Infrastruktur |
| Server & Virtualisierung | IT-Infrastruktur |
| Storage & Backup | IT-Infrastruktur |
| Security & Identity | IT-Security / IT-IAM |
| IT-Projekte & Consulting | IT-Projekte |
| Sonstige IT-Leistungen | IT-1st-Level |

### 10.3 SAP-Sonderfall: Dispatcher-Modell

SAP-Tickets werden initial an den **SAP-Dispatcher** geroutet, der nach Modul/Applikation weiterleitet:

```
Service: SAP → SAP-Dispatcher
  ├─ Applikation: SAP MM → SAP-MM-Team
  ├─ Applikation: SAP FI → SAP-FI-Team
  ├─ Applikation: SAP HR → SAP-HR-Team
  └─ Applikation: SAP BW → SAP-BW-Team
```

---

## 11. Backlog-Bereinigung (1.470 offene Tickets)

### 11.1 3-Stufen-Strategie

| Stufe | Kriterium | Maßnahme | Verantwortlich |
|---|---|---|---|
| **Auto-Close** | Letzte Aktualisierung > 12 Monate | Automatisches Schließen mit Standard-Kommentar | OMNITRACKER-Admin |
| **Team-Review** | Letzte Aktualisierung 6–12 Monate | Team prüft: Lösen, Schließen oder Migrieren | Service Owner |
| **Migration** | Letzte Aktualisierung < 6 Monate | Ticket bleibt offen, erhält neue Felder (Service, Applikation, Kategorie) | 1st Level |

### 11.2 Kommentar-Template für Auto-Close

> *„Dieses Ticket wird automatisch geschlossen, da seit mehr als 12 Monaten keine Aktivität stattgefunden hat. Falls das Problem weiterhin besteht, bitte ein neues Ticket mit aktuellen Informationen erstellen."*

### 11.3 Grundsatz: Kein Re-Open alter Tickets

- Alte Tickets werden **nicht wieder geöffnet**
- Bei erneutem Bedarf: **immer neues Ticket** mit korrekter neuer Struktur anlegen
- Altes Ticket kann als Referenz verlinkt werden

### 11.4 Zeitplan Backlog-Bereinigung

| Woche | Aktivität |
|---|---|
| Woche 1–2 | Auto-Close aller Tickets > 12 Monate (ca. 30-40 % des Backlogs) |
| Woche 3–5 | Team-Review für Tickets 6–12 Monate |
| Woche 6–8 | Migration aktiver Tickets auf neue Struktur |
| Ab Woche 9 | Laufende Pflege – nur neue Tickets mit neuer Struktur |

---

## 12. Reporting & KPIs

### 12.1 Multi-dimensionale Auswertung

Das neue Datenmodell ermöglicht Auswertungen nach beliebiger Kombination:

```
Filter-Beispiele:
• Service = "SAP" AND Applikation = "SAP MM"         → Alle SAP-MM-Tickets
• Kategorie = "Zugang & Berechtigungen"               → Alle Zugangsprobleme
• Applikation = "KISSsoft"                            → KISSsoft-spezifische Tickets
• Service = "Netzwerk" AND Priorität = "Kritisch"     → Kritische Netzwerk-Incidents
```

### 12.2 Standard-KPIs (ohne SLA-Zwang)

| KPI | Beschreibung | Messung |
|---|---|---|
| **Ticketvolumen** | Anzahl Tickets pro Zeitraum nach Service / Applikation | Wöchentlich |
| **Erstlösungsquote** | Anteil Tickets gelöst ohne Weiterleitung | Wöchentlich |
| **Ø Lösungszeit** | Durchschnittliche Bearbeitungszeit nach Priorität | Monatlich |
| **Backlog-Alter** | Anteil offener Tickets nach Alter-Klassen | Monatlich |
| **Prio-Verteilung** | Anteil P1/P2/P3/P4 an allen Tickets | Wöchentlich |
| **Top 10 Applikationen** | Applikationen mit den meisten Tickets | Monatlich |
| **Top 5 Kategorien** | Häufigste Kategorien (Trendanalyse) | Wöchentlich |

### 12.3 Beispiel-Dashboard (Weekly)

Das bestehende Weekly Dashboard wird um folgende Dimensionen erweitert:

- **Vorher:** Nur ZDF (Zahlen, Daten, Fakten) + Top 5 Kategorien
- **Nachher:** + Service-Verteilung + Top 10 Applikationen + Prio-Verteilung

---

## 13. Systemseitige Änderungen im OMNITRACKER

### 13.1 Übersicht Änderungen

| Änderung | Aufwand | Typ |
|---|---|---|
| **Services anlegen** (15 neue Services, alt deaktivieren) | Gering | Konfiguration |
| **Neues Feld „Applikation"** (abhängiges Dropdown) | **Mittel** | **Entwicklung (einmalig)** |
| **Kategorienbaum neu aufbauen** (33 Kategorien) | Gering | Konfiguration |
| **Default-Priorität auf „Gering" ändern** | Gering | Konfiguration |
| **Priorität-Feld schreibschützen** | Gering | Konfiguration |
| **Checkbox „Nicht SLA-relevant" entfernen** | Gering | Konfiguration |
| **Mapping-Tabelle erweitern** (Servicekatalog) | Gering | Konfiguration |

### 13.2 Einzige echte Entwicklungsaufgabe

Das **abhängige Dropdown-Feld „Applikation"** ist die einzige systemseitige Entwicklungsaufgabe:

- Neues Formularfeld anlegen
- Abhängigkeitslogik implementieren (Inhalt filtert nach Service-Auswahl)
- In alle relevanten Formulare (Neu, Bearbeiten, Detailansicht) integrieren
- Pflichtfeld-Validierung konfigurieren

Alle anderen Änderungen sind **Konfigurationsaufgaben ohne Coding-Aufwand**.

---

## 14. Umsetzungsfahrplan (14 Wochen, 4 Phasen)

### Phase 1: Vorbereitung & Design (Woche 1–3)

| Woche | Aktivität | Ergebnis |
|---|---|---|
| 1 | Konzept abstimmen, Entscheidungen herbeiführen (Kapitel 15) | Freigabe Konzept |
| 2 | Service-Liste finalisieren, Applikations-Listen pro Service befüllen | Excel-Tabelle final |
| 2 | Mapping-Tabelle Servicekatalog vervollständigen | Mapping komplett |
| 3 | OMNITRACKER-Entwicklung beauftragen: Applikationsfeld | Entwicklungsauftrag |

### Phase 2: Entwicklung & Konfiguration (Woche 4–7)

| Woche | Aktivität | Ergebnis |
|---|---|---|
| 4–6 | Entwicklung Applikationsfeld | Fertige Komponente |
| 4 | Services im OMNITRACKER anlegen | 15 Services aktiv |
| 5 | Neuen Kategorienbaum einpflegen | 33 Kategorien aktiv |
| 6 | Prioritätslogik anpassen (Default, Schreibschutz) | Prio-Logik aktiv |
| 7 | Mapping-Tabelle einpflegen | Servicekatalog-Integration |

### Phase 3: Test & Schulung (Woche 8–10)

| Woche | Aktivität | Ergebnis |
|---|---|---|
| 8 | Integrationstest gesamte neue Struktur | Testprotokoll |
| 9 | Schulung 1st Level (Service, Applikation, Kategorie, Prio) | Schulungsdurchführung |
| 10 | Schulung 2nd Level & Service Owner | Schulungsdurchführung |

### Phase 4: Go-Live & Backlog-Bereinigung (Woche 11–14)

| Woche | Aktivität | Ergebnis |
|---|---|
| 11 | **Go-Live** neue Struktur | Produktivbetrieb |
| 11 | Auto-Close Tickets > 12 Monate | Backlog reduziert |
| 12–13 | Team-Reviews Tickets 6–12 Monate | Backlog bereinigt |
| 13–14 | Migration aktiver Tickets | Alle Tickets neue Struktur |
| 14 | Erstauswertung nach neuer Struktur | Erstes sauberes Reporting |

---

## 15. Offene Punkte & Entscheidungsbedarf

Folgende Punkte erfordern eine explizite Entscheidung des IT-Managements:

| # | Fragestellung | Optionen | Empfehlung |
|---|---|---|---|
| 1 | **Sollen SLAs formal eingeführt werden?** | Ja / Nein / Orientierungswerte | Orientierungswerte (kein formales SLA) |
| 2 | **Ist Priorität 1 ein 24/7-Thema?** | Ja (mit Rufbereitschaft) / Nein (nur Bürozeiten) | Klärung mit IT-Leitung |
| 3 | **Wer pflegt Applikationslisten?** | IT-Admin zentral / Service Owner dezentral | Service Owner |
| 4 | **Backlog: Auto-Close ab wann?** | 6 / 9 / 12 Monate | 12 Monate |
| 5 | **Werden FB-Formulare vollständig abgelöst?** | Ja / Nein / Teilweise | Teilweise (sukzessive Migration) |
| 6 | **Symptom als Pflichtfeld oder über Kategorie?** |Eigenes Feld / Über Kategorie L2 | Über Kategorie L2 (kein neues Feld) |

---

## Anhang

### A. Glossar

| Begriff | Definition |
|---|---|
| **INC** | Incident – ungeplante Störung oder Qualitätsminderung eines IT-Services |
| **SR** | Service Request – Standardanfrage oder Bestellung aus dem Servicekatalog |
| **Service** | Logische Gruppierung von IT-Leistungen (z. B. „SAP", „Netzwerk") |
| **Applikation** | Konkretes IT-Produkt oder Modul (z. B. „KISSsoft", „SAP MM") |
| **Kategorie** | Technischer Bereich / Art des Problems (z. B. „Zugang & Berechtigungen") |
| **Offering** | Konkretes Angebot im Servicekatalog (z. B. „Neuer Benutzer anlegen") |
| **Service Owner** | Verantwortliche Person / Team für einen IT-Service |
| **Backlog** | Menge offener, noch nicht abgeschlossener Tickets |
| **SLA** | Service Level Agreement – vertragliche Vereinbarung über Reaktions-/Lösungszeiten |
| **1st Level** | Erster Ansprechpartner, nimmt Tickets auf und löst einfache Anfragen |
| **2nd Level** | Spezialisiertes Team, übernimmt komplexere Tickets vom 1st Level |
| **Dispatcher** | Koordinationsfunktion, die Tickets prüft und an Spezialteams weiterleitet |
| **FB** | Formularblatt – interne SCHUNK-Formulare für standardisierte Anfragen |

### B. Dateien im Repository

| Datei | Inhalt |
|---|---|
| `Konzept_ITSM_Neuaufbau_OMNITRACKER.md` | Dieses Dokument |
| `DatenFKDBReport_Ticketdetails_Incidents.csv` | Exportierte Incident-Ticketdaten (Kategorie-Pfade) |
| `DatenFKDBReport_Ticketdetails_Servicerequests.csv` | Exportierte Service-Request-Ticketdaten |
| `DatenFKDBReport_StatistikSnapshot.csv` | Team-/Bereichs-Statistik |
| `OT-Kategorien.xlsx` | Export bestehender Kategorienbaum |
| `services-export-2026-04-01.xlsx` | Export bestehende Serviceliste |
| `priorität.png` | Screenshot Prioritätsmatrix |
| `Ticket Formular.png` | Screenshot aktuelles Ticket-Formular |
| `Weekly DAshboard.png` | Screenshot Weekly-Dashboard |

---

*Dokument erstellt: April 2026 | Interne IT-Abteilung SCHUNK GmbH & Co. KG*