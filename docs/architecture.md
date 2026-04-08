# OMNITRACKER – System Architecture

## 1. Object Model Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     OMNITRACKER Objects                         │
│                                                                 │
│  ┌──────────────┐  ┌────────────────────┐  ┌───────────────┐   │
│  │   Incident   │  │  Service Request   │  │    Change     │   │
│  │  (INC-xxxxx) │  │    (SR-xxxxx)      │  │  (CHG-xxxxx)  │   │
│  └──────┬───────┘  └────────┬───────────┘  └───────┬───────┘   │
│         │                   │                       │           │
│         └───────────────────┼───────────────────────┘           │
│                             │                                   │
│              ┌──────────────▼──────────────┐                    │
│              │      Category / Service      │                    │
│              │  (Domain > Category >        │                    │
│              │   Symptom / Catalog Item)    │                    │
│              └──────────────┬──────────────┘                    │
│                             │                                   │
│         ┌───────────────────┼───────────────────┐               │
│         │                   │                   │               │
│  ┌──────▼──────┐   ┌────────▼───────┐  ┌───────▼──────┐        │
│  │  Assignment │   │  Approval Chain│  │  SLA / OLA   │        │
│  │   (Groups)  │   │  (Approvers)   │  │  Definition  │        │
│  └─────────────┘   └────────────────┘  └──────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

## 2. Process Separation

| Criterion              | Incident          | Service Request         | Change                  |
|------------------------|-------------------|-------------------------|-------------------------|
| Trigger                | Unplanned event   | User request            | Planned modification    |
| ITIL Classification    | Incident          | Service Request         | Change (Normal/Standard/Emergency) |
| SLA Target             | Resolution time   | Fulfillment time        | Implementation window   |
| Approval Required      | No (by default)   | Yes (1–3 levels)        | Yes (CAB / peer review) |
| Prefix                 | INC-              | SR-                     | CHG-                    |
| Routing basis          | Category/Symptom  | Service Catalog Item    | Change Type / Risk      |

### Decision rule (Script: `common/utility-functions.vbs`, `ClassifyTicket`)

```
Symptom → unplanned degradation → Incident
Catalog Item selected → planned request   → Service Request
Planned modification to infrastructure   → Change
```

## 3. Category Model (three levels)

```
Domain (Level 1)
└── Category (Level 2)
    └── Symptom (Incident) / Service (SR) (Level 3)
```

**Example:**

```
IT Infrastructure
├── Network
│   ├── [INC] No internet access
│   ├── [INC] VPN not connecting
│   └── [SR]  VPN account setup
└── Server
    ├── [INC] Server unreachable
    └── [SR]  New server provisioning

Business Applications
├── SAP
│   ├── [INC] SAP login error
│   └── [SR]  SAP role request
└── Microsoft 365
    ├── [INC] Outlook not sending
    └── [SR]  New M365 license
```

### Routing table (stored on Category object)

| Field                  | Description                                         |
|------------------------|-----------------------------------------------------|
| `DefaultGroup`         | Default assignment group                            |
| `EscalationGroup`      | Group to escalate to after SLA breach               |
| `ApprovalRequired`     | Boolean – triggers approval workflow for SRs        |
| `ApproverGroup`        | Group whose members must approve the SR             |
| `SLA_Hours`            | Target resolution/fulfillment in business hours     |
| `AutoClose_Hours`      | Auto-close after N hours of pending-user state      |

## 4. Automation Events

All scripts are attached to Business Object events in OMNITRACKER Administration:

| Event              | Object          | Script                                        |
|--------------------|-----------------|-----------------------------------------------|
| `OnCreate`         | Incident        | `incident/auto-routing.vbs`                   |
| `OnCreate`         | Incident        | `incident/auto-assignment.vbs`                |
| `OnCreate`         | Service Request | `service-request/approval-workflow.vbs`       |
| `OnStatusChange`   | Service Request | `service-request/fulfillment-routing.vbs`     |
| `OnCreate`         | Change          | `change/cab-notification.vbs`                 |
| `OnStatusChange`   | Change          | `change/change-approval.vbs`                  |
| `OnSLABreach`      | Incident        | `incident/escalation.vbs`                     |
| `OnSLABreach`      | Service Request | `incident/escalation.vbs`                     |

## 5. Mail Notification Strategy

- All outbound mails use shared templates in `common/mail-templates.vbs`.
- Templates support substitution tokens: `{TicketID}`, `{Summary}`, `{AssignedGroup}`,
  `{RequesterName}`, `{SLA_Deadline}`.
- Language selection is automatic based on `Requester.Language` field.

## 6. Scalability Considerations

- Category lookup uses indexed fields only — no full-table scans.
- Scripts read routing rules from the Category object at runtime; no hard-coded group names.
- Adding a new service requires only: a new Category entry + Catalog Item — no script changes.
- SLA definitions are stored in the OMNITRACKER SLA object; scripts reference them by name.
