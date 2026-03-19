# Service Request Workflow

## Overview

A Service Request is a **formal request for a standard IT service** from the Service Catalog.
Unlike incidents, SRs are planned and expected; the goal is timely fulfillment according to SLA.

## State Diagram

```
                    ┌─────────────┐
            Create  │             │
         ──────────►│     New     │
                    │             │
                    └──────┬──────┘
                           │
               ┌───────────┴───────────┐
               │ Approval required?    │
               │ (from Catalog Item)   │
               ├───────────────────────┤
              Yes                      No
               │                       │
               ▼                       │
    ┌─────────────────────┐            │
    │  Pending Approval   │            │
    │  (L1: Line Manager) │            │
    └──────────┬──────────┘            │
               │                       │
    ┌──────────┴──────────┐            │
    │ L2 needed?          │            │
    ├─────────────────────┤            │
   Yes                    No           │
    │                     │            │
    ▼                     ▼            │
┌──────────────┐   ┌──────────────┐   │
│ Pending (L2) │   │   Approved   │◄──┘
│ IT Approval  │──►│              │
└──────────────┘   └──────┬───────┘
                           │
                  ┌────────┴──────────┐
                  │ Rejected?         │
                  ├───────────────────┤
                 No                  Yes
                  │                   │
                  ▼                   ▼
         ┌──────────────┐    ┌──────────────┐
         │In Fulfillment│    │   Rejected   │──► Closed
         │              │    └──────────────┘
         └──────┬───────┘
                │
       ┌────────┴────────┐
       │ Waiting for user│
       │ input?          │
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│  Pending     │  │  Fulfilled   │
│  (User)      │  │              │
└──────┬───────┘  └──────┬───────┘
       │ User responds    │
       └────────►         │
                   ┌──────┴──────┐
          Confirms │             │ 48h no response
                   ▼             ▼
            ┌──────────┐  ┌──────────────┐
            │  Closed  │  │ Closed (auto)│
            └──────────┘  └──────────────┘
```

## Transition Conditions

| From                | To                  | Condition / Trigger                                      |
|---------------------|---------------------|----------------------------------------------------------|
| New                 | Pending Approval    | `approvalRequired = true` on Catalog Item (OnCreate)     |
| New                 | Approved            | `approvalRequired = false` on Catalog Item (OnCreate)    |
| Pending Approval    | L2 Pending Approval | L1 approver approves AND `approvalLevel >= 2`            |
| Pending Approval    | Approved            | L1 approves AND `approvalLevel = 1`                      |
| L2 Pending Approval | Approved            | L2 approver approves                                     |
| Any Pending         | Rejected            | Any approver rejects                                     |
| Approved            | In Fulfillment      | `fulfillment-routing.vbs` routes to group; SLA starts    |
| In Fulfillment      | Pending (User)      | Fulfillment agent needs user input                       |
| Pending (User)      | In Fulfillment      | User responds                                            |
| In Fulfillment      | Fulfilled           | Fulfillment agent marks service as delivered             |
| Fulfilled           | Closed              | User confirms OR 48 h elapsed (auto-close)               |
| Rejected            | Closed              | Automatic on rejection                                   |

## Approval Timeout Handling

- L1 approver: 24 business hours to respond.
- If no response: escalate to `ApproverGroup` and notify IT Service Manager.
- L2 approver: same rules apply.
- Rejection overrides approval at any stage (one rejection = rejected).

## Required Fields

| Field            | Mandatory at       | Notes                                          |
|------------------|--------------------|------------------------------------------------|
| CatalogItem      | Create             | Must reference an active Catalog Item          |
| Summary          | Create             | Max 200 characters                             |
| Description      | Create             | Additional context for fulfillment team        |
| Justification    | Create (if L2)     | Required for L2 approval items                 |
| CostCenter       | Create (if flagged)| Required if `costCenterRequired = true`        |
| AssignedGroup    | Approved           | Set by `fulfillment-routing.vbs`               |
| FulfillmentNotes | Fulfilled          | Required to transition to Fulfilled            |

## SLA Clock Rules

- **Starts**: When SR enters `In Fulfillment` state (approval time is excluded).
- **Pauses**: While in `Pending (User)` state.
- **Resumes**: When SR returns to `In Fulfillment`.
- **Breaches**: `escalation.vbs` fires → escalates to `EscalationGroup`.

## KPI Fields

| Field              | Description                                        |
|--------------------|----------------------------------------------------|
| ApprovalTime       | Business hours from New to Approved                |
| FulfillmentTime    | Business hours from Approved to Fulfilled          |
| TotalLeadTime      | Business hours from New to Closed                  |
| RejectionRate      | % of SRs rejected (per service / per period)       |
| SLABreached        | Boolean                                            |
