# Incident Workflow

## Overview

An Incident represents an **unplanned interruption** or quality degradation of an IT service.
The goal is service restoration as fast as possible, not necessarily root-cause elimination.

## State Diagram

```
                    ┌─────────────┐
            Create  │             │
         ──────────►│     New     │
                    │             │
                    └──────┬──────┘
                           │  First response / agent picked up
                           ▼
                    ┌─────────────┐
                    │ In Progress │◄────────────────────────────┐
                    │             │                             │
                    └──────┬──────┘                             │
                           │                                    │
           ┌───────────────┼──────────────────┐                 │
           │               │                  │                 │
           ▼               ▼                  ▼                 │
  ┌──────────────┐ ┌───────────────┐  ┌──────────────┐         │
  │  Pending     │ │  Pending      │  │  Escalated   │         │
  │  (User)      │ │  (3rd Party)  │  │              │         │
  └──────┬───────┘ └───────┬───────┘  └──────┬───────┘         │
         │                 │                  │                 │
         │ User responds   │ Vendor updates   │ Escalation team │
         └────────┬────────┘                  │ resolves        │
                  │◄──────────────────────────┘                 │
                  │  Agent resumes                              │
                  └────────────────────────────────────────────►│
                           │                                    │
                           ▼ Fix applied
                    ┌─────────────┐
                    │  Resolved   │
                    │             │
                    └──────┬──────┘
                           │
              ┌────────────┴────────────┐
              │ User confirms           │ 72h no response
              ▼                         ▼
       ┌─────────────┐          ┌─────────────┐
       │   Closed    │          │   Closed    │
       │(by user)    │          │(auto-close) │
       └─────────────┘          └─────────────┘
```

## Transition Conditions

| From          | To                | Condition / Trigger                                       |
|---------------|-------------------|-----------------------------------------------------------|
| New           | In Progress       | Agent takes ownership or auto-assignment fires            |
| In Progress   | Pending (User)    | Agent sets status and sends info-request mail             |
| In Progress   | Pending (3rd Party)| Agent waiting for external vendor                        |
| In Progress   | Escalated         | SLA breach (OnSLABreach event) or manual escalation       |
| Pending (User)| In Progress       | User provides information (reply or portal update)        |
| Pending (User)| Closed            | Auto-close after `AutoClose_Hours` without user response  |
| Escalated     | In Progress       | Escalation group takes over                               |
| In Progress   | Resolved          | Agent applies fix and sets resolution text                |
| Resolved      | Closed            | User confirms resolution OR 72 h elapsed                  |
| Resolved      | In Progress       | User reopens (issue persists)                             |

## Priority Assignment Matrix

| Impact ↓ / Urgency → | Low     | Medium   | High     |
|-----------------------|---------|----------|----------|
| Low                   | P4      | P3       | P2       |
| Medium                | P3      | P2       | P1       |
| High                  | P2      | P1       | P1       |

Priority is set automatically when the ticket is created based on the
Impact and Urgency fields selected by the agent or derived from the Category.

## SLA Clock Rules

- **Starts**: When the ticket transitions from `New` to `In Progress`.
- **Pauses**: While in `Pending (User)` or `Pending (3rd Party)` states.
- **Resumes**: When status returns to `In Progress`.
- **Breaches**: OnSLABreach event fires → `escalation.vbs` runs automatically.

## Required Fields

| Field            | Mandatory at | Notes                                      |
|------------------|-------------|---------------------------------------------|
| Summary          | Create      | Max 200 characters                          |
| Category         | Create      | Level 3 (Symptom)                           |
| Priority         | Create      | Default = P3 if not set                     |
| Description      | Create      | Free text; min 20 characters                |
| AssignedGroup    | In Progress | Set automatically by `auto-routing.vbs`     |
| Resolution       | Resolved    | Required to transition to Resolved          |
| RootCause        | Closed      | Optional but recommended for P1/P2          |

## KPI Fields (for Reporting)

| Field              | Description                                  |
|--------------------|----------------------------------------------|
| FirstResponseTime  | Minutes from New to first agent comment       |
| ResolutionTime     | Business hours from New to Resolved           |
| EscalationCount    | Number of times ticket was escalated          |
| ReopenCount        | Number of times ticket was reopened           |
| SLABreached        | Boolean – was SLA missed?                     |
