# Change Workflow

## Overview

A Change is any addition, modification, or removal of anything that could affect IT services.
Change Management balances the need to make changes quickly with the need to minimise risk.

## Change Types at a Glance

| Type      | Pre-approved | CAB Required | Quorum | Auto-Approve |
|-----------|-------------|--------------|--------|--------------|
| Standard  | Yes         | No           | n/a    | Yes          |
| Normal    | No          | Yes          | 3      | No           |
| Emergency | No          | Mini-CAB     | 2      | No           |

## State Diagram

```
                    ┌─────────────┐
            Create  │             │
         ──────────►│    Draft    │
                    │             │
                    └──────┬──────┘
                           │ Change owner submits RFC
                           ▼
                    ┌─────────────┐
                    │  Submitted  │
                    └──────┬──────┘
                           │
              ┌────────────┴────────────┐
              │ Standard change?        │
              ├─────────────────────────┤
             Yes                        No
              │                          │
              ▼                          ▼
    ┌──────────────────┐       ┌──────────────────┐
    │   CAB Approved   │       │   Under Review   │
    │  (auto-approve)  │       │  (CAB voting)    │
    └────────┬─────────┘       └────────┬─────────┘
             │                          │
             │               ┌──────────┴──────────┐
             │               │ Quorum reached?     │
             │               ├─────────────────────┤
             │              Yes        No (rejection)
             │               │                │
             │               ▼                ▼
             │    ┌──────────────────┐  ┌──────────────┐
             │    │   CAB Approved   │  │ CAB Rejected │──► Draft / Closed
             │    └────────┬─────────┘  └──────────────┘
             │             │
             └─────────────┘
                           │ Within approved window
                           ▼
                    ┌─────────────┐
                    │Implementation│
                    │             │
                    └──────┬──────┘
                           │ Implementation complete
                           ▼
                    ┌─────────────────────────┐
                    │ Post-Implementation      │
                    │ Review (PIR)            │
                    └──────┬──────────────────┘
                           │ PIR completed
                           ▼
                    ┌─────────────┐
                    │   Closed    │
                    └─────────────┘
```

## Transition Conditions

| From              | To                    | Condition / Trigger                                        |
|-------------------|-----------------------|------------------------------------------------------------|
| Draft             | Submitted             | Change owner submits for review                            |
| Submitted         | CAB Approved          | Standard change type → auto-approved by `cab-notification.vbs` |
| Submitted         | Under Review          | Normal / Emergency → `cab-notification.vbs` notifies CAB  |
| Under Review      | CAB Approved          | Approval quorum reached (`change-approval.vbs`)            |
| Under Review      | Vote Cast             | A CAB member saves their vote; quorum check runs          |
| Vote Cast         | Under Review          | Quorum not yet reached; remain in review                   |
| Vote Cast         | CAB Approved          | Approval quorum reached (`change-approval.vbs`)            |
| Vote Cast         | CAB Rejected          | Max rejections exceeded (`change-approval.vbs`)            |
| Under Review      | CAB Rejected          | Max rejections exceeded (`change-approval.vbs`)            |
| CAB Rejected      | Draft                 | Change owner revises and resubmits                         |
| CAB Approved      | Implementation        | Change owner initiates within approved window              |
| Implementation    | PIR                   | Change owner marks implementation complete                 |
| PIR               | Closed                | PIR completed and documented                               |

## CAB Voting Rules

- Each CAB member casts a vote: **Approve** or **Reject**.
- Normal change: 3 approval votes required; 1 rejection = rejected.
- Emergency change: 2 approval votes required; 1 rejection = rejected.
- Voting window: 24 hours from notification.
- If quorum is not reached in 24 hours: IT Service Manager decides.

## Emergency CAB Process

1. Change owner contacts IT Service Manager directly (phone).
2. IT Service Manager convenes emergency CAB (min. 2 members available on-call).
3. Emergency CAB meets (phone/Teams) and votes synchronously.
4. Decision recorded in OMNITRACKER within 1 hour of the call.
5. Full documentation must be completed within 24 hours post-implementation.

## Required Fields

| Field            | Mandatory at    | Notes                                                |
|------------------|-----------------|------------------------------------------------------|
| Summary          | Draft           | Max 200 characters                                   |
| ChangeType       | Draft           | Standard / Normal / Emergency                        |
| Description      | Draft           | Detailed description of what is being changed        |
| RiskImpact       | Draft           | Low / Medium / High                                  |
| RiskLikelihood   | Draft           | Low / Medium / High                                  |
| RollbackPlan     | Submitted       | Required before submission                           |
| PlannedStart     | Submitted       | Must be in the future                                |
| PlannedEnd       | Submitted       | Must be after PlannedStart                           |
| DowntimeMinutes  | Submitted       | 0 if no downtime                                     |
| AffectedGroup    | Submitted       | Group(s) impacted by downtime                        |
| ActualStart      | Implementation  | Auto-set by `change-approval.vbs`                    |
| ActualEnd        | PIR             | Auto-set by `change-approval.vbs`                    |
| PIROutcome       | PIR → Closed    | Success / Partial / Failed + lessons learned         |

## KPI Fields

| Field              | Description                                              |
|--------------------|----------------------------------------------------------|
| LeadTime           | Business hours from Submitted to CAB Approved            |
| ImplementationTime | Hours from Implementation start to PIR                   |
| RiskScore          | Calculated: Impact × Likelihood (1–9)                    |
| ChangeSuccess      | PIROutcome = Success or Partial                          |
| EmergencyChange    | Boolean – was this an emergency change?                  |
| UnauthorisedChange | Boolean – was the change implemented without approval?   |
