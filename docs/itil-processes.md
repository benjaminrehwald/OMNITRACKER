# ITIL Process Descriptions

## 1. Incident Management

### Definition
An Incident is an **unplanned interruption** or **degradation** of an IT service.
The goal of Incident Management is to restore normal service as quickly as possible.

### Ticket Prefix: `INC-`

### Lifecycle States

```
New → In Progress → Pending (User) → Resolved → Closed
              ↓
           Escalated (L2/L3)
              ↓
           Resolved
```

| State              | Description                                                          |
|--------------------|----------------------------------------------------------------------|
| New                | Ticket created; awaiting first response                             |
| In Progress        | Agent is actively working                                           |
| Pending (User)     | Waiting for user to provide information                             |
| Pending (3rd Party)| Waiting for external vendor                                         |
| Escalated          | Passed to L2 / L3 / specialist group                                |
| Resolved           | Fix applied; user notified; confirmation pending                    |
| Closed             | User confirmed or auto-closed after 72 h in Resolved state          |

### SLA Targets (default, configurable per Category)

| Priority | Response Time | Resolution Time |
|----------|---------------|-----------------|
| P1 – Critical  | 15 min  | 4 h             |
| P2 – High      | 30 min  | 8 h             |
| P3 – Medium    | 2 h     | 24 h            |
| P4 – Low       | 4 h     | 72 h            |

### Routing Logic
1. Category + Symptom selected on form.
2. `auto-routing.vbs` reads `DefaultGroup` from the Category object.
3. `auto-assignment.vbs` checks group workload and assigns to the least-loaded agent.
4. SLA clock starts on `New` → `In Progress` transition.

---

## 2. Service Request Management

### Definition
A Service Request is a **formal request** from a user for standard IT services,
information, or access. It is always fulfilled from the Service Catalog.

### Ticket Prefix: `SR-`

### Lifecycle States

```
New → Pending Approval (optional) → Approved → In Fulfillment → Fulfilled → Closed
                ↓
            Rejected → Closed
```

| State              | Description                                                          |
|--------------------|----------------------------------------------------------------------|
| New                | SR created; awaiting routing / approval                             |
| Pending Approval   | Waiting for manager/IT approval                                     |
| Approved           | All approvals granted; routed to fulfillment group                  |
| Rejected           | At least one approver rejected; requester notified                  |
| In Fulfillment     | Fulfillment group working on the request                            |
| Pending (User)     | Fulfillment team waiting for user input                             |
| Fulfilled          | Service delivered; user notified                                    |
| Closed             | User confirmed or auto-closed after 48 h in Fulfilled state         |

### SLA Targets
SLA starts when the request enters **Approved** state (approval time is excluded).

### Approval Rules
- Defined per catalog item (`ApprovalRequired`, `ApprovalLevel`).
- Automatic escalation to `ApproverGroup` if no response within 24 h.
- Requester is notified at every state transition.

---

## 3. Change Management

### Definition
A Change is the addition, modification, or removal of anything that could affect IT services.

### Ticket Prefix: `CHG-`

### Change Types

| Type      | Description                                    | CAB Required | Auto-Approve |
|-----------|------------------------------------------------|--------------|--------------|
| Standard  | Pre-approved, low-risk, documented procedure   | No           | Yes          |
| Normal    | Moderate risk; requires CAB review             | Yes          | No           |
| Emergency | Urgent change to restore service               | Emergency CAB| No           |

### Lifecycle States

```
Draft → Submitted → Under Review → CAB Approved → Implementation
                         ↓                              ↓
                     CAB Rejected              Post-Implementation Review
                         ↓                              ↓
                      Closed                         Closed
```

| State                      | Description                                          |
|----------------------------|------------------------------------------------------|
| Draft                      | Change being authored                               |
| Submitted                  | Sent to CAB / peer review                           |
| Under Review               | CAB reviewing risk, impact, rollback plan           |
| CAB Approved               | Approved; implementation can begin                  |
| CAB Rejected               | Not approved; change owner must revise              |
| Implementation             | Change being executed                               |
| Post-Implementation Review | Verification that change achieved its goal          |
| Closed                     | Completed and reviewed                              |

### CAB Notification
`cab-notification.vbs` triggers on `Submitted` → `Under Review` transition:
- Notifies all CAB members with: change summary, risk assessment, scheduled window.
- Adds calendar entry to CAB shared calendar (if Exchange integration is active).

### Risk Assessment Matrix

| Impact ↓ / Likelihood → | Low  | Medium | High  |
|--------------------------|------|--------|-------|
| Low                      | 1    | 2      | 3     |
| Medium                   | 2    | 4      | 6     |
| High                     | 3    | 6      | 9     |

- Score 1–2: Standard Change candidate
- Score 3–5: Normal Change
- Score 6–9: Emergency CAB required even for planned changes

---

## 4. Process Interaction

```
Incident (P1/P2) ──────────────────────────────► Problem
                                                     │
                                                     ▼
Service Request (new system needed) ────────► Change (RFC)
                                                     │
                                                     ▼
                                              Implementation
                                                     │
                                              ┌──────▼──────┐
                                              │  Incident?  │ ← caused by Change?
                                              └─────────────┘
```

- A high-volume Incident with the same root cause becomes a **Problem**.
- A Problem's workaround can trigger a **Change** to fix the root cause permanently.
- A Service Request that requires infrastructure work raises a **linked Change**.
